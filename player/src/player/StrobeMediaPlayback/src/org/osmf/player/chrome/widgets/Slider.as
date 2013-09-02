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
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import flashx.textLayout.formats.VerticalAlign;
	
	import org.osmf.player.chrome.events.ScrubberEvent;

	[Event(name="scrubStart", type="org.osmf.samples.controlbar.ScrubberEvent")]
	[Event(name="scrubUpdate", type="org.osmf.samples.controlbar.ScrubberEvent")]
	[Event(name="scrubEnd", type="org.osmf.samples.controlbar.ScrubberEvent")]
	
	/**
	 * Slider class implements the behaviour of a slider and it is used by both the volume control and ScrubBar.
	 */ 
	public class Slider extends Sprite
	{
		public function Slider(up:DisplayObject, down:DisplayObject, disabled:DisplayObject, over:DisplayObject=null)
		{
			this.up = up;
			this.down = down;
			this.disabled = disabled;
			this.over = over;
			
			scrubTimer = new Timer(UPDATE_INTERVAL);
			scrubTimer.addEventListener(TimerEvent.TIMER, onDraggingTimer);
			
			updateFace(this.up);
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			
			super();
		}
		
		public function get sliding():Boolean
		{
			return _sliding;
		}

		public function set enabled(value:Boolean):void
		{
			if (value != _enabled)
			{
				_enabled = value;
				mouseEnabled = value;
				updateFace(_enabled ? up : disabled);
			}
		}
		
		public function set origin(value:Number):void
		{
			_origin = value;
		}
		public function get origin():Number
		{
			return _origin;
		}
		
		public function set rangeX(value:Number):void
		{
			_rangeX = value;
		}
		public function get rangeX():Number
		{
			return _rangeX;
		}

		public function set rangeY(value:Number):void
		{
			_rangeY = value;
		}
		public function get rangeY():Number
		{
			return _rangeY;
		}
		
		public function start(lockCenter:Boolean = true):void
		{
			if (_enabled && _sliding == false)
			{
				_sliding = true;
				stage.addEventListener(MouseEvent.MOUSE_UP, onStageExitDrag);
				updateFace(down);
				scrubTimer.start();
				dispatchEvent(new ScrubberEvent(ScrubberEvent.SCRUB_START));

				startDrag
					( lockCenter
					, new Rectangle
							( rangeY == 0.0 ? _origin : x
							, rangeX == 0.0 ? _origin : y
							, _rangeX
							, _rangeY
							)
					);
//				INJECTION Change 692020: extracting (height/2) from the Y range fixed ST-204(the slider is allowed to
//					be dragged to far south (the calculations not taking into account the actual height
//					of the scrubber itself))
//				but also caused the (ST-220) Control bar was injected in  build 692020.
//				startDrag
//					( lockCenter
//						, new Rectangle
//						( rangeY == 0 ? _origin : x
//							, rangeX == 0 ? _origin : y
//							, _rangeX
//							, _rangeY - (height/2)
//						)
//					);
			}
		}
		
		public function stop():void
		{
			if (_enabled && _sliding)
			{
				scrubTimer.stop();
				stopDrag();
				updateFace(up);
				_sliding = false;
				
				try
				{
					stage.removeEventListener(MouseEvent.MOUSE_UP, onStageExitDrag);
				}
				catch (e:Error)
				{
					// swallow this, it means that we already removed
					// the event listened in a previous stop() call
				}
				dispatchEvent(new ScrubberEvent(ScrubberEvent.SCRUB_END));

			}
		}
		
		// Overrides
		//
		
		override public function set x(value:Number):void
		{
			if (_sliding == false)
			{
				super.x = value;
			}
		}
		
		override public function set y(value:Number):void
		{
			if (_sliding == false)
			{
				super.y = value;
			}
		}

		
		// Internals
		//
		
		private function updateFace(face:DisplayObject):void
		{
			if (currentFace != face)
			{
				if (currentFace)
				{
					removeChild(currentFace);
				}
				
				currentFace = face;
				
				if (currentFace)
				{
					addChild(currentFace);
				}
			}
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			start(false);
		}
		
		private function onRollOver(event:MouseEvent):void{
			updateFace(this.over);
		}
		
		private function onRollOut(event:MouseEvent):void{
			updateFace(this.up);
		}
		
		private function onStageExitDrag(event:MouseEvent):void
		{
			stop();
		}
		
		private function onDraggingTimer(event:TimerEvent):void
		{
			dispatchEvent(new ScrubberEvent(ScrubberEvent.SCRUB_UPDATE));
		}
		
		private const UPDATE_INTERVAL:int = 40
		private var currentFace:DisplayObject;
		private var up:DisplayObject;
		private var down:DisplayObject;
		private var disabled:DisplayObject;
		private var over:DisplayObject;
		
		private var _enabled:Boolean = true;
		private var _origin:Number = 0.0;
		private var _rangeX:Number = 100.0;
		private var _rangeY:Number = 100.0;
		
		private var _sliding:Boolean;
		private var scrubTimer:Timer;
	}
}