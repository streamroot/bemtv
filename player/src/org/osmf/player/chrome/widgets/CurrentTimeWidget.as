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

package org.osmf.player.chrome.widgets
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.PerspectiveProjection;
	import flash.media.Microphone;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.StreamType;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.assets.FontAsset;
	import org.osmf.player.chrome.metadata.ChromeMetadata;
	import org.osmf.player.chrome.utils.FormatUtils;
	import org.osmf.player.media.StrobeMediaPlayer;
	import org.osmf.player.metadata.MediaMetadata;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;

	/**
	 * CurrentTimeWidget displays the current time and the total duration of the media.
	 * 
	 */ 
	public class CurrentTimeWidget extends TimeLabelWidget
	{
		
		public var showSeekTime:Boolean = true;
		
		// Overrides
		//
		
		/**
		 * Updates the displayed text using the time values provided as arguments.
		 */ 
		override internal function updateValues(currentTimePosition:Number, totalDuration:Number, isLive:Boolean):void
		{	
			// WORKARROUND: ST-285 CLONE -Multicast live duration
			// Check is the value is over the int range, and turn it into a NaN
			if (totalDuration > int.MAX_VALUE || (mediaPlayer != null && mediaPlayer.streamType == StreamType.LIVE))
			{
				totalDuration = NaN;
			}
			
			// Don't display the time labels if total duration is 0
			if (isNaN(totalDuration) || totalDuration == 0) 
			{	
				if (isLive)
				{
					timeLabel.text = LIVE;			
					timeLabel.autoSize = false;
					timeLabel.width = timeLabel.measuredWidth;
					timeLabel.align = TextFormatAlign.RIGHT;
				}
			}
			else
			{				
				var newValues:Vector.<String> = FormatUtils.formatTimeStatus(currentTimePosition, totalDuration, isLive, LIVE);
				
				// WORKARROUND: adding additional spaces since I'm unable to position the text nicely
				var currentTimeString:String = " " + newValues[0] + " ";
				
				// Fix for (ST-306) The current time is shown very close to the slash from the total time, almost overlapping
				if ((!isLive && timeLabel.text.indexOf(LIVE)>=0))
				{
					timeLabel.autoSize = true;
				}
				timeLabel.text = currentTimeString;
				if (timeLabel.autoSize)
				{
					timeLabel.autoSize = false;
					timeLabel.width = timeLabel.measuredWidth;					
				}				
			}
		}
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{		
			setSuperVisible(false);
			layoutMetadata.percentHeight = 100;
			layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			
			// Current time
			timeLabel = new LabelWidget();
			timeLabel.autoSize = true;
			timeLabel.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			timeLabel.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;			
			addChildWidget(timeLabel);
			
			timeLabel.configure(xml, assetManager);
			
			super.configure(xml, assetManager);	
			
			timeLabel.text = TIME_ZERO;
			measure();
		}
		
		override protected function onMediaElementTraitAdd(event:MediaElementEvent):void
		{
			timeLabel.autoSize = true;
			if (event.traitType == MediaTraitType.SEEK)
			{
				seekTrait = media.getTrait(MediaTraitType.SEEK) as SeekTrait;
				seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
			}
		}
		
		override protected function onSeekingChange(event:SeekEvent):void{
			if(showSeekTime){
				// The timeout is used here to force a "seek end" scenario
				clearTimeout(_seekChangeTimeout);
				_seekChangeTimeout = setTimeout(function():void{
													timeLabel.textFormat = FontAsset(assetManager.getAsset(AssetIDs.DEFAULT_FONT)).format;
												}, 50);
				//reset the textformat to use the bold font
				if(event.seeking) timeLabel.textFormat = FontAsset(assetManager.getAsset(AssetIDs.DEFAULT_FONT_BOLD)).format;
			}
			super.onSeekingChange(event);
		}
		
		private var _seekChangeTimeout:uint;
	}
}