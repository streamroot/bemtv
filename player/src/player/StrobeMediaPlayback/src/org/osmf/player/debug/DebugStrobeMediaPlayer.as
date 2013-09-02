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

package org.osmf.player.debug
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	import flash.system.System;
	import flash.utils.Timer;
	
	import org.osmf.elements.LightweightVideoElement;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.net.*;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.player.chrome.utils.MediaElementUtils;
	import org.osmf.player.media.StrobeMediaPlayer;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TraitEventDispatcher;

	CONFIG::FLASH_10_1
	{
		import flash.net.NetGroup;
		import flash.net.NetGroupInfo;
	}
	/**
	 * An extension to the StrobeMediaPlayer class which is responsible 
	 * for tracking qos information.
	 */  
	public class DebugStrobeMediaPlayer extends StrobeMediaPlayer
	{
		/**
		 * Constructor. Logs all the MediaPlayer events.
		 * Additionally it registers handlers for the main
		 * player state changes so that it updates the QoS stats.
		 */ 
		public function DebugStrobeMediaPlayer()
		{		
			addEventListener(MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE, logger.event);
			addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, logger.event);
			addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, logger.event);
			addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, logger.event);
			addEventListener(MediaErrorEvent.MEDIA_ERROR, logger.event);
			addEventListener(MediaPlayerCapabilityChangeEvent.TEMPORAL_CHANGE, logger.event);
		
			addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
			
			addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
			
			debugTimer = new Timer(SAMPLING_TIMEOUT);
			debugTimer.addEventListener(TimerEvent.TIMER, onDebugTimer);
			debugTimer.start();
		}
		
		// Internals
		//	
		
		private function onDebugTimer(event:Event):void
		{
			logger.qos.duration = duration;
			logger.qos.memory = System.totalMemory / 1048576;
			
			if (media && media.hasTrait(MediaTraitType.DISPLAY_OBJECT))
			{
				var displayObjectTrait:DisplayObjectTrait = media.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
				if (displayObjectTrait)
				{
					var displayObject:DisplayObject = displayObjectTrait.displayObject;
					if (displayObject)
					{
						var _stage:Stage = displayObject.stage;
						if (_stage)
						{
							logger.qos.rendering.screenWidth = _stage.fullScreenWidth;
							logger.qos.rendering.screenHeight = _stage.fullScreenHeight;
							logger.qos.rendering.screenAspectRatio = logger.qos.rendering.screenWidth  / logger.qos.rendering.screenHeight;
							
							if (_stage.fullScreenSourceRect !=null)
							{
								logger.qos.rendering.fullScreenSourceRect = 
									_stage.fullScreenSourceRect.toString();
								logger.qos.rendering.fullScreenSourceRectAspectRatio = _stage.fullScreenSourceRect.width / _stage.fullScreenSourceRect.height;
							}
							else
							{
								logger.qos.rendering.fullScreenSourceRect =	"";
								logger.qos.rendering.fullScreenSourceRectAspectRatio = NaN;
							}
						}	
						logger.qos.rendering.displayObjectWidth = displayObject.width;
						logger.qos.rendering.displayObjectHeight = displayObject.height;
						logger.qos.rendering.displayObjectRatio = displayObject.width / displayObject.height;
					}	
				}
			}
			
			logger.trackObject("MediaPlayer", super);
			
			if (mediaMetadata)
			{
				logger.trackObject("ResourceMetadata", mediaMetadata.resourceMetadata);
			}
			
			if (media && media.hasTrait(MediaTraitType.LOAD))
			{
				var loadTrait:NetStreamLoadTrait = media.getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
				if (loadTrait)
				{
					var netStream:NetStream = loadTrait.netStream;
					if (netStream)
					{
						var netStreamInfo:NetStreamInfo = netStream.info;
						logger.trackObject("NetStream", netStream);
						
						logger.qos.currentTime = netStream.time;
						logger.qos.buffer.length = netStream.bufferLength;
						logger.qos.buffer.time = netStream.bufferTime;
						logger.qos.buffer.percentage = netStream.bufferLength / netStream.bufferTime * 100;
						
						if (netStreamInfo)
						{
							logger.trackObject("NetStreamInfo", netStreamInfo);
							logger.qos.droppedFrames = netStreamInfo.droppedFrames;
						}
						
						if (netStream.multicastInfo)
						{
							logger.trackObject("NetStreamMulticastInfo", netStream.multicastInfo);
						}
						
//						for (var i:int = 0; i < netStream.peerStreams.length; i++)
//						{
//							logger.trackObject("NetStreamPeerStream - " + i, netStream.peerStreams[i]);
//						}
						
						
					}
					
					CONFIG::FLASH_10_1
					{
						var netGroup:NetGroup = loadTrait.netGroup;					
						if (netGroup)
						{
							var netGroupInfo:NetGroupInfo = netGroup.info;					
							logger.trackObject("NetGroup", netGroup);
							logger.trackObject("NetGroupInfo", netGroupInfo);
						}
					}
				}
			}
		}
	
		private function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void
		{	
			// Computes Buffering QoS stats.
			if (event.state == MediaPlayerState.PLAYING)
			{
				logger.qos.buffer.eventCount++;
				var now:Number = new Date().time;			
				logger.qos.buffer.previousWaitDuration = now - bufferingStartTimestamp;
				logger.qos.buffer.totalWaitDuration += logger.qos.buffer.previousWaitDuration;
				logger.qos.buffer.avgWaitDuration = logger.qos.buffer.totalWaitDuration / logger.qos.buffer.eventCount;
				logger.qos.buffer.maxWaitDuration = Math.max(logger.qos.buffer.maxWaitDuration, logger.qos.buffer.previousWaitDuration);
				
				bufferingStartTimestamp = NaN;
			}
			if (event.state == MediaPlayerState.BUFFERING)
			{	
				bufferingStartTimestamp = new Date().time;	
			}			
		}
		
		/**
		 * Updates the Rendering and DynamicStreaming QoS indicators. 
		 */ 
		private function onMediaSizeChange(event:DisplayObjectEvent):void
		{		
			width = event.newWidth;
			height = event.newHeight;
			logger.qos.rendering.width = event.newWidth;
			logger.qos.rendering.height = event.newHeight;
			logger.qos.rendering.aspectRatio = width / height;
			logger.qos.ds.currentVerticalResolution = height;
			var lightweightVideoElement:LightweightVideoElement = MediaElementUtils.getMediaElementParentOfType(media, LightweightVideoElement) as LightweightVideoElement;
			if (lightweightVideoElement != null)
			{
				logger.qos.rendering.HD = event.newHeight > highQualityThreshold;
				logger.qos.rendering.smoothing = lightweightVideoElement.smoothing;
				logger.qos.rendering.deblocking = lightweightVideoElement.deblocking == 0 ? "Lets the video compressor apply the deblocking filter as needed." : "Does not use a deblocking filter";
				
				if (isDynamicStream)
				{
					logger.qos.ds.index = currentDynamicStreamIndex;
					logger.qos.ds.numDynamicStreams = numDynamicStreams;
					logger.qos.ds.currentBitrate = getBitrateForDynamicStreamIndex(currentDynamicStreamIndex);
				}
			}			
		}

		
		private const SAMPLING_TIMEOUT:int = 2000;
		
		private var bufferingStartTimestamp:Number;
		
		private var width:Number;
		private var height:Number;	

		
		private var debugTimer:Timer;
	}
}