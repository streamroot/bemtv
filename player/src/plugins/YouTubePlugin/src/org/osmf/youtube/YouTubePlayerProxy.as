/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
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
 **********************************************************/


package org.osmf.youtube
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * This event is fired when the player is loaded and initialized, 
	 * meaning it is ready to receive API calls.
	 */	
	[Event(name="onReady",type="flash.events.Event")]
	
	/**
	 * This event is fired when an error in the player occurs. 
	 * The possible error codes are 100, 101, and 150. 
	 * The 100 error code is broadcast when the video requested is not found. 
	 * This occurs when a video has been removed (for any reason), 
	 * or it has been marked as private. 
	 * The 101 error code is broadcast when the video requested does not 
	 * allow playback in the embedded players. 
	 * The error code 150 is the same as 101, it's just 101 in disguise!
	 */ 
	[Event(name="onError",type="flash.events.Event")]

	/**
	 * This event is fired whenever the player's state changes. 
	 * Possible values are unstarted (-1), ended (0), playing (1), paused (2), buffering (3), video cued (5). 
	 * When the SWF is first loaded it will broadcast an unstarted (-1) event. 
	 * When the video is cued and ready to play it will broadcast a video cued event (5).
	 */	
	[Event(name="onStateChange",type="flash.events.Event")]
	
	/**
	 * This event is fired whenever the video playback quality changes. For example, if you call the setPlaybackQuality(suggestedQuality) function, this event will fire if the playback quality actually changes. Your code should respond to the event and should not assume that the quality will automatically change when the setPlaybackQuality(suggestedQuality) function is called. Similarly, your code should not assume that playback quality will only change as a result of an explicit call to setPlaybackQuality or any other function that allows you to set a suggested playback quality.
	 *
	 * The value that the event broadcasts is the new playback quality. Possible values are "small", "medium", "large", "hd720", "hd1080", and "highres"
	 */	
	[Event(name="onPlaybackQualityChange",type="flash.events.Event")]

	/**
	 * Proxy Sprite that wraps the DisplayObject contained within the YouTube
	 * SWF.  This class provides a means of strongly-typing the YouTube API,
	 * as well as isolating our own code from changes to YouTube's API.
	 **/
	public class YouTubePlayerProxy extends Sprite
	{
		/**
		 * Defines the YouTube chromeless player state of ended.
		 *
		 */
		public static const YOUTUBE_STATE_ENDED:int = 0;
		
		/**
		 * Defines the YouTube chromeless player state of playing.
		 *
		 */
		public static const YOUTUBE_STATE_PLAYING:int = 1;
		
		/**
		 * Defines the YouTube chromeless player state of cued (video loaded).
		 *
		 */
		public static const YOUTUBE_STATE_CUED:int = 5;
		
		/**
		 * The YouTube chromeless player url.
		 *
		 */
		public static const CHROMELESS_PLAYER:String = "http://www.youtube.com/apiplayer?version=3";

		public function YouTubePlayerProxy(playerObject:Object)
		{
			player = playerObject;

			this.addChild(player as DisplayObject);
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent);
		}
		
		public function setSize(width:Number, height:Number):void
		{
			player.setSize(width, height);
		}

		public function getDuration():Number
		{
			return player.getDuration();
		}

		public function cueVideoById(id:String, startSeconds:Number = 0, suggestedQuality:String = "default"):void
		{
			player.cueVideoById(id, startSeconds, suggestedQuality);
		}
		
		public function loadVideoById(id:String, startSeconds:Number = 0, suggestedQuality:String = "default"):void
		{
			player.loadVideoById(id, startSeconds, suggestedQuality);
		}


		public function getCurrentTime():Number
		{
			return player.getCurrentTime();
		}

		public function seekTo(time:Number,  allowSeekAhead:Boolean=false):void
		{
			player.seekTo(time, allowSeekAhead);
		}

		public function playVideo():void
		{
			trace(getPlayerState());
			player.playVideo();
		}

		public function pauseVideo():void
		{
			trace(getPlayerState());
			player.pauseVideo();
		}
		
		public function stopVideo():void
		{
			player.stopVideo();
		}

		public function getPlayerState():int
		{
			return player.getPlayerState();
		}

		public function getAvailableQualityLevels():Array
		{
			return player.getAvailableQualityLevels();
		}

		public function setPlaybackQuality(suggestedQualityLevel:String):void
		{
			player.setPlaybackQuality(suggestedQualityLevel);
		}

		public function getPlaybackQuality():String
		{
			return player.getPlaybackQuality();
		}

		public function isMuted():Boolean
		{
			return player.isMuted();
		}
		
		public function getVolume():Number
		{
			return player.getVolume();
		}
		
		public function mute():void
		{
			player.mute();
		}
		
		public function unMute():void
		{
			player.unMute();
		}
		
		public function setVolume(value:Number):void
		{
			player.setVolume(value);
		}
		
		public function getVideoStartBytes():Number
		{
			return player.getVideoStartBytes();
		}
		
		public function getVideoBytesLoaded():Number
		{
			return player.getVideoBytesLoaded();
		}
		
		public function getVideoBytesTotal():Number
		{
			return player.getVideoBytesTotal();
		}
		
		public function destroy():void
		{
			player.destroy();
		}
		// Overrides
		//
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false,
		                                          priority:int = 0, useWeakReference:Boolean = false):void
		{
			player.addEventListener(type, listener, useCapture, priority, useWeakReference);			
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			player.removeEventListener(type, listener, useCapture);
		}

		override public function dispatchEvent(event:Event):Boolean
		{
			return player.dispatchEvent(event);
		}

		override public function get loaderInfo():LoaderInfo
		{
			return player.loaderInfo;
		}

		// Internals
		//
		
		private function onMouseEvent(event:Event):void
		{
			super.dispatchEvent(event);
		}

		private var player:Object;
	}
}