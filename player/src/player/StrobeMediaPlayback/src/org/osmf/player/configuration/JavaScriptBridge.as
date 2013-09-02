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

package org.osmf.player.configuration
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.*;
	
	import org.osmf.events.*;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.player.media.StrobeMediaPlayer;
	
	/**
	 * This class is responsible for exposing the MediaPlayer API to javascript.
	 *
	 */ 
	public class JavaScriptBridge
	{	
		// Constructor
		//
		public static function call(args:Array, async:Boolean = true):void
		{		
			if (async)
			{
				var asyncTimer:Timer = new Timer(10, 1);	
				asyncTimer.addEventListener(TimerEvent.TIMER, 
					function(event:Event):void
					{
						asyncTimer.removeEventListener(TimerEvent.TIMER, arguments.callee);
						ExternalInterface.call.apply(ExternalInterface, args);
					}
				);	
				asyncTimer.start();
			}
			else
			{
				ExternalInterface.call.apply(ExternalInterface, args);
			}
		}
		
		public static function error(event:MediaErrorEvent):void
		{
			// HTML5 Video API error codes.
			var MEDIA_ERR_ABORTED:int = 1;
			var MEDIA_ERR_NETWORK:int = 2;
			var MEDIA_ERR_DECODE:int = 3;
			var MEDIA_ERR_SRC_NOT_SUPPORTED:int = 4;
			
			var _error:Object = {};
			switch (event.error.errorID){				
				// Network errors:
				case MediaErrorCodes.IO_ERROR:
				case MediaErrorCodes.SECURITY_ERROR:
				case MediaErrorCodes.ASYNC_ERROR:
				case MediaErrorCodes.HTTP_GET_FAILED:
				case MediaErrorCodes.NETCONNECTION_REJECTED:
				case MediaErrorCodes.NETCONNECTION_APPLICATION_INVALID:
				case MediaErrorCodes.NETCONNECTION_TIMEOUT:
				case MediaErrorCodes.NETCONNECTION_FAILED:
				case MediaErrorCodes.DVRCAST_SUBSCRIBE_FAILED:
				case MediaErrorCodes.DVRCAST_STREAM_INFO_RETRIEVAL_FAILED:
					_error.code = 2;
					break;
				
				default:
					_error.code = 4;
			}	
			call(["org.strobemediaplayback.triggerHandler", ExternalInterface.objectID, "error", {error:_error}]);
		}
		
		public function JavaScriptBridge(strobeMediaPlayback:StrobeMediaPlayback, mediaPlayer:StrobeMediaPlayer, kind:Class, javascriptCallbackFunction:String)
		{
			this.strobeMediaPlayback = strobeMediaPlayback;
			this.mediaPlayer = mediaPlayer;
			this.kind = kind;	
			this.javascriptCallbackFunction = javascriptCallbackFunction;
			if (ExternalInterface.available)
			{
				try
				{
					createJSBridge();
				}
				catch(_:Error)
				{
					trace("allowScriptAccess is set to false. JavaScript API is not enabled.");
				}
			}			
		}
	
		// Internals
		//
		/**
		 * The element has not yet been initialized. All attributes are in their initial states.
		 */
		private const NETWORK_EMPTY:int = 0;
		
		/**
		 * The element's resource selection algorithm is active and has selected a resource, but it is not actually using the network at this time.
		 */ 
		private const NETWORK_IDLE:int = 1;
		
		/**
		 * The user agent is actively trying to download data.
		 */ 
		private const NETWORK_LOADING:int = 2;
		
		/**
		 * The element's resource selection algorithm is active, but it has so not yet found a resource to use.
		 */ 
		private const NETWORK_NO_SOURCE:int = 3;
		
		/**
		 * No information regarding the media resource is available. No data for the current playback position is available. Media elements whose networkState attribute are set to NETWORK_EMPTY are always in the HAVE_NOTHING state.
		 */ 
		private const HAVE_NOTHING:int = 0;
		
		/** 
		 * Enough of the resource has been obtained that the duration of the resource is available. In the case of a video element, the dimensions of the video are also available. The API will no longer raise an exception when seeking. No media data is available for the immediate current playback position. The timed tracks are ready. 
		 * */
		private const HAVE_METADATA:int =  1;		
		
		/** 
		 * Data for the immediate current playback position is available, but either not enough data is available that the user agent could successfully advance the current playback position in the direction of playback at all without immediately reverting to the HAVE_METADATA state, or there is no more data to obtain in the direction of playback. For example, in video this corresponds to the user agent having data from the current frame, but not the next frame; and to when playback has ended. 
		 * */		  
		private const HAVE_CURRENT_DATA:int =  2;		
		
		/**
		 * Data for the immediate current playback position is available, as well as enough data for the user agent to advance the current playback position in the direction of playback at least a little without immediately reverting to the HAVE_METADATA state. For example, in video this corresponds to the user agent having data for at least the current frame and the next frame. The user agent cannot be in this state if playback has ended, as the current playback position can never advance in this case.
		 */ 
		private const HAVE_FUTURE_DATA:int =  3;
		
		/**
		 * All the conditions described for the HAVE_FUTURE_DATA state are met, and, in addition, the user agent estimates that data is being fetched at a rate where the current playback position, if it were to advance at the rate given by the defaultPlaybackRate attribute, would not overtake the available data before playback reaches the end of the media resource.
		 */
		private const HAVE_ENOUGH_DATA:int =  4;
		
		
		private var mediaPlayer:StrobeMediaPlayer; 
		private var kind:Class;
		private var strobeMediaPlayback:StrobeMediaPlayback;
		private var eventTypeListeners:Object = {};
		private var eventMaps:Dictionary; 
		private var javascriptCallbackFunction:String;
		
		private function createJSBridge():void
		{	
			// Add callback methods
			ExternalInterface.addCallback("addEventListener", addEventListener);
			ExternalInterface.addCallback("addEventListeners", addEventListeners);
			ExternalInterface.addCallback("setMediaResourceURL", setMediaResourceURL);		
			
			var typeXml:XML = describeType(kind);
			
			var declaredByWhiteList:Array = ["org.osmf.media::MediaPlayer", "org.osmf.player.media::StrobeMediaPlayer"];
			var typeBlackList:Array = ["org.osmf.media::MediaElement"];
			// Walk all the variables...
			for each (var variable:XML in typeXml.factory.variable)
			{			
				exposeProperty(mediaPlayer, variable.@name.toString(), false);
			}	
			
			// ...and all the accessors...
			for each (var accessor:XML in typeXml.factory.accessor)
			{
				if (declaredByWhiteList.indexOf(accessor.@declaredBy.toString()) >= 0)
				{
					if (typeBlackList.indexOf(accessor.@type.toString()) < 0)
					{					
						exposeProperty(mediaPlayer, accessor.@name.toString(), accessor.@access == "readonly");
					}					
				}
			}
			
			// ...and all the methods.
			for each (var method:XML in typeXml.factory.method)
			{
				if (declaredByWhiteList.indexOf(method.@declaredBy.toString()) >= 0)
				{
					var methodName:String = method.@name.toString();
					if (typeBlackList.indexOf(method.@returnType.toString()) < 0)					
					{
						var ok:Boolean = true;
						for each(var param:XML in method.parameter)
						{
							if (!param.@optional && typeBlackList.indexOf(param.@type.toString()) >= 0)
							{
								ok = false;
								break;
							}
						}
						if (ok)
						{
							if (methodName != "play" && methodName != "stop")
							{
								ExternalInterface.addCallback(methodName, mediaPlayer[methodName]);
							}
						}
					}
				}
			}
			
			initializeEventMap();			
			
			// We are ready, notify the javascript client.
			
			mediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
			mediaPlayer.addEventListener(AudioEvent.MUTED_CHANGE, onVolumeChange);
			mediaPlayer.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
			mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
			mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
			mediaPlayer.addEventListener(TimeEvent.COMPLETE, onComplete);
			mediaPlayer.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
			mediaPlayer.addEventListener(LoadEvent.BYTES_LOADED_CHANGE, onBytesLoadedChange);
			mediaPlayer.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
			
			exposeProperty(strobeMediaPlayback.configuration, "src", false);
			exposeProperty(strobeMediaPlayback, "error", true);
			ExternalInterface.addCallback("setCurrentTime", mediaPlayer.seek);
			ExternalInterface.addCallback("play2", mediaPlayer.play);
			ExternalInterface.addCallback("stop2", mediaPlayer.stop);
			ExternalInterface.addCallback("load", load);
			call([javascriptCallbackFunction, ExternalInterface.objectID, "onJavaScriptBridgeCreated"], false);
			
//			var javascriptObjectName:String = "javascriptObjectName";
//			call(["$javascriptObjectName.triggerHandler('loadstart')", ExternalInterface.objectID]);
//			call(["$javascriptObjectName.trigger('timeupdate')", ExternalInterface.objectID]);
//			call(["$javascriptObjectName.triggerHandler('loadstart')", ExternalInterface.objectID]);
		}
		
		private function setMediaResourceURL(url:String):void
		{			
			strobeMediaPlayback.configuration.src = url;
			load();
		}
		
		private function load():void
		{
			strobeMediaPlayback.removePoster();
			strobeMediaPlayback.loadMedia();		
		}
		
		private function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void
		{
			if (event.state == MediaPlayerState.READY)
			{
				//call(["org.strobemediaplayback.proxied["+ExternalInterface.objectID+"].update",{"duration":30, "paused":false},["play"]]);
				call([javascriptCallbackFunction, ExternalInterface.objectID, "emptied", {networkState:NETWORK_EMPTY, ended: false, error:null, readyState: HAVE_NOTHING, paused: false, seeking: false, duration: NaN, src: strobeMediaPlayback.configuration.src}]);
			}
			if (event.state == MediaPlayerState.LOADING)
			{
				//call(["org.strobemediaplayback.proxied["+ExternalInterface.objectID+"].update",{"duration":30, "paused":false},["play"]]);
				call([javascriptCallbackFunction, ExternalInterface.objectID, "loadstart", {networkState:NETWORK_LOADING, currentSrc:mediaPlayer.currentSrc}]);
			}
			if (event.state == MediaPlayerState.PLAYING)
			{
				//call(["org.strobemediaplayback.proxied["+ExternalInterface.objectID+"].update",{"duration":30, "paused":false},["play"]]);
				call([javascriptCallbackFunction, ExternalInterface.objectID, "play", {paused:false, ended: false, error:null}]);
			}
			if (event.state == MediaPlayerState.PAUSED)
			{
				//call(["org.strobemediaplayback.proxied["+ExternalInterface.objectID+"].update",{"duration":30, "paused":true},["pause"]]);
				call([javascriptCallbackFunction, ExternalInterface.objectID, "pause", {paused:true}]);
			}
			if (event.state == MediaPlayerState.BUFFERING)
			{
				call([javascriptCallbackFunction, ExternalInterface.objectID, "waiting", {}]);
			}
		}
		
		private function onMediaSizeChange(event:DisplayObjectEvent):void
		{
			call([javascriptCallbackFunction, ExternalInterface.objectID, "loadedmetadata", {videoWidth: mediaPlayer.videoWidth, videoHeight: mediaPlayer.videoHeight, readyState:HAVE_METADATA}]);
		}
		
		private function onSeekingChange(event:SeekEvent):void
		{
			if (event.seeking)
			{
				call([javascriptCallbackFunction, ExternalInterface.objectID, "seeking", {seeking:true}]);			
			}
			else
			{
				call([javascriptCallbackFunction, ExternalInterface.objectID, "seeked", {seeking:false}]);
			}
		}
		
		private function onVolumeChange(event:AudioEvent):void
		{
			call([javascriptCallbackFunction, ExternalInterface.objectID, "volumechange", {muted: mediaPlayer.muted, volume: mediaPlayer.volume}]);
		}
		
		private function onDurationChange(event:TimeEvent):void
		{
			call([javascriptCallbackFunction, ExternalInterface.objectID, "durationchange", {"duration":mediaPlayer.duration}]);
		}
		
		private function onCurrentTimeChange(event:TimeEvent):void
		{
			call([javascriptCallbackFunction, ExternalInterface.objectID, "timeupdate", {"duration":mediaPlayer.duration, "currentTime":mediaPlayer.currentTime}]);
		}
		
		private function onBytesLoadedChange(event:LoadEvent):void
		{
			var end:Number = mediaPlayer.duration * mediaPlayer.bytesLoaded / mediaPlayer.bytesTotal;		
			var buffered:Object = {
				length:1, 
				_start: [0],
				_end: [end]
			};	
			call([javascriptCallbackFunction, ExternalInterface.objectID, "progress", {buffered:buffered}]);	
		}
		
		private function onComplete(event:TimeEvent):void
		{
			call([javascriptCallbackFunction, ExternalInterface.objectID, "complete", {ended:true}]);
		}
		
		private function initializeEventMap():void
		{
			eventMaps = new Dictionary();
			// Trait Events
			eventMaps[TimeEvent.DURATION_CHANGE]					= function(event:TimeEvent):Array{return [event.time];};	
			eventMaps[TimeEvent.COMPLETE]							= function(event:TimeEvent):Array{return [event.time];};	
			eventMaps[PlayEvent.PLAY_STATE_CHANGE]					= function(event:PlayEvent):Array{return [event.playState];};	
			eventMaps[PlayEvent.CAN_PAUSE_CHANGE]					= function(event:PlayEvent):Array{return [event.canPause];};	
			eventMaps[AudioEvent.VOLUME_CHANGE]						= function(event:AudioEvent):Array{return [event.volume];};	
			eventMaps[AudioEvent.MUTED_CHANGE]						= function(event:AudioEvent):Array{return [event.muted];};
			eventMaps[AudioEvent.PAN_CHANGE]						= function(event:AudioEvent):Array{return [event.pan];};	
			eventMaps[SeekEvent.SEEKING_CHANGE]						= function(event:SeekEvent):Array{return [event.time];};	
			eventMaps[DynamicStreamEvent.SWITCHING_CHANGE] 			= function(event:DynamicStreamEvent):Array{return [event.switching];};	
			eventMaps[DynamicStreamEvent.AUTO_SWITCH_CHANGE] 		= function(event:DynamicStreamEvent):Array{return [event.autoSwitch];};	
			eventMaps[DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE] = function(event:DynamicStreamEvent):Array{return [];}; // numDynamicStreams property missing on event
			eventMaps[DisplayObjectEvent.DISPLAY_OBJECT_CHANGE]		= function(event:DisplayObjectEvent):Array{return [];};	
			eventMaps[DisplayObjectEvent.MEDIA_SIZE_CHANGE] 		= function(event:DisplayObjectEvent):Array{return [event.newWidth, event.newHeight];};	
			eventMaps[LoadEvent.LOAD_STATE_CHANGE]					= function(event:LoadEvent):Array{return [event.loadState];};	
			eventMaps[LoadEvent.BYTES_LOADED_CHANGE]				= function(event:LoadEvent):Array{return [event.bytes];};	
			eventMaps[LoadEvent.BYTES_TOTAL_CHANGE]					= function(event:LoadEvent):Array{return [event.bytes];};	
			eventMaps[BufferEvent.BUFFERING_CHANGE]					= function(event:BufferEvent):Array{return [event.buffering];};
			eventMaps[BufferEvent.BUFFER_TIME_CHANGE]				= function(event:BufferEvent):Array{return [event.bufferTime];};
			eventMaps[DRMEvent.DRM_STATE_CHANGE]					= function(event:DRMEvent):Array{return [event.drmState];};
			eventMaps[DVREvent.IS_RECORDING_CHANGE]					= function(event:DVREvent):Array{return [];};// isRecording property missing on event	
			
			// MediaPlayerCapabilityChangeEvent(s)
			eventMaps[MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE]					= function(event:MediaPlayerCapabilityChangeEvent):Array{return [event.enabled];};
			eventMaps[MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE]					= function(event:MediaPlayerCapabilityChangeEvent):Array{return [event.enabled];};
			eventMaps[MediaPlayerCapabilityChangeEvent.TEMPORAL_CHANGE]					= function(event:MediaPlayerCapabilityChangeEvent):Array{return [event.enabled];};
			eventMaps[MediaPlayerCapabilityChangeEvent.HAS_AUDIO_CHANGE]					= function(event:MediaPlayerCapabilityChangeEvent):Array{return [event.enabled];};
			eventMaps[MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE]					= function(event:MediaPlayerCapabilityChangeEvent):Array{return [event.enabled];};
			eventMaps[MediaPlayerCapabilityChangeEvent.CAN_BUFFER_CHANGE]					= function(event:MediaPlayerCapabilityChangeEvent):Array{return [event.enabled];};
			eventMaps[MediaPlayerCapabilityChangeEvent.HAS_DISPLAY_OBJECT_CHANGE]					= function(event:MediaPlayerCapabilityChangeEvent):Array{return [event.enabled];};
			
			// MediaPlayer events
			eventMaps[MediaErrorEvent.MEDIA_ERROR]					= function(event:MediaErrorEvent):Array{return [event.error.errorID, event.error.message, event.error.detail];};
			eventMaps[TimeEvent.CURRENT_TIME_CHANGE]					= function(event:TimeEvent):Array{return [event.time];};
			eventMaps[MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE]					= function(event:MediaPlayerStateChangeEvent):Array{return [event.state];};		
		}
				
		private function addEventListener(type:String, callback:String):void
		{
			if (eventMaps.hasOwnProperty(type))
			{
				mediaPlayer.addEventListener(type,
					function(event:Event):void
					{						
						var args:Array = eventMaps[event.type](event);
						args.unshift(callback);
						args.push(ExternalInterface.objectID);
						call(args);
					}
				);
			}
		}
	
		private function addEventListeners(typeListenerMapping:Object):void
		{
			for (var type:String in typeListenerMapping)
			{
				addEventListener(type, typeListenerMapping[type]);
			}
		}

		private function exposeProperty(instance:Object, propertyName:String, readOnly:Boolean):void
		{
			var capitalizedPropertyName:String = propertyName.charAt(0).toUpperCase() + propertyName.substring(1);
			var getPropertyName:String = "get" + capitalizedPropertyName;
			ExternalInterface.addCallback(getPropertyName, function():*{return instance[propertyName]});
			
			if (!readOnly)
			{
				var setPropertyName:String = "set" + capitalizedPropertyName
				ExternalInterface.addCallback(setPropertyName, function(value:*):void{instance[propertyName] = value});
			}
		}
	}
}