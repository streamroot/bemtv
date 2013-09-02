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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;

	public class PlayButtonOverlay extends PlayableButton
	{
		// Public API
		//
		
		public function PlayButtonOverlay()
		{
			visibilityTimer = new Timer(VISIBILITY_DELAY, 1);
			visibilityTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onVisibilityTimerComplete);
			
			super();
			
			upFace = AssetIDs.PLAY_BUTTON_OVERLAY_NORMAL;
			downFace = AssetIDs.PLAY_BUTTON_OVERLAY_DOWN;
			overFace = AssetIDs.PLAY_BUTTON_OVERLAY_OVER;
		}
		
		// Overrides
		//
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);
			
			// Make sure that the overlay is toggle invisible intially:
			visible = false;
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
					if (parent)
					{
						visibilityTimer.reset();
						visibilityTimer.start();
					}
					else
					{
						super.visible = true;
					}
				}
			}
		}
		
		override public function get visible():Boolean
		{
			return _visible;
		}
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			var playable:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
			playable.play();
		}
		
		override protected function visibilityDeterminingEventHandler(event:Event = null):void
		{
			var newVisibleValue:Boolean = playable && playable.playState == PlayState.STOPPED;
			if (newVisibleValue)
			{
				// Only show the play button overlay when we're at the beginning
				// of the content, or at the end of the content:
				var time:TimeTrait = media.getTrait(MediaTraitType.TIME) as TimeTrait;
				if (time)
				{
					newVisibleValue
						=	time.currentTime == 0
						||	Math.abs(time.currentTime - time.duration) < 2;
				}
			}
			
			visible = newVisibleValue;
		}
		
		// Internals
		//
		
		private function onVisibilityTimerComplete(event:TimerEvent):void
		{
			super.visible = true;	
		}
		
		private var _visible:Boolean = true;
		private var visibilityTimer:Timer;
		
		/* static */
		private static const VISIBILITY_DELAY:int = 500;
	}
}