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
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataWatcher;
	import org.osmf.utils.OSMFStrings;

	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	}

	/**
	 * LayoutRendererBase is the base class for custom layout renderers.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	/*
	 * Implementation details:
	 *  
	 * The class provides a number of facilities:
	 * 
	 *  * A base implementation for collecting and managing layout layoutTargets.
	 *  * A base implementation for metadata watching: override usedMetadataFacets to
	 *    return the set of metadata facet namespaces thatyour renderer reads from its
	 *    target on rendering them. All specified facets will be watched for change, at
	 *    which the invalidate methods gets invoked.
	 *  * A base invalidation scheme that postpones rendering until after all other frame
	 *    scripts have finished executing, by means of managing a dirty flag an a listener
	 *    to Flash's EXIT_FRAME event. The invokation of validateNow will always result
	 *    in the 'render' method being invoked right away.
	 * 
	 * On doing a subclass, the render method must be overridden.
	 * 
	 * Optionally, the following protected methods may be overridden:
	 * 
	 *  * get usedMetadatas, used when layoutTargets get added or removed, to add
	 *    change watchers that will trigger invalidation of the renderer.
	 *  * compareTargets, which is used to put the layoutTargets in a particular display
	 *    list index order.
	 * 
	 *  * processContainerChange, invoked when the renderer's container changed.
	 *  * processStagedTarget, invoked when a target is put on the stage of the
	 *    container's displayObjectContainer.
	 *  * processUnstagedTarget, invoked when a target is removed from the stage
	 *    of the container's displayObjectContainer.  
	 */
	public class LayoutRendererBase extends EventDispatcher
	{
		// LayoutRenderer
		//
		
		/**
		 * Defines the renderer that this renderer is a child of.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		final public function get parent():LayoutRendererBase
		{
			return _parent;	
		}
		
		/**
		 * @private
		 **/
		final internal function setParent(value:LayoutRendererBase):void
		{
			_parent = value;
			processParentChange(_parent);
		}
		
		/**
		 * Defines the container against which the renderer will calculate the size
		 * and position values of its targets. The renderer additionally manages
		 * targets being added and removed as children of the set container's
		 * display list.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		final public function get container():ILayoutTarget
		{
			return _container;
		}
		final public function set container(value:ILayoutTarget):void
		{
			if (value != _container)
			{
				var oldContainer:ILayoutTarget = _container;
				
				if (oldContainer != null)
				{
					reset();
					
					oldContainer.dispatchEvent
						( new LayoutTargetEvent
							( LayoutTargetEvent.UNSET_AS_LAYOUT_RENDERER_CONTAINER
							, false, false, this
							)
						);
					
					oldContainer.removeEventListener
						( DisplayObjectEvent.MEDIA_SIZE_CHANGE
						, invalidatingEventHandler
						);
				}
					
				_container = value;
					
				if (_container)
				{
					layoutMetadata = _container.layoutMetadata;
					
					_container.addEventListener
						( DisplayObjectEvent.MEDIA_SIZE_CHANGE
						, invalidatingEventHandler
						, false, 0, true
						);

					_container.dispatchEvent
						( new LayoutTargetEvent
							( LayoutTargetEvent.SET_AS_LAYOUT_RENDERER_CONTAINER
							, false, false, this
							)
						);
						
					invalidate();
				}
				
				processContainerChange(oldContainer, value);
			}
		}
		
		/**
		 * Method for adding a target to the layout renderer's list of objects
		 * that it calculates the size and position for. Adding a target will
		 * result the associated display object to be placed on the display
		 * list of the renderer's container.
		 * 
		 * @param target The target to add.
		 * @throws IllegalOperationError when the specified target is null, or 
		 * already a target of the renderer.
		 * @returns The added target.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		final public function addTarget(target:ILayoutTarget):ILayoutTarget
		{
			if (target == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			if (layoutTargets.indexOf(target) != -1)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			// Dispatch a ADD_TO_LAYOUT_RENDERER event on the target. This is the cue for
			// the currently owning renderer to remove the target from its listing:
			target.dispatchEvent
				( new LayoutTargetEvent
					( LayoutTargetEvent.ADD_TO_LAYOUT_RENDERER
					, false, false, this
					)
				);
			
			// Get the index where the target should be inserted:
			var index:int = Math.abs(BinarySearch.search(layoutTargets, compareTargets, target));
			
			// Add the target to our listing:
			layoutTargets.splice(index, 0, target);	
			
			// Watch the metadata on the target's collection that we're interested in:
			var watchers:Array = metaDataWatchers[target] = new Array();
			for each (var namespaceURL:String in usedMetadatas)
			{
				var watcher:MetadataWatcher =
					new MetadataWatcher
						( target.layoutMetadata
						, namespaceURL
						, null
						, targetMetadataChangeCallback
						)
					;
				watcher.watch();
				watchers.push(watcher);
			}
			
			// Watch the target's displayObject, dimenions, and layoutRenderer change:
			target.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, invalidatingEventHandler);
			target.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, invalidatingEventHandler);
			
			target.addEventListener(LayoutTargetEvent.ADD_TO_LAYOUT_RENDERER, onTargetAddedToRenderer);
			target.addEventListener(LayoutTargetEvent.SET_AS_LAYOUT_RENDERER_CONTAINER, onTargetSetAsContainer);
			
			invalidate();
			
			processTargetAdded(target);
			
			return target;
		}
		
		/**
		 * Method for removing a target from the layout render's list of objects
		 * that it will render. See addTarget for more information.
		 * 
		 * @param target The target to remove.
		 * @throws IllegalOperationErrror when the specified target is null, or
		 * not a target of the renderer.
		 * @returns The removed target.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		final public function removeTarget(target:ILayoutTarget):ILayoutTarget
		{
			if (target == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			var removedTarget:ILayoutTarget;
			var index:Number = layoutTargets.indexOf(target);
			if (index != -1)
			{
				// Remove the target from the container stage:
				removeFromStage(target);
				
				// Remove the target from our listing:
				removedTarget = layoutTargets.splice(index,1)[0];
				
				// Un-watch the target's displayObject and dimenions change:
				target.removeEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, invalidatingEventHandler);
				target.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, invalidatingEventHandler);
				
				target.removeEventListener(LayoutTargetEvent.ADD_TO_LAYOUT_RENDERER, onTargetAddedToRenderer);
				target.removeEventListener(LayoutTargetEvent.SET_AS_LAYOUT_RENDERER_CONTAINER, onTargetSetAsContainer);
								
				// Remove the metadata change watchers that we added:
				for each (var watcher:MetadataWatcher in metaDataWatchers[target])
				{
					watcher.unwatch();
				}
				
				delete metaDataWatchers[target];
				
				processTargetRemoved(target);
				
				target.dispatchEvent
					( new LayoutTargetEvent
						( LayoutTargetEvent.REMOVE_FROM_LAYOUT_RENDERER
						, false, false, this
						)
					);
					
				invalidate();
			}
			else
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return removedTarget;
		}
		
		/**
		 * Method for querying if a layout target is currently a target of this
		 * layout renderer.
		 *  
		 * @return True if the specified target is a target of this renderer.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		final public function hasTarget(target:ILayoutTarget):Boolean
		{
			return layoutTargets.indexOf(target) != -1;
		}
		
		/**
		 * Defines the width that the layout renderer measured on its last rendering pass.
		 */		
		final public function get measuredWidth():Number
		{
			return _measuredWidth;
		}
		
		/**
		 * Defines the height that the layout renderer measured on its last rendering pass.
		 */		
		final public function get measuredHeight():Number
		{
			return _measuredHeight;
		}
		
		/**
		 * Method that will mark the renderer's last rendering pass invalid. At
		 * the descretion of the implementing instance, the renderer may either
		 * directly re-render, or do so at a later time.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		final public function invalidate():void
		{
			// If we're either cleaning or dirty already, then invalidation
			// is a no-op:
			if (cleaning == false && dirty == false)
			{
				// Raise the 'dirty' flag, signalling that layout need recalculation:
				dirty = true;
				
				if (_parent != null)
				{
					// Forward further processing to our parent:
					_parent.invalidate();
				}
				else
				{
					// Since we don't have a parent, put us in the queue
					// to be recalculated when the next frame exits:
					flagDirty(this);
				}
			}
		}
		
		/**
		 * Method ordering the direct recalculation of the position and size
		 * of all of the renderer's assigned targets. The implementing class
		 * may still skip recalculation if the renderer has not been invalidated
		 * since the last rendering pass. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		final public function validateNow():void
		{
			if (_container == null || cleaning == true)
			{
				// no-op:
				return;	
			}
			
			if (_parent)
			{
				// Have validation triggered from the root-node down:
				_parent.validateNow();
				return;
			}
			
			// This is a root-node. Flag that we're cleaning up:
			cleaning = true;
			
			CONFIG::LOGGING
			{
				logger.debug
					( "layout dimensions before measurement ({0}, {1})"
					, _measuredWidth, _measuredHeight
					);
			}
			measure();
			CONFIG::LOGGING
			{
				logger.debug
					( "layout dimensions after measurement ({0}, {1})"
						, _measuredWidth, _measuredHeight
					);
			}
			
			layout(_measuredWidth, _measuredHeight);
			
			cleaning = false;
		}
		
		/**
		 * @private
		 */
		internal function measure():void
		{
			// Take care of all targets being staged correctly:
			prepareTargets();
			
			// Traverse, execute bottom-up:
			for each (var target:ILayoutTarget in layoutTargets)
			{
				target.measure(true /* deep */);
			}
			
			// Calculate our own size:
			var size:Point = calculateContainerSize(layoutTargets);
			
			_measuredWidth = size.x;
			_measuredHeight = size.y;
			
			_container.measure(false /* shallow */);
		}
		
		/**
		 * @private
		 */
		internal function layout(availableWidth:Number, availableHeight:Number):void
		{
			processUpdateMediaDisplayBegin(layoutTargets);
			
			_container.layout(availableWidth, availableHeight, false /* shallow */);
			
			// Traverse, execute top-down:
			for each (var target:ILayoutTarget in layoutTargets)
			{
				var bounds:Rectangle = calculateTargetBounds(target, availableWidth, availableHeight);
				
				target.layout(bounds.width, bounds.height, true /* deep */);
				
				var displayObject:DisplayObject = target.displayObject;
				if (displayObject)
				{
					displayObject.x = bounds.x;
					displayObject.y = bounds.y;
				}
			}
			
			dirty = false;
			
			processUpdateMediaDisplayEnd();
		}
		
		// Subclass stubs
		//
		
		/**
		 * @private
		 * 
		 * Subclasses may override this method to have it return the list
		 * of URL namespaces that identify the metadata objects that the
		 * renderer uses on its calculations.
		 * 
		 * The base class will make sure that the renderer gets invalidated
		 * when any of the specified metadatas' values change.
		 * 
		 * @return The list of URL namespaces that identify the metadata objects
		 * that the renderer uses on its calculations. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function get usedMetadatas():Vector.<String>
		{
			return new Vector.<String>;
		}
		
		/**
		 * @private
		 *
		 * Subclasses may override this method, providing the algorithm
		 * by which the list of targets gets sorted.
		 * 
		 * @returns -1 if x comes before y, 0 if equal, and 1 if x comes
		 * after y.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function compareTargets(x:ILayoutTarget, y:ILayoutTarget):Number
		{
			// The base comparision function assumes all targets are equal:
			return 0;
		}
		
		/**
		 * @private
		 *
		 * Subclasses may override this method to process the renderer's container
		 * changing.
		 * 
		 * @param oldContainer The old container.
		 * @param newContainer The new container.
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function processContainerChange(oldContainer:ILayoutTarget, newContainer:ILayoutTarget):void
		{	
		}
		
		/**
		 * @private
		 *
		 * Subclasses may override this method to do processing on a target
		 * item being added.
		 *   
		 * @param target The target that has been added.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function processTargetAdded(target:ILayoutTarget):void
		{	
		}
		
		/**
		 * @private
		 *
		 * Subclasses may override this method to do processing on a target
		 * item being removed.
		 *   
		 * @param target The target that has been removed.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function processTargetRemoved(target:ILayoutTarget):void
		{	
		}
		
		/**
		 * @private
		 *
		 * Subclasses may override this method should they require special
		 * processing on the displayObject of a target being staged.
		 *  
		 * @param target The target that is being staged
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function processStagedTarget(target:ILayoutTarget):void
		{	
			// CONFIG::LOGGING { logger.debug("staged: {0}", target.metadata.getFacet(MetadataNamespaces.ELEMENT_ID)); }
		}
		
		/**
		 * @private
		 *
		 * Subclasses may override this method should they require special
		 * processing on the displayObject of a target being unstaged.
		 *  
		 * @param target The target that has been unstaged
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function processUnstagedTarget(target:ILayoutTarget):void
		{	
			// CONFIG::LOGGING { logger.debug("unstaged: {0}", target.metadata.getFacet(MetadataNamespaces.ELEMENT_ID)); }
		}
		
		/**
		 * @private
		 *
		 * Subclasses may override this method should they require special
		 * processing on the layout routine starting it execution.
		 *  
		 * @param targets The targets that are about to be measured.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function processUpdateMediaDisplayBegin(targets:Vector.<ILayoutTarget>):void
		{	
		}
		
		/**
		 * @private
		 *
		 * Subclasses may override this method should they require special
		 * processing on the layout routine completing its execution.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function processUpdateMediaDisplayEnd():void
		{
		}	
		
		/**
		 * @private
		 *
		 * Subclasses should override this method to implement the algorithm by
		 * which the targets of the renderer get sorted.
		 * 
		 * @param target The element to order.
		 */		
		protected function updateTargetOrder(target:ILayoutTarget):void
		{
			var index:int = layoutTargets.indexOf(target);
			if (index != -1)
			{
				layoutTargets.splice(index, 1);
				
				index = Math.abs(BinarySearch.search(layoutTargets, compareTargets, target));
				layoutTargets.splice(index, 0, target);
			}
		}
		
		/**
		 * @private
		 *
		 * Subclasses should override this method to implement the algorithm by which
		 * the position and size of a target gets calculated.
		 * 
		 * @param target The target to calculate the bounds for.
		 * @param availableWidth The width available to the target.
		 * @param availableHeight The height available to the target.
		 * @return The calculated bounds for the specified target.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		protected function calculateTargetBounds(target:ILayoutTarget, availableWidth:Number, availableHeight:Number):Rectangle
		{
			return new Rectangle();
		}
		
		/**
		 * @private
		 *
		 * Subclasses should override this method to implement the algorithm by which
		 * the size of the renderer's container is calculated:
		 * 
		 * @return The calculated size of the renderer's container.
		 */		
		protected function calculateContainerSize(targets:Vector.<ILayoutTarget>):Point
		{
			return new Point();
		}
		
		/**
		 * @private
		 *
		 * Subclasses should override this method to implement to do processing on the
		 * renderer's parent being changed.
		 * 
		 * @value The new parent of the renderer.
		 */
		protected function processParentChange(value:LayoutRendererBase):void
		{	
		}
		
		// Internals
		//
		
		private function reset():void
		{
			for each (var target:ILayoutTarget in layoutTargets)
			{
				removeTarget(target);
			}
			
			if (_container)
			{
				_container.removeEventListener
					( DisplayObjectEvent.MEDIA_SIZE_CHANGE
					, invalidatingEventHandler
					);
						
				// Make sure to update the existing container
				// before we loose it:
				validateNow();
			}
			
			_container = null;
			layoutMetadata = null;
		}
		
		private function targetMetadataChangeCallback(metadata:Metadata):void
		{
			invalidate();
		}
		
		private function invalidatingEventHandler(event:Event):void
		{
			/*
			CONFIG::LOGGING 
			{
				var targetMetadata:Metadata
					= event.target is ILayoutTarget
						? ILayoutTarget(event.target).metadata
						: null;
						
				logger.debug
					( "invalidated: {0} eventType: {1}, target: {2} sender ID: {3}"
					, metadata.getFacet(MetadataNamespaces.ELEMENT_ID)
					, event.type, event.target
					, targetMetadata ? targetMetadata.getFacet(MetadataNamespaces.ELEMENT_ID) : "?" 
					); 
			}
			*/
			invalidate();
		}
		
		private function onTargetAddedToRenderer(event:LayoutTargetEvent):void
		{
			if (event.layoutRenderer != this)
			{
				// The target is being added to another renderer. If we have
				// it on as a target, then remove it from our listing:
				var target:ILayoutTarget = event.target as ILayoutTarget;
				if (hasTarget(target))
				{
					removeTarget(target);
				}
			}
		}
		
		private function onTargetSetAsContainer(event:LayoutTargetEvent):void
		{
			if (event.layoutRenderer != this)
			{
				// Our container is being set as the container to another
				// layout renderer. If this container still is our container,
				// we need to release our own reference:
				var target:ILayoutTarget = event.target as ILayoutTarget;
				if (container == target)
				{
					container = null;
				}
			}	
		}
		
		private function prepareTargets():void
		{
			// Setup a displayObject counter:
			var displayListCounter:int = 0;
			
			for each (var target:ILayoutTarget in layoutTargets)
			{
				var displayObject:DisplayObject = target.displayObject;
				if (displayObject)
				{
					addToStage(target, target.displayObject, displayListCounter);
					displayListCounter++;
				}
				else
				{
					removeFromStage(target);
				}
			}
		}
		
		private function addToStage(target:ILayoutTarget, object:DisplayObject, index:Number):void
		{
			var currentObject:DisplayObject = stagedDisplayObjects[target];
			if (currentObject == object)
			{
				// Make sure that the object is at the right position in the display list:
				
				_container.dispatchEvent
					( new LayoutTargetEvent
						( LayoutTargetEvent.SET_CHILD_INDEX
						, false, false
						, this
						, target
						, currentObject
						, index
						)
					);
			}
			else
			{
				if (currentObject != null)
				{
					
					// Remove the current object:
					_container.dispatchEvent
						( new LayoutTargetEvent
							( LayoutTargetEvent.REMOVE_CHILD
							, false, false
							, this
							, target
							, currentObject
							)
						);
				}
				
				// Add the new object:
				stagedDisplayObjects[target] = object;
				
				_container.dispatchEvent
					( new LayoutTargetEvent
						( LayoutTargetEvent.ADD_CHILD_AT
						, false, false
						, this
						, target
						, object
						, index
						)
					);
				
				// If there wasn't an old object, then trigger the staging processor:
				if (currentObject == null)
				{
					processStagedTarget(target);
				}
			}
		}
		
		private function removeFromStage(target:ILayoutTarget):void
		{
			var currentObject:DisplayObject = stagedDisplayObjects[target];
			if (currentObject != null)
			{
				delete stagedDisplayObjects[target];
				
				_container.dispatchEvent
					( new LayoutTargetEvent
						( LayoutTargetEvent.REMOVE_CHILD
						, false, false
						, this
						, target
						, currentObject
						)
					);
			}
		}
		
		private var _parent:LayoutRendererBase;
		private var _container:ILayoutTarget;		
		private var layoutMetadata:LayoutMetadata;
		
		private var layoutTargets:Vector.<ILayoutTarget> = new Vector.<ILayoutTarget>;
		private var stagedDisplayObjects:Dictionary = new Dictionary(true);
		
		private var _measuredWidth:Number;
		private var _measuredHeight:Number;
		
		private var dirty:Boolean;
		private var cleaning:Boolean;
		
		private var metaDataWatchers:Dictionary = new Dictionary();
		
		// Private Static
		//
		
		private static function flagDirty(renderer:LayoutRendererBase):void
		{
			if (renderer == null || dirtyRenderers.indexOf(renderer) != -1)
			{
				// no-op;
				return;
			}
			
			dirtyRenderers.push(renderer);
			
			if (cleaningRenderers == false)
			{
				dispatcher.addEventListener(Event.EXIT_FRAME, onExitFrame);
			}
		}
		
		private static function flagClean(renderer:LayoutRendererBase):void
		{
			var index:Number = dirtyRenderers.indexOf(renderer);
			if (index != -1)
			{
				dirtyRenderers.splice(index,1);
			}
		}
		
		private static function onExitFrame(event:Event):void
		{
			dispatcher.removeEventListener(Event.EXIT_FRAME, onExitFrame);
			
			cleaningRenderers = true;
			
			CONFIG::LOGGING { logger.debug("ON EXIT FRAME: BEGIN"); }
			
			while (dirtyRenderers.length != 0)
			{
				var renderer:LayoutRendererBase = dirtyRenderers.shift();
				if (renderer.parent == null)
				{
					CONFIG::LOGGING { logger.debug("VALIDATING LAYOUT"); }
					renderer.validateNow();
					CONFIG::LOGGING { logger.debug("LAYOUT VALIDATED"); }
				}
				else
				{
					renderer.dirty = false;
				}
			}
			CONFIG::LOGGING { logger.debug("ON EXIT FRAME: END"); }
			
			cleaningRenderers = false;
		}
		
		private static var dispatcher:DisplayObject = new Sprite();
		private static var cleaningRenderers:Boolean;
		private static var dirtyRenderers:Vector.<LayoutRendererBase> = new Vector.<LayoutRendererBase>;
		
		CONFIG::LOGGING private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.layout.LayoutRendererBase");
	}
}