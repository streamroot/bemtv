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
 **********************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.utils.Timer;
	
	import org.osmf.events.BufferEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.TimeTrait;

	public class BufferingOverlay extends Widget
	{
		public function BufferingOverlay()
		{
			visibilityTimer = new Timer(VISIBILITY_DELAY, 1);
			visibilityTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onVisibilityTimerComplete);
			
			super();
			
			mouseEnabled = false;
			mouseChildren = false;
			
			face = AssetIDs.BUFFERING_OVERLAY;
			_visible = super.visible;
		}
		
		// Overrides
		//
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);
			
			updateState();
		}
		
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void
		{
			bufferable = element.getTrait(MediaTraitType.BUFFER) as BufferTrait;
			bufferable.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, updateState);
			bufferable.addEventListener(BufferEvent.BUFFERING_CHANGE, updateState);
			
			playable = element.getTrait(MediaTraitType.PLAY) as PlayTrait;
			playable.addEventListener(PlayEvent.PLAY_STATE_CHANGE, updateState);
			
			timeTrait = element.getTrait(MediaTraitType.TIME) as TimeTrait;
			
			updateState();
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{
			if (bufferable != null)
			{
				bufferable.removeEventListener(BufferEvent.BUFFER_TIME_CHANGE, updateState);
				bufferable.removeEventListener(BufferEvent.BUFFERING_CHANGE, updateState);
				bufferable = null;
			}
			
			if (playable != null)
			{
				playable.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, updateState);
				playable = null;
			}
			
			if (timeTrait != null)
			{
				timeTrait = null;
			}
			
			updateState();
		}
		
		override public function measure(deep:Boolean=true):void
		{
			var child:DisplayObject = getChildAt(0);
			if (child)
			{
				child.scaleX = child.scaleY = 1;
			}
			
			scaleX = scaleY = 1;
			super.measure(deep);
		}
		
		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean=true):void
		{
			var child:DisplayObject = getChildAt(0);
			if (child)
			{
				child.scaleX = child.scaleY = 1;
			}
			
			scaleX = scaleY = 1;
			super.layout(availableWidth, availableHeight, deep);
		}
		
		override public function set visible(value:Boolean):void
		{
			if (value != _visible)
			{
				_visible = value;
				
				if (value == false)
				{
					visibilityTimer.stop();
					super.visible = false;
				}
				else
				{
					if (visibilityTimer.running)
					{
						visibilityTimer.stop();
					}
					visibilityTimer.reset();
					visibilityTimer.start();
				}
			}
		}
		
		override public function get visible():Boolean
		{
			return _visible;
		}
		
		// Internals
		//
		
		private function updateState(event:Event = null):void
		{
			// Show the overlay only if both the bufferable and playtrait are present,
			// and buffering is taking place while playing back.
			visible
				= (bufferable == null || playable == null) 
					? 	false
					: 	(	bufferable.buffering
						&&	(playable.playState == PlayState.PLAYING)
						);
		}
		
		private function onVisibilityTimerComplete(event:TimerEvent):void
		{
			super.visible = true;
			
			// WORKARROUND: for https://bugs.adobe.com/jira/browse/FM-1146
			workarroundTimer = new Timer(VISIBILITY_DELAY)
			visibleWorkarroundTimestamp = timeTrait.currentTime;
			workarroundTimer.addEventListener(TimerEvent.TIMER, workarrounHandler);			
		}
		
		// WORKARROUND: for https://bugs.adobe.com/jira/browse/FM-1146
		private function workarrounHandler(event:Event):void
		{
			if (timeTrait && timeTrait.currentTime != visibleWorkarroundTimestamp)
			{
				super.visible = false;
				workarroundTimer.stop();
				workarroundTimer = null;
			}
		}		
		private var workarroundTimer:Timer;		
		private var visibleWorkarroundTimestamp:Number;
	
		
		private var bufferable:BufferTrait;
		private var playable:PlayTrait;
		private var timeTrait:TimeTrait;
		
		private var _visible:Boolean;
		private var visibilityTimer:Timer;
		
		/* static */
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.BUFFER;
		_requiredTraits[1] = MediaTraitType.PLAY;
		_requiredTraits[2] = MediaTraitType.TIME;
		
		private static const VISIBILITY_DELAY:int = 1000;
	}
}