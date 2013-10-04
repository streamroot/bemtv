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

package org.osmf.player.containers
{
	import flash.display.DisplayObject;
	import flash.errors.IllegalOperationError;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.osmf.containers.IMediaContainer;
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.LayoutRenderer;
	import org.osmf.layout.LayoutRendererBase;
	import org.osmf.layout.LayoutTargetEvent;
	import org.osmf.layout.LayoutTargetSprite;
	import org.osmf.layout.MediaElementLayoutTarget;
	import org.osmf.media.MediaElement;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * MediaContainer defines a Sprite-based IMediaContainer implementation.
	 * 
	 * @includeExample MediaContainerExample.as -noswf
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class StrobeMediaContainer extends LayoutTargetSprite implements IMediaContainer
	{
		/**
		 * Constructor.
		 *  
		 * @param layoutRenderer The layout renderer that will render
		 * the MediaElement instances that get added to this container. If no
		 * renderer is specified, a LayoutRenderer instance will be used.
		 * @param layoutMetadata The LayoutMetadata to use to layout this
		 * sprite.  Optional.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function StrobeMediaContainer(layoutRenderer:LayoutRendererBase=null, layoutMetadata:LayoutMetadata=null)
		{
			super(layoutMetadata);
			
			_layoutRenderer = layoutRenderer || new LayoutRenderer();
			_layoutRenderer.container = this; 
		}
		
		/**
		 * Adds a MediaElement instance to the container.
		 * 
		 * @param element The MediaElement instance to add to the container.
		 * @returns The added MediaElement instance.
		 * @throws IllegalOperationError if the specified element is null,
		 * or already a child of the container.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function addMediaElement(element:MediaElement):MediaElement
		{
			if (element == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			if (layoutTargets[element] == undefined)
			{
				// Media containers are under obligation to dispatch a container change event when
				// they add a media element:
				element.dispatchEvent
					( new ContainerChangeEvent
						( ContainerChangeEvent.CONTAINER_CHANGE
						, false, false
						, element.container, this
						)
					);
					
				var contentTarget:MediaElementLayoutTarget = MediaElementLayoutTarget.getInstance(element);
				
				layoutTargets[element] = contentTarget;
				_layoutRenderer.addTarget(contentTarget);
				
				element.addEventListener(ContainerChangeEvent.CONTAINER_CHANGE, onElementContainerChange);
			}
			else
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return element;
		}
		
		/**
		 * Removes a MediaElement instance from the container.
		 * 
		 * @param element The element to remove from the container.
		 * @returns The removed MediaElement instance.
		 * @throws IllegalOperationError if the specified element isn't
		 * a child element, or is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function removeMediaElement(element:MediaElement):MediaElement
		{
			if (element == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			var result:MediaElement;
			var contentTarget:MediaElementLayoutTarget = layoutTargets[element];
			
			if (contentTarget)
			{
				element.removeEventListener(ContainerChangeEvent.CONTAINER_CHANGE, onElementContainerChange);
				_layoutRenderer.removeTarget(contentTarget);
				delete layoutTargets[element];
				result = element;
				
				// Media containers are under obligation to dispatch a container change event when
				// they remove a media element. See if we're still the element's container, though.
				// For if not, a change has already occured.
				if (element.container == this)
				{
					element.dispatchEvent
						( new ContainerChangeEvent
							( ContainerChangeEvent.CONTAINER_CHANGE
							, false, false
							, element.container, null
							)
						);
				}
			}
			else
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return result;
		}
		
		/**
		 * Verifies if an element is a child of the container.
		 *  
		 * @param element Element to verify.
		 * @return True if the element if a child of the container.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function containsMediaElement(element:MediaElement):Boolean
		{
			return layoutTargets[element] != undefined
		}
		
		/**
		 * The layout renderer that renders the MediaElement instances within
		 * this container.
		 **/
		public function get layoutRenderer():LayoutRendererBase
		{
			return _layoutRenderer;
		}
		
		/**
		 * Defines if the children of the container that display outside of its bounds 
		 * will be clipped or not.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get clipChildren():Boolean
		{
			return scrollRect != null;
		}
		
		public function set clipChildren(value:Boolean):void
		{
			if (value && scrollRect == null)
			{
				scrollRect = new Rectangle(0, 0, _layoutRenderer.measuredWidth, _layoutRenderer.measuredHeight);
			}
			else if (value == false && scrollRect)
			{
				scrollRect = null;
			} 
		}
		
		/**
		 * Defines the container's background color. By default, this value
		 * is set to NaN, which results in no background being drawn.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get backgroundColor():Number
		{
			return _backgroundColor;
		}

		public function set backgroundColor(value:Number):void
		{
			if (value != _backgroundColor)
			{
				_backgroundColor = value;
				drawBackground();
			}
		}
		
		/**
		 * Defines the container's background alpha. By default, this value
		 * is set to 1, which results in the background being fully opaque.
		 * 
		 * Note that a container will not have a background drawn unless its
		 * backgroundColor property is set.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get backgroundAlpha():Number
		{
			return _backgroundAlpha;
		}

		public function set backgroundAlpha(value:Number):void
		{
			if (value != _backgroundAlpha)
			{
				_backgroundAlpha = value;
				drawBackground();
			}
		}
		
		// Overrides
		//
		
		/**
		 * @private
		 **/
		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true):void
		{
			super.layout(availableWidth, availableHeight, deep);
			
			lastAvailableWidth = availableWidth;
			lastAvailableHeight = availableHeight;
			
			if (!isNaN(backgroundColor))
			{
				drawBackground();
			}
			
			if (scrollRect)
			{
				scrollRect = new Rectangle(0, 0, availableWidth, availableHeight);
			}
		}
				
		/**
		 * @private
		 */
		override public function validateNow():void
		{
			_layoutRenderer.validateNow();
		}
		
		// Overrides
		//
		
//		/**
//		 * @private
//		 **/
//		override public function addChild(child:DisplayObject):DisplayObject
//		{
//			throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.DIRECT_DISPLAY_LIST_MOD_ERROR));
//		}
//		
		/**
		 * @private
		 **/
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.DIRECT_DISPLAY_LIST_MOD_ERROR));
		}
		
//		/**
//		 * @private
//		 **/
//		override public function removeChild(child:DisplayObject):DisplayObject
//		{
//			throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.DIRECT_DISPLAY_LIST_MOD_ERROR));
//		}
		
		/**
		 * @private
		 **/
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.DIRECT_DISPLAY_LIST_MOD_ERROR));
		}
		
		/**
		 * @private
		 **/
		override protected function onAddChildAt(event:LayoutTargetEvent):void
		{
			super.addChildAt(event.displayObject, event.index);
		}
		
		/**
		 * @private
		 **/
		override protected function onRemoveChild(event:LayoutTargetEvent):void
		{
			super.removeChild(event.displayObject);	
		}
		
		/**
		 * @private
		 **/
		override protected function onSetChildIndex(event:LayoutTargetEvent):void
		{
			super.setChildIndex(event.displayObject, event.index);	
		}
		
		// Internals
		//
		
		private function drawBackground():void
		{
			graphics.clear();
			
			if	(	!isNaN(_backgroundColor)
				&&	lastAvailableWidth
				&&	lastAvailableHeight
				)
			{
				graphics.beginFill(_backgroundColor, _backgroundAlpha);
				graphics.drawRect(0, 0, lastAvailableWidth, lastAvailableHeight);
				graphics.endFill();
			}
		}
		
		private function onElementContainerChange(event:ContainerChangeEvent):void
		{
			if (event.oldContainer == this)
			{
				removeMediaElement(event.target as MediaElement);
			}
		}
		
		/**
		 * @private
		 * 
		 * Dictionary of MediaElementLayoutTarget instances, index by the
		 * media elements that they wrap: 
		 */		
		private var layoutTargets:Dictionary = new Dictionary();
		
		private var _layoutRenderer:LayoutRendererBase;
		
		private var _backgroundColor:Number;
		private var _backgroundAlpha:Number;
		
		private var lastAvailableWidth:Number;
		private var lastAvailableHeight:Number;
	}
}