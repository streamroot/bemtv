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
	
	import org.osmf.media.MediaPlayer;
	import org.osmf.traits.TimeTrait;
	import org.osmf.youtube.YouTubePlayerProxy;

	/**
	 * YouTubeTimeTrait defines the TimeTrait interface for YouTube videos
	 *
	 * @see org.osmf.traits.AudioTrait
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class YouTubeTimeTrait extends TimeTrait
	{
		/**
		 * Constructor.
		 *
		 * @param duration The duration of the media.
		 * @param playerReference Reference to YouTube player.
		 */
		public function YouTubeTimeTrait(duration:Number, playerReference:YouTubePlayerProxy)
		{
			player = playerReference;
			player.addEventListener("onStateChange", onStateChange);
			
			super(duration);
		}
		
		private function onStateChange(event:Event):void
		{
			if (duration != player.getDuration())
			{
				setDuration(player.getDuration());
			}
			switch(event["data"])
			{
				case YouTubePlayerProxy.YOUTUBE_STATE_ENDED:
					signalComplete();					
					break;
			}
		}
		
		/**
		 * Retrieves the currentTime using YouTube's API
		 *
		 * @return Current time in seconds
		 */
		override public function get currentTime():Number
		{
			return player.getCurrentTime();
		}

		private var player:YouTubePlayerProxy;
	}
}