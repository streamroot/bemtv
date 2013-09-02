/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.elements
{
	import __AS3__.vec.Vector;
	
	import flash.errors.IllegalOperationError;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	
	import org.osmf.elements.htmlClasses.HTMLAudioTrait;
	import org.osmf.elements.htmlClasses.HTMLLoadTrait;
	import org.osmf.elements.htmlClasses.HTMLPlayTrait;
	import org.osmf.elements.htmlClasses.HTMLTimeTrait;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFStrings;

	/**
	 * HTMLElement is a media element that represents a piece of media external
	 * to the Flash SWF, and within an HTML region.  It serves as a bridge between
	 * the OSMF APIs for controlling media, and a corresponding (external)
	 * JavaScript implementation.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class HTMLElement extends MediaElement
	{
		// Public API
		//
		
		/**
		 * @private
		 */		
		public function set scriptPath(value:String):void
		{
			_scriptPath = value;
		}
		
		/**
		 * @private
		 */
		public function getPropertyCallback(property:String):*
		{
			var result:*;
			var playable:HTMLPlayTrait = switchableTraits[MediaTraitType.PLAY] as HTMLPlayTrait;
			var temporal:HTMLTimeTrait = switchableTraits[MediaTraitType.TIME] as HTMLTimeTrait;
			var audible:HTMLAudioTrait = switchableTraits[MediaTraitType.AUDIO] as HTMLAudioTrait;
			
			// All property names start with a capital, for they translate
			// to 'getXxxx' in JavaScript.
			switch (property)
			{
				// MediaElement core:
				case "Resource":
					if (resource is URLResource)
					{
						result = URLResource(resource).url;
					}
					break;
					
				// LoadTrait:
				case "LoadState":
					result = loadTrait.loadState;
					break;
					
				// PlayTrait:
				case "Playable":
					result = hasTrait(MediaTraitType.PLAY);
					break;
				case "PlayState":
					result = playable ? playable.playState : null; 
					break;
				case "CanPause":
					result = playable ? playable.canPause : false;
					break;
				
				// TimeTrait:
				case "Temporal":
					result = hasTrait(MediaTraitType.TIME);
					break;
				case "Duration":
					result = temporal ? temporal.duration : NaN;
					break;
				case "CurrentTime":
					result = temporal ? temporal.currentTime : NaN;
					break;
					
				// AudioTrait:
				case "Volume":
					result = audible ? audible.volume : NaN;
					break;
				case "Muted":
					result = audible ? audible.muted : false;
					break;
				case "Pan":
					result = audible ? audible.pan : NaN;
					break;
			}
			
			return result;
		}
		
		/**
		 * @private
		 */
		public function setPropertyCallback(property:String, value:*):void
		{
			settingAProperty = true;
			
			var playable:HTMLPlayTrait = switchableTraits[MediaTraitType.PLAY] as HTMLPlayTrait;
			var temporal:HTMLTimeTrait = switchableTraits[MediaTraitType.TIME] as HTMLTimeTrait;
			var audible:HTMLAudioTrait = switchableTraits[MediaTraitType.AUDIO] as HTMLAudioTrait;
				
			// All property names start with a capital, for they translate
			// to 'setXxxx' in JavaScript.
			switch (property)
			{
				// Load Trait
				case "LoadState":
					var newLoadState:String = value;
					if (loadTrait)
					{
						loadTrait.loadState = newLoadState;
						if (newLoadState == LoadState.LOAD_ERROR)
						{
							dispatchEvent
								( new MediaErrorEvent
									( MediaErrorEvent.MEDIA_ERROR
									, false
									, false
									, new MediaError(MediaErrorCodes.MEDIA_LOAD_FAILED)
									)
								);
						}
					}
					break;
					
				// Play Trait:
				case "Playable":
					setTraitEnabled(MediaTraitType.PLAY, value as Boolean);
					break;
				case "CanPause":
					if (playable)
					{
						playable.canPause = value;
					}
					break;
				case "PlayState":
					if (playable)
					{
						playable.playState = value;
					}
				
				// Time Trait:
				case "Temporal":
					setTraitEnabled(MediaTraitType.TIME, value as Boolean);
					break;
				case "Duration":
					if (temporal)
					{
						temporal.duration = value as Number;
					}
					break;
				case "CurrentTime":
					if (temporal)
					{
						temporal.currentTime = value as Number;
					}
					break;
					
				// AudioTrait
				case "Audible":
					setTraitEnabled(MediaTraitType.AUDIO, value as Boolean);
					break;
				case "Volume":
					if (audible)
					{
						audible.volume = value as Number;
					}
					break;
				case "Muted":
					if (audible)
					{
						audible.muted = value as Boolean;
					}
					break;
				case "Pan":
					if (audible)
					{
						audible.pan = value as Number;
					}
					break;
				// If the property is unknown, throw an exception:
				default:
					throw new IllegalOperationError
						( "Property '"
						+ property
						+ "' assigned from JavaScript is not supported on a MediaElement."
						);
					break;
			}
			
			settingAProperty = false;
		} 
		
		/**
		 * @private
		 */
		internal var settingAProperty:Boolean;
		
		/**
		 * @private
		 */
		public function invokeJavaScriptMethod(methodName:String, ...arguments):*
		{
			requireScriptPath;
			
			arguments.unshift(_scriptPath + "__" + methodName + "__");
			var result:* = ExternalInterface.call.apply(this, arguments);
					
			return result;
		}
		
		/**
		 * @private
		 */		
		private function setTraitEnabled(type:String, enabled:Boolean):void
		{
			if (switchableTraitTypes.indexOf(type) == -1)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			var trait:MediaTraitBase = switchableTraits[type];
			if (trait == null && enabled == true)
			{
				// Instantiate the correct trait implementation:
				switch(type)
				{
					case MediaTraitType.PLAY:
						trait = new HTMLPlayTrait(this);
						break;
					case MediaTraitType.TIME:
						trait = new HTMLTimeTrait(this);
						break;
					case MediaTraitType.AUDIO:
						trait = new HTMLAudioTrait(this);
						break;
				}
				switchableTraits[type] = trait;
				updateTraits();
			}
			else if (trait != null && enabled == false)
			{
				// Remove the current trait implementation:
				delete switchableTraits[type];
				updateTraits();
			}
		}
		
		// Overrides
		//
		
		/**
		 * @private
		 */
		override public function set resource(value:MediaResourceBase):void
		{
			if (resource != value)
			{
				super.resource = value;
				
				// LoadTrait cannot have its resource reset anymore. As a
				// result, we need to consruct a new trait on the elements
				// resource being set:
				
				if (loadTrait)
				{
					loadTrait.unload();
					loadTrait.removeEventListener
						( LoadEvent.LOAD_STATE_CHANGE
						, onLoadStateChange
						);
				}
				
				loadTrait = new HTMLLoadTrait(this);
				
				{
					addTrait(MediaTraitType.LOAD, loadTrait);
					
					loadTrait.addEventListener
						( LoadEvent.LOAD_STATE_CHANGE
						, onLoadStateChange
						, false, int.MAX_VALUE
						);
				}
			}
		}
		
		// Private
		//
	
		private function onLoadStateChange(event:LoadEvent):void
		{
			updateTraits();
		}
	
		private function updateTraits():void
		{
			var type:String;
			
			if (loadTrait && loadTrait.loadState == LoadState.READY)
			{
				// Make sure that the constructed trait objects are
				// being reflected on being loaded:
				for (var typeObject:Object in switchableTraits)
				{
					type = String(typeObject);
					var trait:MediaTraitBase = switchableTraits[type]; 
					if (hasTrait(type) == false)
					{
						addTrait(type, trait);
					}
				}
			}
			else
			{
				// Don't expose any traits if not loaded (except for the 
				// LoadTrait):
				for each (type in traitTypes)
				{
					if (type != MediaTraitType.LOAD)
					{
						removeTrait(type);
					}
				}
			}
		}
	
		private function get requireScriptPath():*
		{
			if (_scriptPath == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_SCRIPT_PATH));	
			}
			
			return undefined;
		}
	
		private var loadTrait:HTMLLoadTrait;
		
		private var switchableTraits:Dictionary = new Dictionary();
		
		private var _scriptPath:String;
		
		/* static */
		
		private static const switchableTraitTypes:Vector.<String> = new Vector.<String>(3);
			switchableTraitTypes[0] = MediaTraitType.PLAY;
			switchableTraitTypes[1] = MediaTraitType.TIME;
			switchableTraitTypes[2] = MediaTraitType.AUDIO;
			
	}
}