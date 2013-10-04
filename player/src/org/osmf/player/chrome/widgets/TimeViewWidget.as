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
	
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.StreamType;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.metadata.ChromeMetadata;
	import org.osmf.player.chrome.utils.FormatUtils;
	import org.osmf.player.media.StrobeMediaPlayer;
	import org.osmf.player.metadata.MediaMetadata;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;

	/**
	 * TimeViewWidget displays the current time and the total duration of the media.
	 * 
	 */ 
	public class TimeViewWidget extends Widget
	{
		/**
		 * Returns the current textual represention of the time displayed by the TimeViewWidget.
		 */
		internal function get text():String
		{
			return 	currentTimeLabel.text 
				+ (timeSeparatorLabel.visible ? timeSeparatorLabel.text : "") 
				+ (totalTimeLabel.visible ? totalTimeLabel.text : "");
		}
		
		/**
		 * Updates the displayed text based on the existing traits.
		 */ 
		internal function updateNow():void
		{
			var timeTrait:TimeTrait;
			timeTrait = media.getTrait(MediaTraitType.TIME) as TimeTrait;			
			updateValues(timeTrait.currentTime, timeTrait.duration, live);
		}
		
		/**
		 * Updates the displayed text using the time values provided as arguments.
		 */ 
		internal function updateValues(currentTimePosition:Number, totalDuration:Number, isLive:Boolean):void
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
					// WORKARROUND: adding additional spaces since I'm not able to position the text nicely
					currentTimeLabel.text = LIVE + "   ";					
					currentTimeLabel.autoSize = false;
					currentTimeLabel.width = currentTimeLabel.measuredWidth;
					currentTimeLabel.align = TextFormatAlign.RIGHT;
				}
				if (currentTimePosition > 0 || isLive)
				{
					totalTimeLabel.visible = false;
					timeSeparatorLabel.visible = false;
				}
			}
			else
			{				
				totalTimeLabel.visible = true;
				timeSeparatorLabel.visible = true;				
				
				var newValues:Vector.<String> = FormatUtils.formatTimeStatus(currentTimePosition, totalDuration, isLive, LIVE);
				
				// WORKARROUND: adding additional spaces since I'm unable to position the text nicely
				var currentTimeString:String = " " + newValues[0] + " ";
				var totalTimeString:String = " " + newValues[1] + " ";
				
				var measuredWidth:Number  = totalTimeLabel.measuredWidth;
				totalTimeLabel.text = totalTimeString;
				// Fix for (ST-306) The current time is shown very close to the slash from the total time, almost overlapping
				if (totalTimeLabel.measuredWidth != measuredWidth || (!isLive && currentTimeLabel.text.indexOf(LIVE)>=0))
				{
					currentTimeLabel.autoSize = true;
				}
				currentTimeLabel.text = currentTimeString;
				if (currentTimeLabel.autoSize)
				{
					currentTimeLabel.autoSize = false;
					currentTimeLabel.width = Math.max(currentTimeLabel.measuredWidth, totalTimeLabel.measuredWidth);					
				}				
			}
		}
		
		// Overrides
		//
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{		
			setSuperVisible(false);
			layoutMetadata.percentHeight = 100;
			layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			
			// Current time
			currentTimeLabel = new LabelWidget();			
			currentTimeLabel.autoSize = true;
			currentTimeLabel.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			currentTimeLabel.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;			
			addChildWidget(currentTimeLabel);
			
			// Separator
			timeSeparatorLabel = new LabelWidget();			
			timeSeparatorLabel.autoSize = true;
			timeSeparatorLabel.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			timeSeparatorLabel.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			addChildWidget(timeSeparatorLabel);
			
			// Duration
			totalTimeLabel = new LabelWidget();
			totalTimeLabel.autoSize = true;
			totalTimeLabel.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			totalTimeLabel.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			addChildWidget(totalTimeLabel);
			
			currentTimeLabel.configure(xml, assetManager);
			totalTimeLabel.configure(xml, assetManager);
			timeSeparatorLabel.configure(xml, assetManager);
			
			super.configure(xml, assetManager);	
			
			currentTimeLabel.text = TIME_ZERO;
			timeSeparatorLabel.text = "/";
			totalTimeLabel.text = TIME_ZERO;
			measure();
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void
		{
			timer.addEventListener(TimerEvent.TIMER, onTimerEvent);
			timer.start();				
			setSuperVisible(true);
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{		
			timer.stop();
			setSuperVisible(false);
		}
		
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
			
		override protected function onMediaElementTraitAdd(event:MediaElementEvent):void
		{
			currentTimeLabel.autoSize = true;
			if (event.traitType == MediaTraitType.SEEK)
			{
				seekTrait = media.getTrait(MediaTraitType.SEEK) as SeekTrait;
				seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
			}
		}
		
		override protected function onMediaElementTraitRemove(event:MediaElementEvent):void
		{	
			if (event.traitType == MediaTraitType.SEEK && seekTrait != null)
			{
				seekTrait.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
				seekTrait = null;				
			}
		}

		// Internals
		//
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.TIME;
		private static const LIVE:String = "Live";
		private static const TIME_ZERO:String = " 0:00 ";
		
		private var currentTimeLabel:LabelWidget;
		private var timeSeparatorLabel:LabelWidget;
		private var totalTimeLabel:LabelWidget;	
		
		private var seekTrait:SeekTrait;
		private var timer:Timer = new Timer(1000);
		private var maxLength:uint = 0;
		private var maxWidth:Number = 100;
		
		private function get live():Boolean
		{
			var mp:StrobeMediaPlayer = mediaPlayer;
			return mp ? mp.isLive : false;
		}
		
		private function get mediaPlayer():StrobeMediaPlayer
		{
			var mediaMetadata:MediaMetadata;
			mediaMetadata = media.metadata.getValue(MediaMetadata.ID) as MediaMetadata;
			if (mediaMetadata != null)
			{
				var mediaPlayer:StrobeMediaPlayer;
				mediaPlayer = mediaMetadata.mediaPlayer;
				return mediaPlayer;
			}
			return null;
		}
		
		private function onTimerEvent(event:Event):void
		{
			updateNow();
		}
		
		private function onSeekingChange(event:SeekEvent):void
		{
			currentTimeLabel.autoSize = true;
			var timeTrait:TimeTrait;
			timeTrait = media.getTrait(MediaTraitType.TIME) as TimeTrait;			
			
			if (event.seeking)
			{
				updateValues(event.time, timeTrait.duration, live);
				timer.stop();				
			}
			else
			{
				updateValues(event.time, timeTrait.duration, live);
				timer.start();
			}
		}	
	}
}