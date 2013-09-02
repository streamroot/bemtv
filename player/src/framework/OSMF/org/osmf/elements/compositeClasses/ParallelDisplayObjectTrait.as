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
	import flash.utils.Dictionary;
	
	import org.osmf.containers.IMediaContainer;
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.MediaElementLayoutTarget;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;

	/**
	 * The view property of the composite trait of a parallel composition refers to a
	 * DisplayObjectContainer implementing instance, that holds each of the composition's
	 * view children's DisplayObject.
	 * 
	 * The bounds of the container determine the size of the composition.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	internal class ParallelDisplayObjectTrait extends CompositeDisplayObjectTrait
	{
		/**
		 * Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function ParallelDisplayObjectTrait(traitAggregator:TraitAggregator, owner:MediaElement)
		{
			super(traitAggregator, owner);
			
			traitAggregationHelper = new TraitAggregationHelper
				( traitType
				, traitAggregator
				, processAggregatedChild
				, processUnaggregatedChild
				);

			// Add all of our children to the layout renderer:
			for (var i:int = 0; i < this.owner.numChildren; i++)
			{
				var child:MediaElement = this.owner.getChildAt(i);
				
				var target:MediaElementLayoutTarget = MediaElementLayoutTarget.getInstance(child);
				target.addEventListener
					( ContainerChangeEvent.CONTAINER_CHANGE
					, onLayoutTargetContainerChange
					);
				
				mediaElementLayoutTargets[child] = target;
				setupLayoutTarget(target);
			}
		}
		
		// Overrides
		//
		
		override public function dispose():void
		{
			traitAggregationHelper.detach();
			traitAggregationHelper = null;
			
			super.dispose();
		}
		
		// Internals
		//

		private function processAggregatedChild(childTrait:MediaTraitBase, child:MediaElement):void
		{
			var layoutTarget:MediaElementLayoutTarget = mediaElementLayoutTargets[child];
			
			if (layoutTarget == null)
			{
				var target:MediaElementLayoutTarget = MediaElementLayoutTarget.getInstance(child);
				
				child.addEventListener
					( ContainerChangeEvent.CONTAINER_CHANGE
					, onLayoutTargetContainerChange
					);
				
				mediaElementLayoutTargets[child] = target;
				
				// [kimi-llnw] setup the index to reflect the position in list
				var targetLayoutMetadata:LayoutMetadata = target.layoutMetadata;
				if (targetLayoutMetadata == null)
				{
					targetLayoutMetadata = new LayoutMetadata();
					target.mediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, targetLayoutMetadata);
				}
				
				if ( isNaN(targetLayoutMetadata.index))
				{
					targetLayoutMetadata.index = owner.getChildIndex(child);
				}
				
				setupLayoutTarget(target);
			}	
		}
		
		private function processUnaggregatedChild(childTrait:MediaTraitBase, child:MediaElement):void
		{
			var target:MediaElementLayoutTarget = mediaElementLayoutTargets[child];
				
			child.removeEventListener
				( ContainerChangeEvent.CONTAINER_CHANGE
				, onLayoutTargetContainerChange
				);
			
			if (layoutRenderer.hasTarget(target))
			{
				layoutRenderer.removeTarget(target);
			}
			
			delete mediaElementLayoutTargets[child];
		}
		
		private function setupLayoutTarget(target:MediaElementLayoutTarget):void
		{
			var container:IMediaContainer = target.mediaElement.container; 
			if (container && container != owner.container)
			{
				if (layoutRenderer.hasTarget(target))
				{
					layoutRenderer.removeTarget(target);	
				}
			}
			else
			{
				if (layoutRenderer.hasTarget(target) == false)
				{
					layoutRenderer.addTarget(target);
				}
			}
		}
		
		private function onLayoutTargetContainerChange(event:ContainerChangeEvent):void
		{
			var mediaElement:MediaElement = event.target as MediaElement;
			
			setupLayoutTarget(mediaElementLayoutTargets[mediaElement]);
		}

		private var traitAggregationHelper:TraitAggregationHelper;
		private var mediaElementLayoutTargets:Dictionary = new Dictionary();
	}
}