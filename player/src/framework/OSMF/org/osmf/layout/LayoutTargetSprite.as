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
package org.osmf.layout
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import org.osmf.events.DisplayObjectEvent;
	
	/**
	 * @private
	 * 
	 * Dispatched when a layout target is being set as a layout renderer's container.
	 *
	 * LayoutRendererBase dispatches this event on the target being set as its container.
	 * 
	 * Implementations that are to be used as layout renderer containers are required
	 * to listen to the event in order to maintain a reference to their layout
	 * renderer, so it can be correctly parented on the container becoming a child
	 * of another container.
	 *  
	 * @eventType org.osmf.layout.LayoutTargetEvent.SET_AS_LAYOUT_RENDERER_CONTAINER
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="setAsLayoutRendererContainer",type="org.osmf.layout.LayoutTargetEvent")]
	
	/**
	 * @private
	 * 
	 * Dispatched when a layout target is being un-set as a layout renderer's container.
	 * 
	 * LayoutRendererBase dispatches this event on the target being unset as its container.
	 * 
	 * Implementations that are to be used as layout renderer containers are required
	 * to listen to the event in order to reset the reference to their layout renderer. 
	 * 
	 * @eventType org.osmf.layout.LayoutTargetEvent.UNSET_AS_LAYOUT_RENDERER_CONTAINER
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="unsetAsLayoutRendererContainer",type="org.osmf.layout.LayoutTargetEvent")]
	
	/**
	 * @private
	 * 
	 * Dispatched when a layout target is added as a target to a layout renderer.
	 * 
	 * LayoutRendererBase dispatches this event on a target when it gets added to
	 * its list of targets.
	 * 
	 * Implementations that are to be used as layout renderer containers
	 * are required to listen to the event in order to invoke <code>setParent</code>
	 * on the renderer that they are the container for.
	 * 
	 * Failing to do so will break the rendering tree, resulting in unneccasary
	 * layout recalculations, as well as unexpected size and positioning of the target.
	 * 
	 * @eventType org.osmf.layout.LayoutTargetEvent.ADD_TO_LAYOUT_RENDERER
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="addToLayoutRenderer",type="org.osmf.layout.LayoutTargetEvent")]

	/**
	 * @private
	 * 
	 * Dispatched when a layout target is removed as a target from a layout renderer.
	 * 
	 * LayoutRendererBase dispatches this event on a target when it gets removed from
	 * its list of targets.
	 *
	 * Implementations that are to be used as layout renderer containers
	 * are required to listen to the event in order to invoke <code>setParent</code>
	 * on the renderer that they are the container for. In case of removal, the
	 * parent should be set to null, unless the target has already been assigned
	 * as the container of another renderer.
	 * 
	 * Failing to do so will break the rendering tree, resulting in unneccasary
	 * layout recalculations, as well as unexpected size and positioning of the target.
	 * 
	 * @eventType org.osmf.layout.LayoutTargetEvent.REMOVE_FROM_LAYOUT_RENDERER
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="removeFromLayoutRenderer",type="org.osmf.layout.LayoutTargetEvent")]

	/**
	 * @private
	 * 
	 * Dispatched when a layout renderer wishes its layout target container to
	 * stage a display object for one of its targets.
	 * 
	 * @eventType org.osmf.layout.LayoutTargetEvent.ADD_CHILD_AT
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="addChildAt",type="org.osmf.layout.LayoutTargetEvent")]
	
	/**
	 * @private
	 * 
	 * Dispatched when a layout renderer wishes its layout target container to
	 * change the display index of the display object for one of its targets.
	 * 
	 * @eventType org.osmf.layout.LayoutTargetEvent.SET_CHILD_INDEX
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="setChildIndex",type="org.osmf.layout.LayoutTargetEvent")]

	/**
	 * @private
	 * 
	 * Dispatched when a layout renderer wishes its layout target container to
	 * remove the display object for one of its targets.
	 * 
	 * @eventType org.osmf.layout.LayoutTargetEvent.REMOVE_CHILD
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="removeChild",type="org.osmf.layout.LayoutTargetEvent")]

	/**
	 * LayoutTargetSprite defines a Sprite-based ILayoutTarget implementation.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class LayoutTargetSprite extends Sprite implements ILayoutTarget
	{
		/**
		 * Constructor.
		 * 
		 * @param layoutMetadata The LayoutMetadata to use to layout this
		 * sprite.  Optional.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function LayoutTargetSprite(layoutMetadata:LayoutMetadata=null)
		{
			_layoutMetadata = layoutMetadata || new LayoutMetadata();
			renderers = new LayoutTargetRenderers(this);
			
			addEventListener(LayoutTargetEvent.ADD_CHILD_AT, onAddChildAt);
			addEventListener(LayoutTargetEvent.SET_CHILD_INDEX, onSetChildIndex);
			addEventListener(LayoutTargetEvent.REMOVE_CHILD, onRemoveChild);
			
			mouseEnabled = true;
			mouseChildren = true;
			
			super();
		}
		
		// ILayoutTarget
		//
		
		/**
		 * A reference to the display object that represents the target. A
		 * client may use this reference to position or parent the target.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get displayObject():DisplayObject
		{
			return this;
		}

	 	/**
	 	 * The metadata that's used to hold information about the layout
	 	 * of this layout target.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	 	 **/
	 	public function get layoutMetadata():LayoutMetadata
	 	{
	 		return _layoutMetadata;
	 	}
	 	
	 	/**
	 	 * Defines the width of the element without any transformations being
	 	 * applied. For a JPG with an original resolution of 1024x768, this
	 	 * would be 1024 pixels. A client may use this value to (for example)
	 	 * keep ratio on scaling the element.
	 	 *  
	 	 *  @langversion 3.0
	 	 *  @playerversion Flash 10
	 	 *  @playerversion AIR 1.5
	 	 *  @productversion OSMF 1.0
	 	 */	 	
		public function get measuredWidth():Number
		{
			return _measuredWidth;
		}
		
	 	/**
	 	 * Defines the height of the element without any transformations being
	 	 * applied. For a JPG with an original resolution of 1024x768, this
	 	 * would be 768 pixels. A client may use this value to (for example)
	 	 * keep ratio on scaling the element.
	 	 *  
	 	 *  @langversion 3.0
	 	 *  @playerversion Flash 10
	 	 *  @playerversion AIR 1.5
	 	 *  @productversion OSMF 1.0
	 	 */
		public function get measuredHeight():Number
		{
			return _measuredHeight;
		}
		
	 	/**
		 * Method that informs the implementation that it should reassess its
		 * measuredWidth and measuredHeight fields:
		 * 
		 * @param deep True if the measurement request is to be forwarded to
		 * the target's potential inner layout system. The forwarding should take
		 * place up front the target measuring itself.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function measure(deep:Boolean = true):void
		{
			if (deep && renderers.containerRenderer)
			{
				renderers.containerRenderer.measure();
			}
			
			var newMeasuredWidth:Number;
			var newMeasuredHeight:Number;
			
			if (renderers.containerRenderer)
			{
				// The measured dimensions can be fetched from the sprite's own
				// layout renderer. Since measurement takes place bottom to top,
				// the renderer should already be up to date for this pass:
				newMeasuredWidth = renderers.containerRenderer.measuredWidth;
				newMeasuredHeight = renderers.containerRenderer.measuredHeight;
			}
			else
			{
				// The sprite is a leaf. Fetch the size from the sprite itself:
				newMeasuredWidth = super.width / scaleX;
				newMeasuredHeight = super.height / scaleY;
			}
				
			if 	(	newMeasuredWidth != _measuredWidth
				||	newMeasuredHeight != _measuredHeight
				)
			{
				var event:DisplayObjectEvent
						= new DisplayObjectEvent
							( DisplayObjectEvent.MEDIA_SIZE_CHANGE, false, false
							, null			, null
							, _measuredWidth	, _measuredHeight
							, newMeasuredWidth	, newMeasuredHeight
							);
							
				_measuredWidth = newMeasuredWidth;
				_measuredHeight = newMeasuredHeight;
				
				dispatchEvent(event);
			}
		}
		
	 	/**
		 * Method that informs the implementation that it should update its
		 * display to adjust to the given available width and height.
		 *  
	 	 * @param availableWidth
	 	 * @param availableHeight
	 	 * @param deep True if the layout request is to be forwarded to
		 * the target's potential inner layout system. The forwarding should take
		 * place only after the target has laid itself out.
	 	 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
	 	public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true):void
	 	{
	 		if (renderers.containerRenderer == null)
	 		{
	 			super.width = availableWidth;
	 			super.height = availableHeight;
	 		}
	 		else if (deep)
	 		{
	 			renderers.containerRenderer.layout(availableWidth, availableHeight);
	 		}
	 	}
	 	
	 	/**
		 * @private
		 */
		public function validateNow():void
		{
			if (renderers.containerRenderer)
			{
				renderers.containerRenderer.validateNow();
			}
		}
		
		// Protected
		//
		
		
		/**
		 * @private
		 **/
		protected function onAddChildAt(event:LayoutTargetEvent):void
		{
			addChildAt(event.displayObject, event.index);
		}
		
		/**
		 * @private
		 **/
		protected function onRemoveChild(event:LayoutTargetEvent):void
		{
			removeChild(event.displayObject);	
		}
		
		/**
		 * @private
		 **/
		protected function onSetChildIndex(event:LayoutTargetEvent):void
		{
			setChildIndex(event.displayObject, event.index);	
		}
		
	 	// Overrides
		//
		
		/**
		 * @private
		 **/
		override public function set width(value:Number):void
		{
			_layoutMetadata.width = value; 
		}
		
		/**
		 * @private
		 **/
		override public function get width():Number
		{
			return _measuredWidth;
		}
		
		/**
		 * @private
		 **/
		override public function set height(value:Number):void
		{
			_layoutMetadata.height = value; 
		}
		
		/**
		 * @private
		 **/
		override public function get height():Number
		{
			return _measuredHeight;
		}
		
		// Private
		//
		
		private var _layoutMetadata:LayoutMetadata;
		private var _measuredWidth:Number = NaN;
		private var _measuredHeight:Number = NaN;
		private var renderers:LayoutTargetRenderers;
	}
}