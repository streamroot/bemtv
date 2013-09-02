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

	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.youtube.YouTubePlayerProxy;
	import org.osmf.youtube.YouTubeUtils;

	/**
	 * The YouTubeDynamicStreamTrait class extends DynamicStreamTrait for YouTube-based
	 * quality levels dynamic streaming.
	 *
	 * @see org.osmf.traits.DynamicStreamTrait
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 *
	 */
	public class YouTubeDynamicStreamTrait extends DynamicStreamTrait
	{

		/**
		 * Constructor.
		 *
		 * @param playerReference The reference to YouTube Chromeless Player
		 * @param autoSwitch The initial autoSwitch state for the trait.  The default is true.
		 * @param currentIndex The initial stream index for the trait.  The default is zero.
		 */
		public function YouTubeDynamicStreamTrait(playerReference:YouTubePlayerProxy, autoSwitch:Boolean=true, currentIndex:int=0)
		{
			player = playerReference;
			player.addEventListener("onStateChange", onYouTubeStateChange);
			player.addEventListener("onPlaybackQualityChange", onYouTubeQualityChange);

			youTubeQualityLevels = player.getAvailableQualityLevels();
			setNumDynamicStreams(youTubeQualityLevels.length);
			
			super(autoSwitch, currentIndex, numDynamicStreams);
		}

		// Overrides
		//

		/**
		 * The index of the current dynamic stream.  Uses a zero-based index.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override public function get currentIndex():int
		{
			return youTubeQualityLevels.indexOf(player.getPlaybackQuality());
		}
		
		/**
		 * Called just after the <code>autoSwitch</code> property has changed.
		 * YouTube autoswitch is set here and dispatches the change event.
		 *
		 * <p>The YouTube api call is made here since it is not asynchronous
		 * and if called in autoSwitchChangeStart it might complete before
		 * the <code>autoSwitch<code> property is set.</p>
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override protected function autoSwitchChangeEnd():void
		{
			if (autoSwitch)
			{
				player.setPlaybackQuality("default");
			}
			super.autoSwitchChangeEnd();
		}

		/**
		 * Called just after the <code>switching</code> property has changed.
		 * The YouTube chromeless api is called to do the actual quality change
		 * and then the change event is dispatched.
		 *
		 * <p>The YouTube api call is made here since it is not asynchronous
		 * and if called in autoSwitchChangeStart it might complete before
		 * the <code>autoSwitch<code> property is set</p>
		 *
		 * @param index The index of the switched-to stream.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override protected function switchingChangeEnd(index:int):void
		{
			if (switching)
			{
				//setSwitching(true, youTubeQualityLevels.indexOf(player.getPlaybackQuality()));
				player.setPlaybackQuality(youTubeQualityLevels[index]);
			}
			super.switchingChangeEnd(index);
		}


		/**
		 * Returns the associated bitrate, in kilobits per second, for the specified index.
		 *
		 * Note that for YouTube the bitrates are totally bogus for now!
		 * They are harcoded in YouTubeUtils.QUALITY_MAP and need to be updated
		 * with more realistic values
		 *
		 * @throws RangeError If the specified index is less than zero or
		 * greater than the highest index available.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override public function getBitrateForIndex(index:int):Number
		{
			return YouTubeUtils.getOSMFBitrate(youTubeQualityLevels[index]);
		}

		//Internals
		//

		/**
		 * YouTube player event handler for quality changes.
		 *
		 * <p>YouTube player will fire this event when it has finished switching.
		 * We need to sync the trait status when receiving it.</p>
		 *
		 * @param event YouTube event.
		 */
		private function onYouTubeQualityChange(event:Event):void
		{
			setSwitching(false, youTubeQualityLevels.indexOf(player.getPlaybackQuality()));
		}

		/**
		 * YouTube player state change event handler.
		 *
		 * <p>Need to reload the available quality levels here, since they might not
		 * be available until playback has started. If we have more quality levels than
		 * initially we need to update trait's internals to reflect that.</p>
		 *
		 * @param event YouTube event
		 */
		private function onYouTubeStateChange(event:Event):void
		{
			if (event["data"] == YouTubePlayerProxy.YOUTUBE_STATE_PLAYING)
			{
				youTubeQualityLevels = player.getAvailableQualityLevels();

				if (youTubeQualityLevels.length != numDynamicStreams)   // update only if we have new stuff
				{
					setNumDynamicStreams(youTubeQualityLevels.length);
					maxAllowedIndex = numDynamicStreams -1;
					setCurrentIndex(youTubeQualityLevels.indexOf(player.getPlaybackQuality()));
				}
			}
		}

		/**
		 * The YouTube quality levels.
		 *
		 * <p>The YouTube quality levels are returned by the chromeless API
		 * as an descending array. In order to match OSMF's behavior where lower
		 * indexes mean lower quality we need to reverse the YouTube response! </p>
		 *
		 * @param value The original YouTube quality levels array.
		 */
		private function set youTubeQualityLevels(value:Array):void
		{
			// need to reverse the YouTube quality levels array
			// since is descendent, not ascendent as OSMF's metaphor

			_youTubeQualityLevels = value.reverse();
		}
		private function get youTubeQualityLevels():Array
		{
			return _youTubeQualityLevels;
		}

		private var player:YouTubePlayerProxy;
		private var _youTubeQualityLevels:Array;
	}
}