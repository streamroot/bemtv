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
	import flash.display.InteractiveObject;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.events.DRMEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DRMState;
	import org.osmf.traits.DRMTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	public class AuthenticationDialog extends Widget
	{		
	
		public var playAfterAuthentication:Boolean;
		
		
		// Overrides
		//
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
						
			submit = getChildWidget("submitButton") as ButtonWidget;
			submit.addEventListener(MouseEvent.CLICK, onSubmitClick);
			
			cancel = getChildWidget("cancelButton") as ButtonWidget;
			cancel.addEventListener(MouseEvent.CLICK, onCancelClick);
			
			userName = getChildWidget("username") as LabelWidget;
			password = getChildWidget("password") as LabelWidget;
			
			errorMessage = getChildWidget("errorLabel") as LabelWidget || new LabelWidget();
			errorIcon = getChildWidget("errorIcon") as Widget || new Widget();
			
			_open = false;
			updateVisibility();
		}
		
		// Internals
		//
				
		private var userName:LabelWidget;
		private var password:LabelWidget;
		private var errorMessage:LabelWidget;
		private var errorIcon:Widget;
		private var errorIconFace:DisplayObject;
		private var submit:ButtonWidget;
		private var cancel:ButtonWidget;
		
		private var _open:Boolean;
		
		private function onMouseClick(event:MouseEvent):void
		{
			try
			{
				if (stage && stage.displayState == StageDisplayState.FULL_SCREEN)
				{
					// exit fullscreen, since it's not interactive
					// and the user won't be able to enter credentials
					stage.displayState = StageDisplayState.NORMAL;
					stage.focus = event.target as InteractiveObject;
				}
			}
			catch (e:Error)
			{
				// swallow, we get an exception if we are loaded 
				// in another swf in a different security domain
			}
		}
		
		private function onSubmitClick(event:MouseEvent):void
		{
			_open = false;
			updateVisibility();
			
			authenticating = true;
			drm.authenticate(userName.text, password.text);
		}
		
		private function onCancelClick(event:MouseEvent):void
		{
			_open = false;
			updateVisibility();
			
			userName.text = userName.defaultText;
			password.text = password.defaultText;
			authenticating = true;
			drm.authenticate();
		}
		
		private function updateVisibility():void
		{
			if(drm && drm.drmState == DRMState.AUTHENTICATION_ERROR)
			{	
				errorIcon.visible = true;	
				errorMessage.text = AUTHENTICATION_ERROR_MESSAGE;
			}
			else
			{
				errorIcon.visible = false;
				errorMessage.text = "";
			}
			visible = _open;
		}
		
		// Overrides
		//
		
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void
		{
			drm = element.getTrait(MediaTraitType.DRM) as DRMTrait;
			drm.addEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMStateChange);
			
			onDRMStateChange();
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{
			if (drm)
			{
				drm.removeEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMStateChange);
				drm = null;
				authenticating = false;
			}
			
			updateVisibility();
		}
		
		// Internals
		//
		
		private var drm:DRMTrait;
		private var authenticating:Boolean;
		
		/* static */
		private static const AUTHENTICATION_ERROR_MESSAGE:String = "Please enter a valid user name and password";
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.DRM;
		
		private function onDRMStateChange(event:DRMEvent=null):void
		{
			if (drm)
			{
				_open = drm.drmState == DRMState.AUTHENTICATION_NEEDED;
				if (_open == false && authenticating == true)
				{
					if (drm.drmState == DRMState.AUTHENTICATION_COMPLETE)
					{
						authenticating = false;
						if (playAfterAuthentication)
						{
							resumePlayback();
						}
					}
					else if (drm.drmState == DRMState.AUTHENTICATION_ERROR)
					{
						authenticating = false;
						_open = true;						
					}
				}
			}
			else
			{
				_open = false;
			}
			updateVisibility();
		}
		
		private function resumePlayback():void
		{
			var loadable:LoadTrait = media ? media.getTrait(MediaTraitType.LOAD) as LoadTrait : null;
			
			if (loadable)
			{
				loadable.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			}
			
			function onLoadStateChange(event:LoadEvent):void
			{
				var playable:PlayTrait = media ? media.getTrait(MediaTraitType.PLAY) as PlayTrait : null;
				if (event.loadState == LoadState.READY && playable)
				{
					loadable.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
					playable.play();
				}
			}
			
		}
		
	}
}