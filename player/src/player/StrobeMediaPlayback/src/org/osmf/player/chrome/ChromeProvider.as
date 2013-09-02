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

package org.osmf.player.chrome
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.configuration.Configuration;
	import org.osmf.player.chrome.widgets.AlertDialog;
	import org.osmf.player.chrome.widgets.AuthenticationDialog;
	import org.osmf.player.chrome.widgets.ButtonWidget;
	import org.osmf.player.chrome.widgets.LabelWidget;
	import org.osmf.player.chrome.widgets.Widget;
	import org.osmf.player.chrome.widgets.WidgetIDs;
	import org.osmf.player.elements.ErrorWidget;
	
	//import spark.components.mediaClasses.VolumeBar;
	
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * Singleton class that handles the player's chrome.
	 */	
	public class ChromeProvider extends EventDispatcher
	{
		// Public Interface
		//
		
		/* static */
		public static function getInstance():ChromeProvider
		{
			instance ||= new ChromeProvider(ConstructorLock);
			return instance;
		}
		
		public function ChromeProvider(lock:Class = null):void
		{
			if (lock != ConstructorLock)
			{
				throw new IllegalOperationError("ChromeProvider is a singleton: use getInstance to obtain a reference."); 
			}
			
			_widgets = new Dictionary();
		}
		
		public function load(assetsManager:AssetsManager):void
		{
			if (_loaded == false && _loading == false)
			{
				// Remember that we're in a _loading state:
				_loading = true;
				
				// Setup the assets provider:
				assetsProvider = new AssetsProvider(assetsManager);
				assetsProvider.addEventListener(Event.COMPLETE, onAssetsProviderComplete);
				assetsProvider.load();
			}
			else
			{
				throw new IllegalOperationError("ChromeProvider is either loading, or already loaded.");
			}
		}
		
		public function get loading():Boolean
		{
			return _loading;
		}
		
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		public function get assetManager():AssetsManager
		{
			return assetsProvider.assetsManager;
		}
		
		public function createAuthenticationDialog():AuthenticationDialog
		{
			var authDialog:AuthenticationDialog = new AuthenticationDialog();
			authDialog.id = WidgetIDs.LOGIN;
			authDialog.fadeSteps = 6;
			authDialog.face = AssetIDs.AUTH_BACKDROP;
			authDialog.playAfterAuthentication = true;
			authDialog.width = 279;
			authDialog.height = 228;
			authDialog.layoutMetadata.layoutMode = LayoutMode.NONE;
			authDialog.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			authDialog.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			
			var errorIcon:Widget = new Widget();
			errorIcon.id = WidgetIDs.ERROR_ICON;
			errorIcon.face = AssetIDs.AUTH_WARNING;
			errorIcon.layoutMetadata.left = 47;
			errorIcon.layoutMetadata.top = 150;
			errorIcon.layoutMetadata.width = 11;
			errorIcon.layoutMetadata.height = 9;

			authDialog.addChildWidget(errorIcon);

			var errorLabel:LabelWidget = new LabelWidget();
			errorLabel.id = WidgetIDs.ERROR_LABEL;
			errorLabel.fontSize = 12;
			errorLabel.multiline = true;
			errorLabel.layoutMetadata.left = 49;
			errorLabel.layoutMetadata.top = 138;
			errorLabel.layoutMetadata.width = 190;
			errorLabel.layoutMetadata.height = 80;
			authDialog.addChildWidget(errorLabel);
			
			var title:LabelWidget = new LabelWidget();
			title.fontSize = 18;
			title.layoutMetadata.left = 34;
			title.layoutMetadata.top = 25;
			authDialog.addChildWidget(title);

			var username:LabelWidget = new LabelWidget();
			username.id = WidgetIDs.USERNAME;
			username.input = true;
			username.fontSize = 14;
			username.textColor = "0x999999";
			username.layoutMetadata.left = 36;
			username.layoutMetadata.top = 63;
			username.layoutMetadata.width = 208;
			username.layoutMetadata.height = 20;
			username.defaultText = "User Name";
			authDialog.addChildWidget(username);
			
			var password:LabelWidget = new LabelWidget();
			password.id = WidgetIDs.PASSWORD;
			password.fontSize = 14;
			password.textColor = "0x999999";
			password.layoutMetadata.left = 36;
			password.layoutMetadata.top = 110;
			password.layoutMetadata.width = 208;
			password.layoutMetadata.height = 20;
			password.input = true;
			password.password = true;
			password.defaultText = "Password";
			authDialog.addChildWidget(password);

			var submitButton:ButtonWidget = new ButtonWidget();
			submitButton.id = WidgetIDs.SUBMIT_BUTTON;
			submitButton.upFace = AssetIDs.AUTH_SUBMIT_BUTTON_NORMAL;
			submitButton.downFace = AssetIDs.AUTH_SUBMIT_BUTTON_DOWN;
			submitButton.overFace = AssetIDs.AUTH_SUBMIT_BUTTON_OVER;
			submitButton.layoutMetadata.left = 140;
			submitButton.layoutMetadata.top = 160; 

			var submitLabel:LabelWidget = new LabelWidget();
			submitLabel.autoSize = true;
			submitLabel.fontSize = 14;
			submitLabel.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			submitLabel.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			submitButton.addChildWidget(submitLabel);
			
			authDialog.addChildWidget(submitButton);

			var cancelButton:ButtonWidget = new ButtonWidget();
			cancelButton.id = WidgetIDs.CANCEL_BUTTON;
			cancelButton.upFace = AssetIDs.AUTH_CANCEL_BUTTON_NORMAL;
			cancelButton.downFace = AssetIDs.AUTH_CANCEL_BUTTON_DOWN;
			cancelButton.overFace = AssetIDs.AUTH_CANCEL_BUTTON_OVER;
			cancelButton.layoutMetadata.left = 235;
			cancelButton.layoutMetadata.top = 25;
			authDialog.addChildWidget(cancelButton);

			
			configureWidgets(
				[ title, username, password
				, submitLabel, submitButton, cancelButton
				, errorLabel, errorIcon
				, authDialog
				]);
				
			title.text = "Sign in";
			submitLabel.text = "Sign in";

			return authDialog;
		}
		
		public function createAlertDialog():AlertDialog
		{
			// alert dialog
			var alertDialog:AlertDialog = new AlertDialog();
			alertDialog.id = WidgetIDs.ALERT;
			alertDialog.layoutMetadata.percentWidth = 100;
			alertDialog.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			alertDialog.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			
			var closeButton:ButtonWidget = new ButtonWidget();
			closeButton.id = WidgetIDs.CLOSE_BUTTON;
			alertDialog.addChildWidget(closeButton);
			
			var captionLabel:LabelWidget = new LabelWidget();
			captionLabel.id = WidgetIDs.CAPTION_LABEL;
			captionLabel.height = 0;
			alertDialog.addChildWidget(captionLabel);
			
			var messageLabel:LabelWidget = new LabelWidget();
			messageLabel.id = WidgetIDs.MESSAGE_LABEL;
			messageLabel.multiline = true;
			messageLabel.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			messageLabel.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			messageLabel.layoutMetadata.percentWidth = 100;
			messageLabel.fontSize = 16;
			messageLabel.align = TextFormatAlign.CENTER;
				
			alertDialog.addChildWidget(messageLabel);

			configureWidgets([closeButton, captionLabel, messageLabel, alertDialog]);

			return alertDialog;
		}
		
		public function createErrorWidget():ErrorWidget
		{
			var errorWidget:ErrorWidget = new ErrorWidget();
			
			errorWidget.id = WidgetIDs.ERROR;
			errorWidget.layoutMetadata.percentWidth = 100;
			errorWidget.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			errorWidget.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			
			var errorLabel:LabelWidget = new LabelWidget();
			errorLabel.id = WidgetIDs.ERROR_LABEL;
			errorLabel.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			errorLabel.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			errorLabel.layoutMetadata.percentWidth = 100;
			errorLabel.multiline = true;
			errorLabel.fontSize = 16;
			errorLabel.align = TextFormatAlign.CENTER;
			
			errorWidget.addChildWidget(errorLabel);
			
			configureWidgets([errorLabel, errorWidget]);
			
			return errorWidget;
		}

		public function createControlBar():IControlBar
		{
			var controlBar:ControlBar = new ControlBar();
			controlBar.configure(<default/>,  assetsProvider.assetsManager)
			return controlBar;
		}
		
		public function createSmartphoneControlBar():IControlBar
		{
			var controlBar:SmartphoneControlBar = new SmartphoneControlBar();
			controlBar.configure(<default/>,  assetsProvider.assetsManager)
			return controlBar;
		}
		
		public function createTabletControlBar():IControlBar
		{
			var controlBar:TabletControlBar = new TabletControlBar();
			controlBar.configure(<default/>,  assetsProvider.assetsManager)
			return controlBar;
		}
		
		public function createVolumeControlBar():VolumeControlBar{
			var volumeBar:VolumeControlBar = new VolumeControlBar();
			volumeBar.configure(<default/>,  assetsProvider.assetsManager)
			return volumeBar;
		}
		
		public function getWidget(id:String):Widget
		{
			return _widgets[id];
		}
		
		// Internals
		//
		
		private function configureWidgets(widgets:Array):void
		{
			for each( var widget:Widget in widgets)
			{
				if (widget)
				{
					var key:String = widget.id 
						? widget.id 
						: getQualifiedClassName(widget) + new Date().time;
					
					_widgets[key] = widget;
					
					widget.configure(<default/>, assetsProvider.assetsManager);
				}
			}
		}		
		
		private function onAssetsProviderComplete(event:Event):void
		{
			// Remember that we're done _loading:
			_loaded = true;
			_loading = false;
			
			// Redispatch the completion event:
			dispatchEvent(event.clone());
		}
		
		
		private var _widgets:Dictionary;
		private var _loaded:Boolean;
		private var _loading:Boolean;
		
		/* static */
		
		// for performance reasons, assets provider 
		// should be instantiated only once, so we make it
		// static and instantiate it only if null:
		private static var assetsProvider:AssetsProvider;
		private static var instance:ChromeProvider;

	}
}

class ConstructorLock {};
