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
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFStrings;
	
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
	 * @private
	 * 
	 * Class wraps a MediaElement into a ILayoutChild.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class MediaElementLayoutTarget extends EventDispatcher implements ILayoutTarget
	{
		/**
		 * @private
		 * 
		 * Constructor. For internal use only: to obtain a MediaElementLayoutTarget instance
		 * use the getInstance method. This ensures that there's no more than one MediaElementLayoutTarget
		 * instance per MediaElement instance.
		 * 
		 * @param mediaElement
		 * @param constructorLock
		 */		
		public function MediaElementLayoutTarget(mediaElement:MediaElement, constructorLock:Class)
		{
			if (constructorLock != ConstructorLock)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ILLEGAL_CONSTRUCTOR_INVOCATION));
			}
			else
			{
				_mediaElement = mediaElement;
				_mediaElement.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementTraitsChange);
				_mediaElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaElementTraitsChange);
				_mediaElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
				_mediaElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onMetadataRemove);
				
				renderers = new LayoutTargetRenderers(this);
				
				_layoutMetadata = _mediaElement.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
				
				addEventListener(LayoutTargetEvent.ADD_CHILD_AT, onAddChildAt);
				addEventListener(LayoutTargetEvent.SET_CHILD_INDEX, onSetChildIndex);
				addEventListener(LayoutTargetEvent.REMOVE_CHILD, onRemoveChild);
				
				onMediaElementTraitsChange();
			}
		}
		
		public function get mediaElement():MediaElement
		{
			return _mediaElement;
		}
		
		// ILayoutTarget
		//
		
		/**
		 * @private
		 */
		public function get layoutMetadata():LayoutMetadata
		{
			// Make sure we always return a non-null value.
			if (_layoutMetadata == null)
			{
				_layoutMetadata = new LayoutMetadata();
				_mediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, _layoutMetadata);
			}

			return _layoutMetadata;
		}

		/**
		 * @private
		 */
		public function get displayObject():DisplayObject
		{
			return _displayObject;
		}
		
		/**
		 * @private
		 */
		public function get measuredWidth():Number
		{
			return displayObjectTrait
				 ? displayObjectTrait.mediaWidth
				 : NaN;
		}
		
		/**
		 * @private
		 */
		public function get measuredHeight():Number
		{
			return displayObjectTrait
				 ? displayObjectTrait.mediaHeight
				 : NaN;
		}
		
		/**
		 * @private
		 */
		public function measure(deep:Boolean = true):void
		{
			if (_displayObject is ILayoutTarget)
			{
				ILayoutTarget(_displayObject).measure(deep);
			}
		}
		
		/**
		 * @private
		 */
		public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true):void
		{
			if (_displayObject is ILayoutTarget)
			{
				ILayoutTarget(_displayObject).layout(availableWidth, availableHeight, deep);
			}
			else if (_displayObject != null && renderers.containerRenderer == null)
			{
				_displayObject.width = availableWidth;
				_displayObject.height = availableHeight;
			} 
		}
		
		// Public interface
		//
		
		public static function getInstance(mediaElement:MediaElement):MediaElementLayoutTarget
		{
			var instance:*;
			for (instance in layoutTargets)
			{
				if (instance.mediaElement == mediaElement)
				{
					break;
				}
				else
				{
					instance = null;
				}
			}
			
			if (instance == null)
			{
				instance = new MediaElementLayoutTarget(mediaElement, ConstructorLock);
				layoutTargets[instance] = true;
			}
			
			return instance;
		}
		
		// Internals
		//
		
		private var _mediaElement:MediaElement;
		private var _layoutMetadata:LayoutMetadata;
		
		private var displayObjectTrait:DisplayObjectTrait;
		private var _displayObject:DisplayObject;
		
		private var renderers:LayoutTargetRenderers;
		
		// Event Handlers
		//
		
		private function onMediaElementTraitsChange(event:MediaElementEvent = null):void
		{
			if ( event == null || (event && event.traitType == MediaTraitType.DISPLAY_OBJECT))
			{
				var newDisplayObjectTrait:DisplayObjectTrait 
					= (event && event.type == MediaElementEvent.TRAIT_REMOVE)
						? null
						: _mediaElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
								
				if (newDisplayObjectTrait != displayObjectTrait)
				{
					if (displayObjectTrait)
					{
						displayObjectTrait.removeEventListener
							( DisplayObjectEvent.DISPLAY_OBJECT_CHANGE
							, onDisplayObjectTraitDisplayObjecChange
							);
						
						displayObjectTrait.removeEventListener
							( DisplayObjectEvent.MEDIA_SIZE_CHANGE
							, onDisplayObjectTraitMediaSizeChange
							);
					}
					
					displayObjectTrait = newDisplayObjectTrait;
					
					if (displayObjectTrait)
					{
						displayObjectTrait.addEventListener
							( DisplayObjectEvent.DISPLAY_OBJECT_CHANGE
							, onDisplayObjectTraitDisplayObjecChange
							);
						
						displayObjectTrait.addEventListener
							( DisplayObjectEvent.MEDIA_SIZE_CHANGE
							, onDisplayObjectTraitMediaSizeChange
							);
					}
					
					updateDisplayObject
						( displayObjectTrait
							? displayObjectTrait.displayObject
							: null
						);
				}
			}
		}
		
		private function onMetadataAdd(event:MediaElementEvent):void
		{
			if (event.namespaceURL == LayoutMetadata.LAYOUT_NAMESPACE)
			{
				_layoutMetadata = event.metadata as LayoutMetadata;
			}
		}

		private function onMetadataRemove(event:MediaElementEvent):void
		{
			if (event.namespaceURL == LayoutMetadata.LAYOUT_NAMESPACE)
			{
				_layoutMetadata = null;
			}
		}
		
		private function updateDisplayObject(newDisplayObject:DisplayObject):void
		{
			var oldDisplayObject:DisplayObject = _displayObject;
			if (newDisplayObject != displayObject)
			{
				_displayObject = newDisplayObject;
				dispatchEvent
					( new DisplayObjectEvent
						( DisplayObjectEvent.DISPLAY_OBJECT_CHANGE
						, false, false
						, oldDisplayObject
						, newDisplayObject
						)
					);	
			}
			
			if	(	newDisplayObject is ILayoutTarget
				&&	renderers.parentRenderer
				)
			{
				// This media element is targetted by a renderer. Send a 
				// fake event to the target, indicating that the target
				// has now become the child of this very same renderer.
				// This will make sure that the target's renderer gets
				// parented correctly:
				ILayoutTarget(newDisplayObject).dispatchEvent
					( new LayoutTargetEvent
						( LayoutTargetEvent.ADD_TO_LAYOUT_RENDERER
						, false, false, renderers.parentRenderer
						)
					);
			}
		}
		
		private function onDisplayObjectTraitDisplayObjecChange(event:DisplayObjectEvent):void
		{
			updateDisplayObject(event.newDisplayObject);
		}
		
		private function onDisplayObjectTraitMediaSizeChange(event:DisplayObjectEvent):void
		{
			dispatchEvent(event.clone());	
		}
		
		private function onAddChildAt(event:LayoutTargetEvent):void
		{
			if (_displayObject is ILayoutTarget)
			{
				ILayoutTarget(_displayObject)
					.dispatchEvent(event.clone());
			}
			else if (_displayObject is DisplayObjectContainer)
			{
				DisplayObjectContainer(_displayObject)
					.addChildAt(event.displayObject, event.index);
			}
		}
		
		private function onRemoveChild(event:LayoutTargetEvent):void
		{
			if (_displayObject is ILayoutTarget)
			{
				ILayoutTarget(_displayObject)
					.dispatchEvent(event.clone());
			}
			else if (_displayObject is DisplayObjectContainer)
			{
				DisplayObjectContainer(_displayObject)
					.removeChild(event.displayObject);
			}	
		}
		
		private function onSetChildIndex(event:LayoutTargetEvent):void
		{
			if (_displayObject is ILayoutTarget)
			{
				ILayoutTarget(_displayObject)
					.dispatchEvent(event.clone());
			}
			else if (_displayObject is DisplayObjectContainer)
			{
				DisplayObjectContainer(_displayObject)
					.setChildIndex(event.displayObject, event.index);
			}	
		}
		
		/* Static */
		
		private static const layoutTargets:Dictionary = new Dictionary(true);
	}
}
	
/**
 * Internal class, used to prevent the MediaElementLayoutTarget constructor
 * to run successfully on being invoked outside of this class.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion OSMF 1.0
 */
class ConstructorLock
{
}