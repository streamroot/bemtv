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

package org.osmf.player.chrome.widgets
{
	import __AS3__.vec.Vector;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.utils.getDefinitionByName;
	
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.configuration.LayoutAttributesParser;
	import org.osmf.player.chrome.hint.Hint;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.LayoutRenderer;
	import org.osmf.layout.LayoutRendererBase;
	import org.osmf.layout.LayoutTargetEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	
	public class Widget extends FadingLayoutTargetSprite
	{
		public function Widget()
		{
			super();
			super.addChildAt(new Sprite(), 0);
			
			children = new Vector.<Widget>();
		}
		
		public function configure(xml:XML, assetManager:AssetsManager):void
		{
			_configuration = xml;
			_assetManager = assetManager;
						
			// Override default properties
			for each(var attribute:XML in xml.@*)
			{
				var propertyName:String = attribute.name();
				if (hasOwnProperty(propertyName))
				{
					this[propertyName] = setValueFromString(this[propertyName], attribute.toString());
				}
				else if (layoutMetadata.hasOwnProperty(propertyName))
				{
					layoutMetadata[propertyName] = setValueFromString(layoutMetadata[propertyName], attribute.toString());
				}
			}
			
			faceDisplayObject 	= assetManager.getDisplayObject(face) || new Sprite();
			
		}
		
		public function get configuration():XML
		{
			return _configuration;
		}
		
		public function get assetManager():AssetsManager
		{
			return _assetManager;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function set id(value:String):void
		{
			_id = value;
		}
		
		public function set media(value:MediaElement):void
		{
			if (_media != value)
			{
				var oldValue:MediaElement = _media;
				_media = null;
								
				if (oldValue)
				{
					oldValue.removeEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementTraitsChange);
					oldValue.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaElementTraitsChange);
					onMediaElementTraitsChange(null);
				}
				
				_media = value;
				
				if (_media)
				{
					_media.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementTraitsChange);
					_media.addEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaElementTraitsChange);
				}
				
				for each (var child:Widget in children)
				{
					child.media = _media;
				}
				
				processMediaElementChange(oldValue);
				onMediaElementTraitsChange(null);
			}
		}
		
		public function get media():MediaElement
		{
			return _media;
		}
		
		public function set faceDisplayObject(value:DisplayObject):void
		{
			if (value != _displayObject)
			{
				if (_displayObject)
				{
					removeChild(_displayObject);
				}
				_displayObject = value;
				if (_displayObject)
				{
					addChildAt(_displayObject, 0);
				}
				
				measure();
			}
		}
		
		public function set enabled(value:Boolean):void
		{
			if (_enabled != value)
			{
				_enabled = value;
				processEnabledChange();
			}
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function addChildWidget(widget:Widget):void
		{
			if (layoutRenderer == null)
			{
				layoutRenderer = constructLayoutRenderer();
				if (layoutRenderer)
				{
					layoutRenderer.container = this;
				}
			}
			
			if (layoutRenderer != null)
			{
				layoutRenderer.addTarget(widget);
				children.push(widget);
				widget.media = _media;
			}
		}
		
		public function removeChildWidget(widget:Widget):void
		{
			if (layoutRenderer && layoutRenderer.hasTarget(widget))
			{
				layoutRenderer.removeTarget(widget);
				children.splice(children.indexOf(widget), 1);
			}
		}
		
		public function getChildWidget(id:String):Widget
		{
			var result:Widget
			
			for each (var child:Widget in children)
			{
				if (child.id && child.id.toLowerCase() == id.toLocaleLowerCase())
				{
					result = child;
					break;
				}
			}
			
			return result;
		}
		
		public function set hint(value:String):void
		{
			if (value != _hint)
			{
				if (_hint == null)
				{
					addEventListener(MouseEvent.ROLL_OVER, onRollOver);
					addEventListener(MouseEvent.ROLL_OUT, onRollOut);
				}
				
				if	(	stage
					&&	_hint
					&&	_hint != ""
					&&	Hint.getInstance(stage, _assetManager).text == _hint
					)
				{
					Hint.getInstance(stage, _assetManager).text = value;
				}
				
				_hint = value;
				
				if (_hint == null)
				{
					removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
					removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				}
			}
		}
		
		public function get hint():String
		{
			return _hint;
		}

		
		public function set tintColor(value:uint):void
		{
			_tintColor = value;
			var tintMultiplier:uint = 1;
			var colTransform:ColorTransform = new ColorTransform();
			colTransform.redMultiplier = 
				colTransform.greenMultiplier = 
				colTransform.blueMultiplier = tintMultiplier;
			colTransform.redOffset = Math.round(((_tintColor & 0xFF0000) >> 16) * tintMultiplier);
			colTransform.greenOffset = Math.round(((_tintColor & 0x00FF00) >> 8) * tintMultiplier);
			colTransform.blueOffset = Math.round(((_tintColor & 0x0000FF)) * tintMultiplier);
			transform.colorTransform = colTransform;
		}
		
		public function get tintColor():uint
		{
			return _tintColor;
		}
		
		public var face:String = "";

		
		// Overrides
		//
		
		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean=true):void
		{
			if (_displayObject)
			{
				_displayObject.width = availableWidth / scaleX;
				_displayObject.height = availableHeight / scaleY;
			}
			super.layout(availableWidth, availableHeight, deep);
		}
		
		override public function set width(value:Number):void
		{
			if (_displayObject)
			{
				_displayObject.width = value / scaleX;
			}
			super.width = value;
		}
		
		override public function set height(value:Number):void
		{
			if (_displayObject)
			{
				_displayObject.height = value / scaleY;
			}
			super.height = value;
		}
		
		override protected function onAddChildAt(event:LayoutTargetEvent):void
		{
			event = new LayoutTargetEvent
				( event.type
				, event.bubbles
				, event.cancelable
				, event.layoutRenderer
				, event.layoutTarget
				, event.displayObject
				, event.index == -1 ? -1 : event.index + 1
				); 
			super.onAddChildAt(event);
		}

		override protected function onRemoveChild(event:LayoutTargetEvent):void
		{
			event = new LayoutTargetEvent
				( event.type
				, event.bubbles
				, event.cancelable
				, event.layoutRenderer
				, event.layoutTarget
				, event.displayObject
				, event.index == -1 ? -1 : event.index + 1
				); 
			super.onRemoveChild(event);
		}
		
		override protected function onSetChildIndex(event:LayoutTargetEvent):void
		{
			event = new LayoutTargetEvent
				( event.type
				, event.bubbles
				, event.cancelable
				, event.layoutRenderer
				, event.layoutTarget
				, event.displayObject
				, event.index == -1 ? -1 : event.index + 1
				); 
			super.onSetChildIndex(event);
		}
		
		override protected function setSuperVisible(value:Boolean):void
		{
			super.setSuperVisible(value);
			layoutMetadata.includeInLayout = value && (configuration ? configuration.@includeInLayout != "false" : true);
		}
				
		// Stubs
		//
		
		protected function constructLayoutRenderer():LayoutRendererBase
		{
			return new LayoutRenderer();
		}
		
		protected function processEnabledChange():void
		{
		}
		
		protected function processMediaElementChange(oldMediaElement:MediaElement):void
		{
		}
		
		protected function onMediaElementTraitAdd(event:MediaElementEvent):void
		{
		}
		
		protected function onMediaElementTraitRemove(event:MediaElementEvent):void
		{	
		}
		
		protected function processRequiredTraitsAvailable(element:MediaElement):void
		{	
		}
		
		protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{	
		}
		
		protected function get requiredTraits():Vector.<String>
		{
			return null;
		}

		// Internals
		//
		
		private var _media:MediaElement;
		
		private var _configuration:XML;
		private var _assetManager:AssetsManager;
		private var _id:String = "";
		private var _enabled:Boolean = true;
		private var _hint:String = null;
		private var _tintColor:uint = 0;
		
		private var _displayObject:DisplayObject;
		private var layoutRenderer:LayoutRendererBase;
		
		private var children:Vector.<Widget>;
		
		private var _requiredTraitsAvailable:Boolean;
		
		private function onRollOver(event:MouseEvent):void
		{
			Hint.getInstance(stage, assetManager).text = _hint;
		}
		
		private function onRollOut(event:MouseEvent):void
		{
			Hint.getInstance(stage, assetManager).text = null;
		}
		
		private function onMediaElementTraitsChange(event:MediaElementEvent = null):void
		{
			var element:MediaElement
				= event 
					? event.target as MediaElement
					: _media;
					
			var priorRequiredTraitsAvailable:Boolean = _requiredTraitsAvailable;
		
			if (element)
			{
				_requiredTraitsAvailable = true;
				for each (var type:String in requiredTraits)
				{
					if (element.hasTrait(type) == false || (event != null && event.type == MediaElementEvent.TRAIT_REMOVE && event.traitType == type))
					{
						_requiredTraitsAvailable = false;
						break;
					}
				}
			}
			else
			{
				_requiredTraitsAvailable = false;
			}
			
			if	(	event == null // always invoke handlers, if change is not event driven.
				||	_requiredTraitsAvailable != priorRequiredTraitsAvailable
				)
			{
				_requiredTraitsAvailable
					? processRequiredTraitsAvailable(element)
					: processRequiredTraitsUnavailable(element);
			}
			
			if (event)
			{
				event.type == MediaElementEvent.TRAIT_ADD
					? onMediaElementTraitAdd(event)
					: onMediaElementTraitRemove(event);
			}
		}
		
		// Utils
		//
		
		protected function parseAttribute(xml:XML, attributeName:String, defaultValue:*):*
		{
			var result:*;
			
			if (xml.@[attributeName] == undefined)
			{
				result = defaultValue;
			}
			else
			{
				result = xml.@[attributeName];
			}
			
			return result;
		}
		
		private function setValueFromString(object:*, stringValue:String):*
		{
			var value:* = null;
			if (object is Boolean)
			{
				value = stringValue.toLowerCase() == "true";
			}
			else if (object is int || object is uint)
			{
				value = parseInt(stringValue);

			}
			else if (object is Number)
			{
				value = parseFloat(stringValue);
			}
			else
			{
				value = stringValue as Object;
			}

			return value;
		}
		
	}
}