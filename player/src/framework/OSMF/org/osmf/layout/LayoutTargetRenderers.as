/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.layout
{
	/**
	 * @private 
	 *
	 * Utility class that manages correctly parenting the layout renderers
	 * that are associated with an ILayoutTarget implementing object.
	 * 
	 * The object helps ILayoutTarget implementations to manage their
	 * internal references to the layout renderers that they get assigned via
	 * the receival of LayoutTargetEvents.
	 */	
	internal class LayoutTargetRenderers
	{
		/**
		 * @private 
		 *
		 * Constructor
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function LayoutTargetRenderers(target:ILayoutTarget)
		{
			target.addEventListener(LayoutTargetEvent.ADD_TO_LAYOUT_RENDERER, onAddedToLayoutRenderer);
			target.addEventListener(LayoutTargetEvent.REMOVE_FROM_LAYOUT_RENDERER, onRemovedFromLayoutRenderer);
			
			target.addEventListener(LayoutTargetEvent.SET_AS_LAYOUT_RENDERER_CONTAINER, onSetAsLayoutRendererContainer);
			target.addEventListener(LayoutTargetEvent.UNSET_AS_LAYOUT_RENDERER_CONTAINER, onUnsetAsLayoutRendererContainer);
		}
		
		/**
		 * @private
		 * 
		 * Defines the layout renderer that the target object is the container of.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	 
		public var containerRenderer:LayoutRendererBase;
		
		/**
		 * @private
		 * 
		 * Defines the layout renderer that the target object is a target of.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public var parentRenderer:LayoutRendererBase;
		
		// Internals
		//
		
		private function onSetAsLayoutRendererContainer(event:LayoutTargetEvent):void
		{
			if (containerRenderer != event.layoutRenderer)
			{
				// This target is being used as a container. Store a reference to
				// the render for which we act as a container:
				containerRenderer = event.layoutRenderer;
				
				// If we have a targetting renderer set already, then that's the
				// parent parent of the container renderer:
				containerRenderer.setParent(parentRenderer);
				
			}
		}
		
		private function onUnsetAsLayoutRendererContainer(event:LayoutTargetEvent):void
		{
			if (containerRenderer != null && containerRenderer == event.layoutRenderer)
			{
				// This target is no longer being used as a container. Release
				// the reference to the container renderer:
				containerRenderer.setParent(null);
				containerRenderer = null;
			}
		}
		
		private function onAddedToLayoutRenderer(event:LayoutTargetEvent):void
		{
			if (parentRenderer != event.layoutRenderer)
			{
				// The target is added to a layout renderer. Store a reference
				// to the renderer that is targetting us:
				parentRenderer = event.layoutRenderer;
				if (containerRenderer)
				{
					// The renderer for which we are the container, should
					// now be parented by the renderer that targets us:
					containerRenderer.setParent(parentRenderer);
				}
			}
		}
		
		private function onRemovedFromLayoutRenderer(event:LayoutTargetEvent):void
		{
			if (parentRenderer == event.layoutRenderer)
			{
				// We're no longer being targetted by the given renderer. Release
				// the reference:
				parentRenderer = null;
				if (containerRenderer)
				{
					// The renderer for which we are the container is now without
					// a parent:
					containerRenderer.setParent(null);
				}
			}	
		}
	}
}