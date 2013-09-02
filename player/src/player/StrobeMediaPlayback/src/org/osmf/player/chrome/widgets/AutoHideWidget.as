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
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import org.osmf.player.chrome.metadata.ChromeMetadata;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.MetadataWatcher;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	public class AutoHideWidget extends Widget
	{
		public function AutoHideWidget()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onFirstAddedToStage);
		}
		
		public function get autoHide():Boolean
		{
			return _autoHide;
		}
		
		public function set autoHide(value:Boolean):void
		{			
			if (_autoHide && !value && _autoHideTimeout>0)
			{
				stopWatchingMouseMoves();
			}
			
			_autoHide = value;
			
			visible = _autoHide ? mouseOver : true;
		}
		
		public function get autoHideTimeout():int
		{
			return _autoHideTimeout;
		}
		
		public function set autoHideTimeout(value:int):void
		{
			_autoHideTimeout = value;			
			visible = _autoHide ? mouseOver : true;
		}		
		
		// Overrides
		//
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
						
			startWatchingMouseMoves();				
		}
		
		private function onFirstAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onFirstAddedToStage);
			 
			
			if (_autoHide && _autoHideTimeout <= 0)
			{
				addEventListener(MouseEvent.MOUSE_OVER, onStageMouseOver);
				addEventListener(MouseEvent.MOUSE_OUT, onStageMouseOut);
			}
			
			if (_autoHide && _autoHideTimeout > 0)
			{
				startWatchingMouseMoves();
			}
		}
		
		private function onStageMouseOver(event:MouseEvent):void
		{
			if (!_autoHide) return;
			
			mouseOver = true;
			stopWatchingMouseMoves();
			visible = _autoHide ? mouseOver : true;			
		}
		
		private function onStageMouseOut(event:MouseEvent):void
		{
			if (!_autoHide) return;		
			mouseOver = false;
			visible = _autoHide ? mouseOver : true;
		}
	
	
		private function startWatchingMouseMoves(event:Event=null):void
		{	
			if (_autoHideTimeout <= 0) return;
			if (stage == null)
			{
				addEventListener(Event.ADDED_TO_STAGE, startWatchingMouseMoves);	
			}
			else
			{
				removeEventListener(Event.ADDED_TO_STAGE, startWatchingMouseMoves);
			}
			
			if (stage != null && _autoHide && _autoHideTimeout > 0 && !mouseOver)
			{
				if (autoHideTimer == null)
				{
					stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);	
					
					autoHideTimer = new Timer(_autoHideTimeout);
					autoHideTimer.addEventListener(TimerEvent.TIMER, onAutoHideTimer);
					autoHideTimer.start();
				}
			}
		}
		
		private function stopWatchingMouseMoves():void
		{
			if (_autoHideTimeout <= 0) return;
			if (stage != null)
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);		
			}
			if (autoHideTimer!=null)
			{
				autoHideTimer.removeEventListener(TimerEvent.TIMER, onAutoHideTimer);
				autoHideTimer.stop();			
				autoHideTimer = null;
			}			
		}
		
		protected function onAutoHideTimer(event:Event):void
		{
			if (_autoHideTimeout<=0) return;
			if (visible)
			{
				visible = false;
				if (stage && stage.displayState != StageDisplayState.NORMAL) 
				{
					Mouse.hide();
				}
			}
		}	
		
		private function onMouseMove(event:Event):void
		{
			if (_autoHideTimeout <= 0) return;
			if (autoHideTimer == null) return;
			autoHideTimer.reset();
			autoHideTimer.start();
			if (!visible)
			{
				visible = true;
				if (stage && stage.displayState != StageDisplayState.NORMAL) 
				{
					Mouse.show();
				}
			}
		}
		
		private var autoHideWatcher:MetadataWatcher;
		private var autoHideTimeoutWatcher:MetadataWatcher;
		private var _autoHide:Boolean;
		private var _autoHideTimeout:int = 3000;
		private var mouseOver:Boolean;
		
		private var autoHideTimer:Timer = null;
	}
}