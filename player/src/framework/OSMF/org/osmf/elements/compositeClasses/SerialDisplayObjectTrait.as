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
package org.osmf.elements.compositeClasses
{

	import org.osmf.containers.IMediaContainer;
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.layout.MediaElementLayoutTarget;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;

	/**
	 * Composite DisplayObjectTrait for serial elements.
	 * 
	 * The view characteristics of a serial composition are identical to the view
	 * characteristics of the active child of that serial composition.
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	internal class SerialDisplayObjectTrait extends CompositeDisplayObjectTrait implements IReusable
	{
		/**
		 * Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function SerialDisplayObjectTrait(traitAggregator:TraitAggregator, owner:MediaElement)
		{
			super(traitAggregator, owner);

			traitAggregationHelper = new TraitAggregationHelper
				( traitType
				, traitAggregator
				, processAggregatedChild
				, processUnaggregatedChild
				);
			
			// In order to forward the serial's active child's view, we need
			// to track the serial's active child:
			traitAggregator.addEventListener
				( TraitAggregatorEvent.LISTENED_CHILD_CHANGE
				, onListenedChildChange
				);
			
			// Setup the current active child:
			setupLayoutTarget(traitAggregator.listenedChild);
		}
		
		/**
		 * @private
		 */
		public function attach():void
		{			
			traitAggregationHelper.attach();
			
			addToRenderer();
		}
		
		/**
		 * @private
		 */
		public function detach():void
		{			
			traitAggregationHelper.detach();
			
			removeFromRenderer();
		}

		// Internals
		//
		
		/**
		 * Invoked on the serial's active child changing.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		private function onListenedChildChange(event:TraitAggregatorEvent):void
		{
			setupLayoutTarget(event.newListenedChild);
		}
		
		private function onTargetContainerChange(event:ContainerChangeEvent):void
		{
			var oldContainer:IMediaContainer = event.oldContainer;
			var newContainer:IMediaContainer = event.newContainer;
			var element:MediaElement = layoutTarget.mediaElement;
			
			var targetInLayoutRenderer:Boolean
				= layoutRenderer.hasTarget(layoutTarget);
				
			if (newContainer == null || newContainer == owner.container)
			{
				if (targetInLayoutRenderer == false)
				{
					layoutRenderer.addTarget(layoutTarget);
				}
			}
			else
			{ 
				if (targetInLayoutRenderer)
				{					
					layoutRenderer.removeTarget(layoutTarget);
				}
			}
		}
		
		private function setupLayoutTarget(listenedChild:MediaElement):void
		{			
			if (layoutTarget != null)
			{
				layoutTarget.mediaElement.removeEventListener
					( ContainerChangeEvent.CONTAINER_CHANGE
					, onTargetContainerChange
					);
				
				removeFromRenderer();
			}
				
			if (listenedChild != null)
			{
				layoutTarget = MediaElementLayoutTarget.getInstance(listenedChild);
				
				listenedChild.addEventListener
					( ContainerChangeEvent.CONTAINER_CHANGE
					, onTargetContainerChange
					);
					
				onTargetContainerChange
					( new ContainerChangeEvent
						( ContainerChangeEvent.CONTAINER_CHANGE
						, false
						, false
						, null
						, layoutTarget.mediaElement.container
						)
					);
			}
		}
		
		private function addToRenderer():void
		{
			if (traitAggregator.listenedChild != null)
			{
				layoutTarget = MediaElementLayoutTarget.getInstance(traitAggregator.listenedChild)
				if (!layoutRenderer.hasTarget(layoutTarget))
				{
					layoutRenderer.addTarget(layoutTarget);
					childrenContainer.measure(true);	
				}	
			}
			
		}
		
		private function removeFromRenderer():void
		{
			if (traitAggregator.listenedChild != null)
			{
				layoutTarget = MediaElementLayoutTarget.getInstance(traitAggregator.listenedChild)
				if (layoutRenderer.hasTarget(layoutTarget))
				{
					layoutRenderer.removeTarget(layoutTarget);	
				}
			}
			
		}
		
		private function processAggregatedChild(child:MediaTraitBase):void
		{
			// Stub method, needed by the helper class.
		}

		private function processUnaggregatedChild(child:MediaTraitBase):void
		{
			// Stub method, needed by the helper class.
		}
		
		private var traitAggregationHelper:TraitAggregationHelper;
		private var layoutTarget:MediaElementLayoutTarget;
	}
}