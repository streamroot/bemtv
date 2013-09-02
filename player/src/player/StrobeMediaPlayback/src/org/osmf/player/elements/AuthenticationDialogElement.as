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
	import org.osmf.player.chrome.widgets.AuthenticationDialog;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.Metadata;
	import org.osmf.player.chrome.ChromeProvider;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * AuthenticationDialogElement is a MediaElement wrapper for a AuthentificationDialog widget.
	 */	
	public class AuthenticationDialogElement extends MediaElement
	{
	
		// Public interface
		//
		
		/**
		 * The target media element for the authentication dialog
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set target(value:MediaElement):void
		{
			authDialog.media = value;
		}
		
		public function set tintColor(value:uint):void
		{
			authDialog.tintColor = value;
		}
		
		// Overrides
		//
		
		override protected function setupTraits():void
		{
			// Setup a AuthenticationDialog using the ChromeLibrary based ChromeProvider:
			chromeProvider = ChromeProvider.getInstance();
			chromeProvider.createAuthenticationDialog();
			authDialog = chromeProvider.getWidget("login") as AuthenticationDialog;
			authDialog.measure();			
			
			// Use the alert dialog's layout metadata as the element's layout metadata:
			addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, authDialog.layoutMetadata);
			
			// Signal that this media element is viewable: create a DisplayObjectTrait.
			// Assign auth dialog (which is a Sprite) to be our view's displayObject.
			// Additionally, use its current width and height for the trait's mediaWidth
			// and mediaHeight properties:
			var viewable:DisplayObjectTrait = new DisplayObjectTrait(authDialog, authDialog.measuredWidth, authDialog.measuredHeight);
			// Add the trait:
			addTrait(MediaTraitType.DISPLAY_OBJECT, viewable);				
		
			super.setupTraits();			
		}
		
		// Internals
		//
		
		private var chromeProvider:ChromeProvider;
		
		private var _target:MediaElement;
		private var authDialog:AuthenticationDialog;
	}
}