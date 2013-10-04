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
	import __AS3__.vec.Vector;
	
	import flash.events.MouseEvent;
	
	import org.osmf.player.chrome.assets.AssetsManager;
	
	public class AlertDialog extends Widget
	{
		// Overrides
		//
		
		public function AlertDialog()
		{
			super();
		}
				
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			queue = new Vector.<Object>;
			update();
			
			super.configure(xml, assetManager);
			
			closeButton = getChildWidget("closeButton") as ButtonWidget;
			closeButton.addEventListener(MouseEvent.CLICK,onCloseButtonClick);
			
			captionLabel = getChildWidget("captionLabel") as LabelWidget;
			messageLabel = getChildWidget("messageLabel") as LabelWidget;		
		}
		
		public function alert(caption:String, message:String):void
		{
			var alert:Object = {caption: caption, message:message}; 
			if (currentAlert != null)
			{
				queue.unshift(alert);
			}
			else
			{
				currentAlert = alert;
			}
			
			update();
		}
		
		public function close(all:Boolean=true):void
		{
			if (all)
			{
				queue = new Vector.<Object>;
			}
			onCloseButtonClick();
		}
		
		// Internals
		//
		
		private var closeButton:ButtonWidget;
		private var captionLabel:LabelWidget;
		private var messageLabel:LabelWidget;
		
		private var queue:Vector.<Object>;
		private var currentAlert:Object;
		
		private function onCloseButtonClick(event:MouseEvent=null):void
		{
			currentAlert = queue.length ? queue.pop() : null;
			
			update();
		}
		
		private function update():void
		{
			if (currentAlert == null)
			{
				visible = false;
			}
			else
			{
				captionLabel.text = currentAlert.caption;
				messageLabel.text = currentAlert.message;
				
				visible = true;
			}
		}
	}
}