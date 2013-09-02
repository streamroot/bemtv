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
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	import org.osmf.player.chrome.assets.AssetsManager;
	
	public class ButtonWidget extends Widget
	{
		public function ButtonWidget()
		{
			
			mouseEnabled = true;
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.CLICK, onMouseClick_internal);
		}
		
		// Overrides
		//
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{

			super.configure(xml, assetManager);

			up =  assetManager.getDisplayObject(upFace);
			down = assetManager.getDisplayObject(downFace);
			over = assetManager.getDisplayObject(overFace);
			disabled =  assetManager.getDisplayObject(disabledFace);
			
			setFace(up);
		}
		
		protected function onMouseOut(event:MouseEvent):void
		{
			Mouse.cursor = flash.ui.MouseCursor.ARROW;
			mouseOver = false;
			setFace(enabled ? up : disabled);
		}

		protected function onMouseOver(event:MouseEvent):void
		{
			Mouse.cursor = flash.ui.MouseCursor.BUTTON;
			mouseOver = true;
			setFace(enabled ? over : disabled);
		}

		// Internals
		//

		protected function onMouseDown(event:MouseEvent):void
		{
			mouseOver = false;
			setFace(enabled ? down : disabled);
		}
		
		private function onMouseClick_internal(event:MouseEvent):void
		{
			if (enabled == false)
			{
				event.stopImmediatePropagation();
			}
			else
			{
				onMouseClick(event);
			}
		}
		
		// Overrides
		//
		
		override protected function processEnabledChange():void
		{
			setFace(enabled ? mouseOver ? over : up : disabled);
			
			super.processEnabledChange();
		}
		
		protected function setFace(face:DisplayObject):void
		{
			if (currentFace != face)
			{
				if (currentFace != null)
				{
					removeChild(currentFace);
				}
				
				currentFace = face;
				
				if (currentFace != null)
				{
					addChildAt(currentFace, 0);
					
					width = currentFace.width;
					height = currentFace.height;
				}
			}
		}

		// Stubs
		//
		
		protected function onMouseClick(event:MouseEvent):void
		{
		}
		
		public var upFace:String = "buttonUp";
		public var downFace:String = "buttonDown";
		public var overFace:String = "buttonOver";
		public var disabledFace:String = "buttonDisabled";

		protected var currentFace:DisplayObject;
		protected var mouseOver:Boolean;
		
		protected var up:DisplayObject;
		protected var down:DisplayObject;
		protected var over:DisplayObject;
		protected var disabled:DisplayObject;
	}
}