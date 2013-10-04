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
	 * TimeLabelWidget is a shell class meant to be the base class for the current or total time.
	 * 
	 */ 
	public class TimeLabelWidget extends LabelWidget
	{		
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
			timeLabel = new LabelWidget();			
			timeLabel.autoSize = true;
			timeLabel.fontSize = fontSize;
			timeLabel.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			timeLabel.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			addChildWidget(timeLabel);
			
			timeLabel.configure(xml, assetManager);
			
			super.configure(xml, assetManager);	
			
			timeLabel.text = TIME_ZERO;
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
		protected static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.TIME;
		protected static const LIVE:String = "Live";
		protected static const TIME_ZERO:String = " 0:00 ";
		
		protected var timeLabel:LabelWidget;
		
		protected var seekTrait:SeekTrait;
		protected var timer:Timer = new Timer(1000);
		protected var maxLength:uint = 0;
		protected var maxWidth:Number = 100;
		
		protected function get live():Boolean
		{
			var mp:StrobeMediaPlayer = mediaPlayer;
			return mp ? mp.isLive : false;
		}
		
		protected function get mediaPlayer():StrobeMediaPlayer
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
		
		protected function onTimerEvent(event:Event):void
		{
			updateNow();
		}
		
		protected function onSeekingChange(event:SeekEvent):void
		{
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