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
	
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.Metadata;
	import org.osmf.player.chrome.ChromeProvider;
	import org.osmf.player.chrome.ControlBar;
	import org.osmf.player.chrome.IControlBar;
	import org.osmf.player.chrome.metadata.ChromeMetadata;
	import org.osmf.player.configuration.ControlBarType;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
		
	/**
	 * ControlBarElement defines a MediaElement implementation which contains the ControlBar UI.
	 * 
	 */ 
	public class ControlBarElement extends MediaElement
	{
		// Public interface
		//		
		
		/**
		 * Defines if the control bar should automatically hide itself
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set autoHide(value:Boolean):void
		{
			controlBar.autoHide = value;
		}
		
		public function get autoHide():Boolean
		{
			return controlBar.autoHide;
		}
		
		/**
		 * Defines the number of milliseconds of idleness required before the
		 * control bar should hide (if autoHide is enabled).
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function set autoHideTimeout(value:int):void
		{
			controlBar.autoHideTimeout = value;
		}
		
		/**
		 * Defines the target media element that this control bar operates on.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set target(value:MediaElement):void
		{
			_target = value;

			// Forward the set target to the inner control bar:
			controlBar.media = _target;
		}				
		
		
		/**
		 * Defines the tint color to aply to the control bar's background.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set tintColor(value:uint):void
		{
			controlBar.tintColor = value;
		}
		
		
		/**
		 * Defines the control bar's width.
		 * 
		 * Should only be set when dynamically sizing the control bar is
		 * required, for example when it's size is relative to the parent
		 * container.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set width(value:int):void
		{
			controlBar.width = value;
			controlBar.measure();
			controlBar.layout(value, height);
		}
		public function get width():int
		{
			return controlBar.width;
		}
		
		/**
		 * Defines the control bar's height.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get height():int
		{
			return controlBar.height;
		}
		
		public function get visible():Boolean{
			return controlBar.visible;
		}
		
		public function set visible(value:Boolean):void{
			controlBar.visible = value;
		}
		
		// Constructor
		
		public function ControlBarElement(type:String = ControlBarType.DESKTOP){
			_type = type;
			super();
		}
		
		// Overrides
		//
				
		override protected function setupTraits():void
		{
			// Setup a control bar using the embedded ChromeProvider:
			chromeProvider = ChromeProvider.getInstance();
			
			switch(_type){
				case ControlBarType.SMARTPHONE:
					controlBar = chromeProvider.createSmartphoneControlBar();
				break;
				case ControlBarType.TABLET:
					controlBar = chromeProvider.createTabletControlBar();
				break;
				default:
					controlBar = chromeProvider.createControlBar();
				break;
			}
			
			// Use the control bar's layout metadata as the element's layout metadata:
			addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, controlBar.layoutMetadata);
			
			// Signal that this media element is viewable: create a DisplayObjectTrait.
			// Assign controlBar (which is a Sprite) to be our view's displayObject.
			// Additionally, use its current width and height for the trait's mediaWidth
			// and mediaHeight properties:
			var viewable:DisplayObjectTrait = new DisplayObjectTrait(DisplayObject(controlBar));
			// Add the trait:
			addTrait(MediaTraitType.DISPLAY_OBJECT, viewable);
			
			super.setupTraits();	
		}
		
		// Internals
		//
		
		private var _target:MediaElement;
		private var controlBar:IControlBar;
		
		private var chromeProvider:ChromeProvider;
		private var _type:String;
	}
}
