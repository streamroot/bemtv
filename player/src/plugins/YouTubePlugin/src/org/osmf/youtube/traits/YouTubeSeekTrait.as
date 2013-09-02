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
	
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	import org.osmf.youtube.YouTubePlayerProxy;

	/**
	 * YouTubeSeekTrait defines the trait interface for YouTube media.
	 *
	 * @see org.osmf.traits.AudioTrait
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */

	public class YouTubeSeekTrait extends SeekTrait
	{
		/**
		 * Constructor
		 *
		 * @param timeTrait The TimeTrait this trait is based on.
		 * @param playerReference Reference to YouTube player.
		 */
		public function YouTubeSeekTrait(timeTrait:TimeTrait, playerReference:YouTubePlayerProxy)
		{
			player = playerReference;
			
			super(timeTrait);
		}

		/**
		 * YouTube specific seek implementation
		 *
		 * @param newSeeking
		 * @param time Where to seek in seconds
		 */
		override protected function seekingChangeStart(newSeeking:Boolean, time:Number):void
		{
			if (newSeeking)
			{
				player.addEventListener("onStateChange", onStateChange);
				player.seekTo(time, true);
			}
		}
		
		override public function canSeekTo(time:Number):Boolean
		{
			return time > 0 && time < timeTrait.duration;
		}
		
		private var player:YouTubePlayerProxy;
		
		private function onStateChange(event:Event):void
		{		
			// Check if the player was seeking and revert the seeking state
			if (player.getPlayerState() == YouTubePlayerProxy.YOUTUBE_STATE_PLAYING)
			{			
				if (seeking)
				{
					player.removeEventListener("onStateChange", onStateChange);
					setSeeking(false, player.getCurrentTime());
				}
			}
		}
	}
}