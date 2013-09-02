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

package org.osmf.youtube.traits
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.events.PlayEvent;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.youtube.YouTubePlayerProxy;
	import org.osmf.youtube.YouTubeUtils;
	
	/**
	 * YouTubePlayTrait defines the PlayTrait interface for YouTube media.
	 *
	 * @see org.osmf.traits.PlayTrait
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class YouTubePlayTrait extends PlayTrait
	{
		
		/**
		 * Constructor.
		 *
		 * @param playerReference Reference to YouTubePlayer
		 */
		public function YouTubePlayTrait(playerReference:YouTubePlayerProxy)
		{
			player = playerReference;
			player.addEventListener("onStateChange", onYouTubeStateChange, false, 0, true);
			super();
		}

		override public function get playState():String
		{		
			var playerState:String = YouTubeUtils.getOSMFState(player.getPlayerState());
			return playerState;
		}
		/**
		 * YouTube specific implementation of state changes. Uses the YouTube API
		 * in order to play/pause/stop the media.
		 *
		 * @param newPlayState
		 */
		override protected function playStateChangeStart(newPlayState:String):void
		{			
			var youtubeState:int = player.getPlayerState();		
			var playerState:String = YouTubeUtils.getOSMFState(youtubeState);		
			switch (newPlayState)
			{
				case PlayState.PAUSED:
					if (playerState != PlayState.PAUSED)
					{
						player.pauseVideo();						
					}
					break;
				case PlayState.PLAYING:
					if (playerState != PlayState.PLAYING)
					{
						player.playVideo();
					}
					break;
			}
		}

		/**
		 * YouTube player handler for state changes. Handles YouTube state changes
		 * and dispatches OSMF compatible state change events.
		 *
		 * @param event YouTube event.
		 */
		private function onYouTubeStateChange(event:Event):void
		{
			var youtubeState:int = event["data"];			
			if (youtubeState == -1)
			{
				// Handle click on the YouTube logo. 
				// Ignore the first initialize state change event.
				if (initialized)
				{
					pause();					
				}
				initialized = true;
			}
			else
			{
				var playerState:String = YouTubeUtils.getOSMFState(youtubeState);
				
				if (playerState)
				{
					if (youtubeState < 3)
					{
						dispatchEvent(new PlayEvent(PlayEvent.PLAY_STATE_CHANGE, false, false, playerState))
					}
					
				}
			}
		}
		
		private var initialized:Boolean = false;
		private var player:YouTubePlayerProxy;
	}
}