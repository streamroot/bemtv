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

package org.osmf.player.elements
{
	import flash.display.DisplayObject;
	
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.configuration.WidgetsParser;
	import org.osmf.player.chrome.widgets.AlertDialog;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.player.chrome.ChromeProvider;
	
	/**
	 * AlertDialogElement is a MediaElement wrapper for an AlertDialog widget.
	 */ 
	public class AlertDialogElement extends MediaElement
	{
		// Public interface
		//
		
		public function alert(caption:String, message:String):void
		{
			alertDialog.alert(caption, message)
		}
		
		
		public function set tintColor(value:uint):void
		{
			alertDialog.tintColor = value;
		}

		// Overrides
		
		override protected function setupTraits():void
		{
			// Setup a AlertDialog using the ChromeLibrary based ChromeProvider:
			chromeProvider = ChromeProvider.getInstance();
			chromeProvider.createAlertDialog();
			alertDialog = chromeProvider.getWidget("alert") as AlertDialog;
			alertDialog.measure();			
		
			// Use the alert dialog's layout metadata as the element's layout metadata:
			addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, alertDialog.layoutMetadata);
			
			// Signal that this media element is viewable: create a DisplayObjectTrait.
			// Assign alert (which is a Sprite) to be our view's displayObject.
			// Additionally, use its current width and height for the trait's mediaWidth
			// and mediaHeight properties:
			var viewable:DisplayObjectTrait = new DisplayObjectTrait(alertDialog, alertDialog.measuredWidth, alertDialog.measuredHeight);
			// Add the trait:
			addTrait(MediaTraitType.DISPLAY_OBJECT, viewable);				
			
			super.setupTraits();			
		}
		
		// Internals		
		
		private var chromeProvider:ChromeProvider;
		
		private var _target:MediaElement;
		private var alertDialog:AlertDialog;
	}
}