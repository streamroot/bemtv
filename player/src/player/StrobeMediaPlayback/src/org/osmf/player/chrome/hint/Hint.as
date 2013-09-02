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

package org.osmf.player.chrome.hint
{
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.assets.FontAsset;
	import org.osmf.player.chrome.widgets.FadingLayoutTargetSprite;

	public class Hint
	{
		public function Hint(lock:Class, assetManager:AssetsManager)
		{
			if (lock != ConstructorLock)
			{
				throw new IllegalOperationError("Hint is a singleton. Please use the getInstance method");
			}
			
			view = new FadingLayoutTargetSprite();
			view.fadeSteps = 10;
			view.mouseChildren = false;
			view.mouseEnabled = false;
			
			var fontAsset:FontAsset
				=	(	assetManager.getAsset("hintFont")
					||	assetManager.getAsset("defaultFont")
					) as FontAsset;
			
			label = new TextField();
			label.embedFonts = true;
			label.defaultTextFormat = fontAsset.format; 
			label.height = 12;
			label.multiline = true;
			label.wordWrap = true;
			label.width = 100;
			label.alpha = 0.8;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.background = true;
			label.backgroundColor = 0;
			
			view.addChild(label);
		}
		
		public static function getInstance(stage:Stage, assetManager:AssetsManager):Hint
		{
			if (stage == null)
			{
				throw new ArgumentError("Stage cannot be null");
			}
			
			if (_instance == null)
			{
				_instance = new Hint(ConstructorLock, assetManager);
				_instance.stage = stage;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, _instance.onStageMouseMove);
			}
			
			return _instance;
		}
		
		
		public function set text(value:String):void
		{
			if (value != _text)
			{
				if (openingTimer != null)
				{
					openingTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onOpeningTimerComplete);
					openingTimer.stop();
					openingTimer = null;
				}
				
				if (stage.contains(view))
				{
					stage.removeChild(view);
				}
				
				_text = value;
				label.text = _text || "";
				
				if (value != null && value != "")
				{
					openingTimer = new Timer(OPENING_DELAY, 1);
					openingTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onOpeningTimerComplete);
					openingTimer.start();
				}
				
				view.measure();
			}
		}
		
		public function get text():String
		{
			return _text;
		}
		
		// Internals
		//
		
		private static var _instance:Hint;
		private static const OPENING_DELAY:Number = 1200;
		
		private var stage:Stage;
		private var view:FadingLayoutTargetSprite;
		private var _text:String;
		private var label:TextField;
		
		private var openingTimer:Timer;
		
		private function onStageMouseMove(event:MouseEvent):void
		{
			if (_text != null && _text != "")
			{
				if (openingTimer && openingTimer.running)
				{
					openingTimer.reset();
					openingTimer.start();	
				}
				else
				{
					text = null;
				}
			}
		}
		
		private function onOpeningTimerComplete(event:TimerEvent):void
		{
			openingTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onOpeningTimerComplete);
			openingTimer.stop();
			openingTimer = null;
			
			stage.addChild(view);
			view.x = stage.mouseX - 13;
			view.y = stage.mouseY - view.height - 2;
		}
			
	}
}

class ConstructorLock
{
}