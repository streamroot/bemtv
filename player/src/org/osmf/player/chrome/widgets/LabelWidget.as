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
	import flash.events.FocusEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import flashx.textLayout.accessibility.TextAccImpl;
	import flashx.textLayout.formats.TextAlign;
	
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.assets.FontAsset;
	
	public class LabelWidget extends Widget
	{
		public var font:String = "defaultFont";
		public var autoSize:Boolean;
		public var align:String;
		public var fontSize:Number;
		public var input:Boolean;
		public var selectable:Boolean;
		public var password:Boolean;
		public var multiline:Boolean;
		public var textColor:String;
		public var defaultText:String = "";
		
		public function LabelWidget()
		{
			textField = new TextField();
			textField.addEventListener(Event.CHANGE, onChange);
			textField.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			textField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			addChild(textField);
			
			super();
		}
		
		public function focus():void
		{
			stage.focus = textField;
		}
		
		public function get text():String
		{
			return textField.text;
		}
		
		public function set text(value:String):void
		{
			var oldText:String = textField.text;
			
			textField.text = value;
			if (autoSize && value.length != oldText.length)
			{
				measure();
			}
		}
		
		public function get textFormat():TextFormat
		{
			return textField.defaultTextFormat;
		}
		
		public function set textFormat(value:TextFormat):void
		{
			textField.defaultTextFormat = value;
		}
		
		// Overrides
		//
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);
			
			var fontAsset:FontAsset = assetManager.getAsset(font) as FontAsset;
			var format:TextFormat = fontAsset ? fontAsset.format : new TextFormat();
			if(textColor)
			{
				format.color = parseInt(textColor);
			}
			if(fontSize) 
			{
				format.size = fontSize;
			}
			
			if(align)
			{
				format.align = align;
			}
			
			textField.defaultTextFormat = format;
			textField.embedFonts = true;
			textField.type = input ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			textField.selectable = textField.type == TextFieldType.INPUT || selectable;
			textField.background = String(parseAttribute(xml, "background", "false")).toLocaleLowerCase()=="true";
			textField.displayAsPassword = password;
			textField.backgroundColor = Number(xml.@backgroundColor || NaN);
			textField.alpha = Number(xml.@textAlpha) || 1;
			textField.multiline = multiline;
			textField.wordWrap = textField.multiline;
			textField.autoSize = autoSize ? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
			textField.antiAliasType = AntiAliasType.ADVANCED;
			textField.sharpness = 200;
			textField.thickness = 0;
			if(textField.text == "")
			{
				textField.text = defaultText;
				textField.displayAsPassword = false;
			}
		}
		
		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean=true):void
		{
			textField.width = autoSize 
				? Math.min(availableWidth, textField.textWidth) 
				: availableWidth;
			textField.height = availableHeight;
		}
		
		
		protected var textField:TextField;
		
		//Internals
		//
		
		private function onChange(event:Event):void
		{
			dirty = true;
		}
		
		private function onFocusIn(event:FocusEvent):void
		{
			if (textField.text == defaultText && !dirty)
			{
				textField.text = "";
				textField.displayAsPassword = password;
			}
		}
		
		private function onFocusOut(event:FocusEvent):void
		{
			if (textField.text == "" && defaultText.length > 0)
			{
				textField.text = defaultText;
				textField.displayAsPassword = false;
				dirty = false;
			}
		}
		
		private var dirty:Boolean;

	}
}