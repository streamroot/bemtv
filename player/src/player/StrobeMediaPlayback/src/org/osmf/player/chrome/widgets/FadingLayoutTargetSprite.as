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
	
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.LayoutTargetSprite;
	
	public class FadingLayoutTargetSprite extends LayoutTargetSprite
	{
		// Public Interface
		//
		
		public function FadingLayoutTargetSprite(layoutMetadata:LayoutMetadata=null)
		{
			super(layoutMetadata);
			
			_visible = super.visible;
			_alpha = super.alpha;
		}
		
		public function get fadeSteps():Number
		{
			return _fadeSteps;
		}
		
		public function set fadeSteps(value:Number):void
		{
			if (_fadeSteps != value)
			{
				_fadeSteps = value;
				
				if (_fadeSteps <= 0)
				{
					setIdle();	
				}
				else
				{
					addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				}
			}
		}
		
		// Overrides
		//
		
		override public function set visible(value:Boolean):void
		{
			if (value != _visible)
			{
				_visible = value;
				if (parent)
				{
					mode = _visible
						? MODE_IN
						: MODE_OUT;
				}
				else
				{
					setIdle();
				}
			}
		}
		
		override public function get visible():Boolean
		{
			return _visible;
		}
		
		override public function set alpha(value:Number):void
		{
			if (value != _alpha)
			{
				_alpha = value;
			}
		}
		
		override public function get alpha():Number
		{
			return _alpha;
		}
		
		// Stubs
		//
		
		protected function setSuperVisible(value:Boolean):void
		{
			super.visible = value;
		}
		
		// Internals
		//
		
		private static const MODE_IDLE:String = null;
		private static const MODE_IN:String = "in";
		private static const MODE_OUT:String = "out";
		
		private var _fadeSteps:Number = 0;
		private var _visible:Boolean = true;
		private var _alpha:Number;
		private var _mode:String;
		
		private var remainingSteps:uint = 0;
		
		private function get mode():String
		{
			return _mode;	
		}
		
		private function set mode(value:String):void
		{
			if (value != _mode)
			{
				_mode = value;
				var fadeRequired:Boolean
					= 	_fadeSteps
					&&	(	(	_mode == MODE_OUT
							&&	super.alpha != 0
							&&	super.visible != false
							)
						||	(	_mode == MODE_IN
							&&	super.alpha != _alpha
							)
						);
				
				if (fadeRequired)
				{
					if (remainingSteps <= 0)
					{
						remainingSteps = _fadeSteps;
					}
					else
					{
						remainingSteps = _fadeSteps - remainingSteps;
					}
					addEventListener(Event.ENTER_FRAME, onEnterFrame);
					onEnterFrame();
				}
				else
				{
					setIdle();
				}	
			}
		}
		
		private function setIdle():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);		
			_mode = MODE_IDLE;
			remainingSteps = 0;
			super.alpha = _visible ? _alpha : 0;
			setSuperVisible(_visible);
		}
		
		private function onAddedToStage(event:Event):void
		{
			if (visible)
			{
				super.alpha = 0;
				mode = MODE_IN;
			}
		}
		
		private function onEnterFrame(event:Event = null):void
		{
			if (remainingSteps <= 0)
			{
				setSuperVisible(_visible);
				mode = MODE_IDLE;
			}
			else 
			{
				remainingSteps--;
				
				if (mode == MODE_IN)
				{
					super.alpha = _alpha - (_alpha * remainingSteps / _fadeSteps);
					setSuperVisible(true);
				}
				else if (mode == MODE_OUT)
				{
					super.alpha = _alpha * remainingSteps / _fadeSteps;
				}
			}
		}	
	}
}