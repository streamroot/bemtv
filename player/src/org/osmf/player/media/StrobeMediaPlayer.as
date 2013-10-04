/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 * 
 **********************************************************/

package org.osmf.player.media
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import org.osmf.elements.LightweightVideoElement;
	import org.osmf.events.*;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.PlaybackOptimizationMetrics;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.player.chrome.utils.MediaElementUtils;
	import org.osmf.player.configuration.VideoRenderingMode;
	import org.osmf.player.metadata.MediaMetadata;
	import org.osmf.player.utils.StrobePlayerStrings;
	import org.osmf.player.utils.VideoRenderingUtils;
	import org.osmf.traits.DVRTrait;
	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;

	CONFIG::LOGGING
	{
		import org.osmf.logging.Log;
		import org.osmf.player.debug.StrobeLogger;
	}
	/**
	 * StrobeMediaPlayer is an optimized MediaPlayer. It is able to adjust it's settings for the best
	 * possible playback configuration based on the MediaElement properties. In a future version it will be able to ajust
	 * the playback configuration based on the computed Quality of Service metrics.
	 * 
	 * So far it is setting the optimal smoothing/deblocking settings for the current MediaElement.
	 * It is able to determine the optimal fullScreenSourceRect so that all the scaling is hardware accelerated.
	 * It is using a Double Threshold Buffer strategy.
	 * 
	 * Future versions will implement dynamic buffering strategies and other best practices related to flash video.
	 * 
	 * Important Note: StrobeMediaPlayer needs to be configured before setting the media. 
	 * The configuration settings changed after the media is set might be ignored. 
	 */ 
	public class StrobeMediaPlayer extends MediaPlayer
	{
		public const STROBE_MEDIA_PLAYER_NAMESPACE:String = "strobeMediaPlayer";
			
		public var highQualityThreshold:uint = 480;
		public var videoRenderingMode:uint = VideoRenderingMode.AUTO;
		
		/**
		 * Specifies the time at which the playback possition is being offset from the current time.
		 * 
		 * Note that the actual playback position will be also offset by the buffer time.
		 */ 
		public var dvrSnapToLiveClockOffset: Number = 4;
		
		/** Specifies the buffer time for dvr content. */ 
		public var dvrBufferTime:Number = 2;
		
		/** Specifies the buffer time for DVR Dynamic Stream content. */
		public var dvrDynamicStreamingBufferTime:Number = 4;
		
		/** Specifies the buffer time for LIVE content. */
		public var liveBufferTime:Number = 2;
		
		/** Specifies the buffer time for DVR Dynamic Stream content. */
		public var liveDynamicStreamingBufferTime:Number = 4;
				
		/** Defines the buffer time for dynamic streams */
		public var dynamicStreamBufferTime:Number = 4;
		
		/**
		 * Constructor.
		 * 
		 * @param media
		 */		
		public function StrobeMediaPlayer(media:MediaElement=null)
		{
			super(media);
			
			// Change the default of autoPlay to false (business requirement).
			autoPlay = false;

			addEventListener(MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE, onIsDynamicStreamChange);
			addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
			addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchingChange);	
			addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onDisplayObjectChange);
						
			addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
			addEventListener(MediaElementChangeEvent.MEDIA_ELEMENT_CHANGE, onMediaElementChangeEvent);
			addEventListener(TimeEvent.COMPLETE, onComplete);
		}

		/**
		 * Indicates whether the media is currently paused.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		override public function get paused():Boolean
		{
			return state != PlayState.PLAYING;	    		    
		}
		
		override public function set media(value:MediaElement):void
		{
			super.media = value;
			initializeMediaMetadata();
		}
		
		override public function play():void
		{
			try {
				super.play();
			}
			catch(_:Error)
			{				
			}
			_ended = false;		
		}
		
		override public function seek(time:Number):void
		{
			// Preventing a RTE from being thrown when seeking
			if (canSeek)
			{
				super.seek(time);
			}
		}

		override public function set autoDynamicStreamSwitch(value:Boolean):void
		{
			super.autoDynamicStreamSwitch = value;	
			autoDynamicStreamSwitchFromSetter = value;
		}

		public function get currentSrc():String
		{
			if (media && media.resource && media.resource is URLResource)
			{
				return (media.resource as URLResource).url;
			}
			return "";
		}
		
		public function get videoWidth():Number
		{
			var result:Number = 0;
			try{
				result = mediaWidth;
			}
			catch(_:Error)
			{				
			}
			return result;
		}
		
		public function get videoHeight():Number
		{
			var result:Number = 0;
			try{
				result = mediaHeight;
			}
			catch(_:Error)
			{				
			}
			return result;
		}
		
		public function get mediaMetadata():MediaMetadata			
		{	
			return media && media.metadata ? media.metadata.getValue(MediaMetadata.ID) as MediaMetadata : null;
		}
		
		public function get isDVRLive():Boolean
		{
			return _isDVRLive;
		}

		public function set isDVRLive(value:Boolean):void
		{
			_isDVRLive = value;
		}

		public function get isLive():Boolean
		{			
			if (streamType == StreamType.LIVE)
			{
				return true;
			}
			else if (streamType == StreamType.DVR)
			{
				return isDVRLive;
			}
			else
			{
				return false;
			}
		}
		
		public function get streamType():String
		{
			return media ? media.metadata.getValue("streamType") : StreamType.RECORDED;
		}

		public function get streamItems():Vector.<DynamicStreamingItem>
		{
			if (mediaMetadata && mediaMetadata.resourceMetadata)
			{
				initializeMediaMetadata();
			}
			return mediaMetadata && mediaMetadata.resourceMetadata ? mediaMetadata.resourceMetadata.streamItems : null;
		}
		
		/**
		 * Retrieves the optimal fullScreenSourceRect so that all the scaling is hardware accelerated.
		 * 
		 * It considers both the video quality, video size and the size 
		 * of the monitor on which the video is being currently played.
		 */ 
		public function getFullScreenSourceRect(stageFullScreenWidth:int, stageFullScreenHeight:int):Rectangle
		{
			var rect:Rectangle = null;
			if (fullScreenVideoHeight > highQualityThreshold  && fullScreenVideoWidth > 0)
			{					
				rect
					= VideoRenderingUtils.computeOptimalFullScreenSourceRect
						( stageFullScreenWidth
						, stageFullScreenHeight
						, fullScreenVideoWidth
						, fullScreenVideoHeight
						);								
			}				
			return rect;
		}		
	
		public function seekUntilSuccess(position:Number, maxRepeatCount:uint = 10):void
		{
			var repeatCount:uint = 0;
			// WORKARROUND: FM-939 - HTTPStreamingDVR - the first seek always fails
			// http://bugs.adobe.com/jira/browse/FM-939
			var workarroundTimer:Timer = new Timer(2000, 1);
			workarroundTimer.addEventListener(TimerEvent.TIMER, 
				function (event:Event):void
				{					
					if (canSeek)
					{
						repeatCount ++;
						if (repeatCount < maxRepeatCount)
						{
							seek(position);
						}
					}
				}
			);
			
			addEventListener
				( SeekEvent.SEEKING_CHANGE
					, function(event:SeekEvent):void
					{									
						if (event.seeking == false)
						{
							removeEventListener(event.type, arguments.callee);						
							
							if (workarroundTimer != null)
							{
								// WORKARROUND: FM-939
								workarroundTimer.stop();
								workarroundTimer = null;
							}
						}
						else
						{	
							// WORKARROUND: FM-939
							if (workarroundTimer != null)
							{
								workarroundTimer.start();
							}
						}
					}
				);
			
			// Seek to the live position:
			seek(position);
		}
		
		public function snapToLive():Boolean
		{			
			if (isDVRRecording == false)
			{
				return false;
			}
			
			if (!playing)
			{
				play();
			}
			
			if (canSeek)
			{
				var livePosition:Number = Math.max(0, duration - bufferTime - dvrSnapToLiveClockOffset); 
				if (canSeekTo(livePosition))
				{
					seekUntilSuccess(livePosition);
					isDVRLive = true;
					return true;
				}		
			}	
			return false;
		}
		
		
			
		// Handlers
		//	
		private function onComplete(event:TimeEvent):void
		{
			_ended = true;
		}
		
		private function onMediaElementChangeEvent(event:MediaElementChangeEvent):void
		{
			if (media != null)
			{
				media.metadata.addValue(MediaMetadata.ID, mediaMetadata);
			}
		}
		
		private function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void
		{	
			if (event.state == MediaPlayerState.READY)
			{
				initializeMediaMetadata();
			}
			
			if (event.state == MediaPlayerState.PLAYING)
			{				
				if (isDynamicStream && autoDynamicStreamSwitch != autoDynamicStreamSwitchTemp && firstPlayingState)
				{					
					firstPlayingState = false;
					autoDynamicStreamSwitch = autoDynamicStreamSwitchTemp;
				}
				if (isDynamicStream)
				{
					if (streamType == StreamType.LIVE)
					{
						bufferTime = liveDynamicStreamingBufferTime;
					}
					else if (streamType == StreamType.DVR)
					{
						bufferTime = dvrDynamicStreamingBufferTime;	
					}
					else
					{
						bufferTime = dynamicStreamBufferTime;
					}
				}
				else if (streamType == StreamType.LIVE)
				{
					bufferTime = liveBufferTime;	
				}
				else if (streamType == StreamType.DVR)
				{
					bufferTime = dvrBufferTime;	
				}					
			}		
			
		
		}
		private function onSwitchingChange(event:DynamicStreamEvent):void
		{
			switching = event.switching;
			if (!event.switching)
			{
				if (!(mediaMetadata && mediaMetadata.resourceMetadata && mediaMetadata.resourceMetadata.streamItems))
				{					
					initializeMediaMetadata();					
				}
				
				if (mediaMetadata && mediaMetadata.resourceMetadata && mediaMetadata.resourceMetadata.streamItems)
				{
					mediaMetadata.resourceMetadata.streamItems[currentDynamicStreamIndex].width = mediaWidth;
					mediaMetadata.resourceMetadata.streamItems[currentDynamicStreamIndex].height = mediaHeight;
				}	
			}
			
			var dsTrait:DynamicStreamTrait;
			dsTrait = media.getTrait(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait;
			var now:Date = new Date();
			var switchingDuration:int;
			
			var index:int = dsTrait.currentIndex;
			var bitrate:Number = dsTrait.getBitrateForIndex(index);
			CONFIG::LOGGING
			{
				logger.qos.ds.index = index;
				logger.qos.ds.currentBitrate = bitrate; 
			}
			if (event.switching)
			{
				swichingStartTime = now;
				previousIndex = dsTrait.currentIndex;
				previousBitrate = dsTrait.getBitrateForIndex(dsTrait.currentIndex);				
			}		
			else
			{		
				CONFIG::LOGGING
				{
					if (swichingStartTime)
					{
						
						logger.qos.ds.previousSwitchDuration = (new Date()).time - swichingStartTime.time;
						logger.qos.ds.totalSwitchDuration += logger.qos.ds.previousSwitchDuration;
						logger.qos.ds.dsSwitchEventCount ++;
						logger.qos.ds.avgSwitchDuration = logger.qos.ds.totalSwitchDuration / logger.qos.ds.dsSwitchEventCount;
						logger.info("Switch complete. Previous (index, bitrate)=({0},{1}). Current (index, bitrate)=({2},{3})", previousIndex, previousBitrate, index, bitrate);
					}
				}
			}	
		}
		
		private function onMediaSizeChange(event:DisplayObjectEvent):void
		{
			if (!isDynamicStream && event.newWidth > 0 && event.newHeight > 0)
			{
				fullScreenVideoWidth = event.newWidth;
				fullScreenVideoHeight = event.newHeight;
			}
			
			if (isDynamicStream && currentDynamicStreamIndex == maxAllowedDynamicStreamIndex)
			{
				// Update the fullScreenVideoWidth/Height since we didn't have them in the resource,
				// but we have it now since we are on the highest bitrate stream.					
				fullScreenVideoWidth = event.newWidth;
				fullScreenVideoHeight = event.newHeight;
			}	
			
			// Set the smothing and deblocking using best practices for HD/SD
			if (fullScreenVideoWidth > 0 && fullScreenVideoHeight > 0)
			{
				var lightweightVideoElement:LightweightVideoElement = MediaElementUtils.getMediaElementParentOfType(media, LightweightVideoElement) as LightweightVideoElement;
				if (lightweightVideoElement != null)
				{	
					if (isDynamicStream && fullScreenVideoHeight > event.newHeight)
					{					
						lightweightVideoElement.smoothing = true;
						lightweightVideoElement.deblocking = 0;
						CONFIG::LOGGING
						{	
							logger.info("Enabling smoothing/deblocking since the current resolution is lower then the best vertical resolution for this DynamicStream:" + fullScreenVideoHeight + "p");
						}
					}
					else
					{					
						lightweightVideoElement.smoothing 
							= VideoRenderingUtils.determineSmoothing
							(   videoRenderingMode
								, event.newHeight > highQualityThreshold 
							);
						lightweightVideoElement.deblocking 
							= VideoRenderingUtils.determineDeblocking
							(   videoRenderingMode
								, event.newHeight > highQualityThreshold
							);
						CONFIG::LOGGING
						{	
							logger.info("Updating smoothing & deblocking settings. smoothing=" + lightweightVideoElement.smoothing + " deblocking=" + lightweightVideoElement.deblocking);
						}
					}
				}	
			}
			
			if (isDynamicStream && !switching)				
			{
				if (!(mediaMetadata && mediaMetadata.resourceMetadata && mediaMetadata.resourceMetadata.streamItems))
				{					
					initializeMediaMetadata();					
				}
				
				if (mediaMetadata && mediaMetadata.resourceMetadata && mediaMetadata.resourceMetadata.streamItems)
				{
					mediaMetadata.resourceMetadata.streamItems[currentDynamicStreamIndex].width = event.newWidth;
					mediaMetadata.resourceMetadata.streamItems[currentDynamicStreamIndex].height = event.newHeight;
				}	
			}
		}
		
		private function onDisplayObjectChange(event:Event):void
		{
			var newStreamType:String = MediaElementUtils.getStreamType(media);
			if (newStreamType != streamType)
			{
				media.metadata.addValue("streamType", newStreamType);
				CONFIG::LOGGING
				{
					logger.qos.streamType = streamType;
				}
				var mediaMetadata:MediaMetadata;
				mediaMetadata = new MediaMetadata();			
				mediaMetadata.mediaPlayer = this;
				media.metadata.addValue(MediaMetadata.ID, mediaMetadata);
			}
		}
				
		private function onIsDynamicStreamChange(event:Event):void
		{	
			if (isDynamicStream)
			{
				// Apply the configuration's autoSwitchQuality setting:	
				
				// We need to keep a copy of the last value set throught a setter.
				// Note that at this point the value of the autoDynamicStreamSwitch might not 
				// reflect a value set on the MediaPlayer.				
				autoDynamicStreamSwitchTemp = autoDynamicStreamSwitchFromSetter;
				if (autoDynamicStreamSwitchTemp)
				{
					autoDynamicStreamSwitch = false;
				}
				var _streamItems:Vector.<DynamicStreamingItem>;
				_streamItems = mediaMetadata.resourceMetadata.streamItems;
				
				if (_streamItems == null)
				{
					MediaElementUtils.collectResourceMetadata(media, mediaMetadata.resourceMetadata);
					_streamItems = mediaMetadata.resourceMetadata.streamItems;
				}
				
				if (_streamItems != null)
				{
					// Retrieve the highest quality stream item 
					var dynamicStreamingItem:DynamicStreamingItem;
					dynamicStreamingItem = _streamItems[_streamItems.length-1];
					
					// Pass the width/height to the fullScreenController so that it is able to optimize the size of the fullScreenSourceRect.
					fullScreenVideoWidth = dynamicStreamingItem.width;
					fullScreenVideoHeight = dynamicStreamingItem.height;
					CONFIG::LOGGING
					{
						logger.qos.ds.bestHorizontatalResolution = fullScreenVideoWidth;
						logger.qos.ds.bestVerticalResolution = fullScreenVideoHeight;
					}
				}
			}			
		}
		
		// Internals
		private function initializeMediaMetadata():void
		{
			if (media)
			{
				var _mediaMetadata:MediaMetadata;
				_mediaMetadata = mediaMetadata;
				if (_mediaMetadata == null)
				{
					_mediaMetadata = new MediaMetadata();
					media.metadata.addValue(MediaMetadata.ID, _mediaMetadata);
				}		
				MediaElementUtils.collectResourceMetadata(media, mediaMetadata.resourceMetadata);
				_mediaMetadata.mediaPlayer = this;	
			}
		}
		
		private var previousIndex:uint;
		private var previousBitrate:Number;	
		private var switching:Boolean = false;
		private var swichingStartTime:Date;
		
		private var _ended:Boolean;
		private var _isDVRLive:Boolean;
		private var _streamType:String;
		private var fullScreenVideoWidth:uint = 0;
		private var fullScreenVideoHeight:uint = 0;
		
		private var autoDynamicStreamSwitchFromSetter:Boolean = true;
		private var autoDynamicStreamSwitchTemp:Boolean = true;
		
		private var firstPlayingState:Boolean = true;
		
		CONFIG::LOGGING
		{
			protected var logger:StrobeLogger = Log.getLogger("StrobeMediaPlayback") as StrobeLogger;
		}
	}
}