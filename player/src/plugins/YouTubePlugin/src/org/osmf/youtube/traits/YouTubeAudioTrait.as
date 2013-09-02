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
	import org.osmf.traits.AudioTrait;
	import org.osmf.youtube.YouTubePlayerProxy;

	/**
	 * This class wraps an AudioTrait around the YouTube chromeless player.
	 *
	 * @see org.osmf.traits.AudioTrait
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class YouTubeAudioTrait extends AudioTrait
	{

		/**
		 * Constructor.
		 *
		 * @param playerReference Reference to the YouTube chromeless player
		 */
		public function YouTubeAudioTrait(playerReference:YouTubePlayerProxy)
		{
			player = playerReference;
			super();
		}


		/**
		 * The muted state
		 * <p>Uses YouTube's API in order to get/set the muted state.</p>
		 *
		 * @return True if muted, false otherwise.
		 */
		override public function get muted():Boolean
		{
			return player.isMuted();
		}


		/**
		 * The volume level
		 * <p>Uses YouTube's API in order to get the volume level.</p>
		 *
		 * @return Volume level.
		 */
		override public function get volume():Number
		{
			return player.getVolume()/100;
		}

		/**
		 * Actually mute/unmute the chromeless player on trait state change.
		 * 
		 */
		override protected function mutedChangeStart(newMuted:Boolean):void
		{
			newMuted ? player.mute() : player.unMute();
		}

		/**
		 * Actually change the volume on the chromeless player, based on trait's volume.
		 *
		 * @param newVolume
		 */
		override protected function volumeChangeStart(newVolume:Number):void
		{
			player.setVolume(newVolume*100);
		}

		/**
		 * reference to YouTube player
		 *
		 */
		private var player:YouTubePlayerProxy;
	}
}