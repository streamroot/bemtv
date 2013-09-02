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
	import flash.display.DisplayObject;
	import flash.events.Event;

	/**
	 * @private
	 *
	 * Defines the events that can be dispatched on a ILayoutTarget. ILayoutTargets
	 * are not expected to dispatch these events directly: instead LayoutRenderer
	 * and MediaElementLayoutTarget dispatch these events via ILayoutTarget instances
	 * to inform them about what layout renderer they are layoutTargetted by, or of what
	 * layout renderer they got set as the container.
	 * 
	 */	
	public class LayoutTargetEvent extends Event
	{
		/**
		 * @private
		 * 
		 * Constant that defines the value of the type property of the event object for
		 * a setAsLayoutRendererContainer event.
		 * 
		 * @eventType SET_AS_LAYOUT_RENDERER_CONTAINER 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const SET_AS_LAYOUT_RENDERER_CONTAINER:String = "setAsLayoutRendererContainer";
		
		/**
		 * @private
		 * 
		 * Constant that defines the value of the type property of the event object for
		 * a unsetAsLayoutRendererContainer event.
		 * 
		 * @eventType UNSET_AS_LAYOUT_RENDERER_CONTAINER 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const UNSET_AS_LAYOUT_RENDERER_CONTAINER:String = "unsetAsLayoutRendererContainer";
		
		/**
		 * @private
		 * 
		 * Constant that defines the value of the type property of the event object for
		 * a addToLayoutRenderer event.
		 * 
		 * @eventType ADD_TO_LAYOUT_RENDERER 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const ADD_TO_LAYOUT_RENDERER:String = "addToLayoutRenderer";
		
		/**
		 * @private
		 * 
		 * Constant that defines the value of the type property of the event object for
		 * a removeFromLayoutRenderer event.
		 * 
		 * @eventType REMOVE_FROM_LAYOUT_RENDERER 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const REMOVE_FROM_LAYOUT_RENDERER:String = "removeFromLayoutRenderer";
		
		/**
		 * @private
		 * 
		 * Constant that defines the value of the type property of the event object for
		 * a addChildAt event.
		 * 
		 * @eventType ADD_CHILD_AT 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const ADD_CHILD_AT:String = "addChildAt";
		
		/**
		 * @private
		 * 
		 * Constant that defines the value of the type property of the event object for
		 * a removeChild event.
		 * 
		 * @eventType REMOVE_CHILD 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const REMOVE_CHILD:String = "removeChild";
		
		/**
		 * @private
		 * 
		 * Constant that defines the value of the type property of the event object for
		 * a setChildIndex event.
		 * 
		 * @eventType SET_CHILD_INDEX 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const SET_CHILD_INDEX:String = "setChildIndex";
		
		/**
		 * @private
		 * 
		 * Constructor
		 *  
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * @param layoutRenderer
		 * @param layoutTarget
		 * @param displayObject
		 * @param index
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function LayoutTargetEvent
							( type:String, bubbles:Boolean=false, cancelable:Boolean=false
							, layoutRenderer:LayoutRendererBase = null
							, layoutTarget:ILayoutTarget = null
							, displayObject:DisplayObject = null
							, index:int = -1
							)
		{
			_layoutRenderer = layoutRenderer;
			_layoutTarget = layoutTarget;
			_displayObject = displayObject;
			_index = index;
			super(type, bubbles, cancelable);
		}
		
		/**
		 * @private
		 * 
		 * Defines the layout renderer associated with the event.
		 */		
		public function get layoutRenderer():LayoutRendererBase
		{
			return _layoutRenderer;
		}
		
		public function get layoutTarget():ILayoutTarget
		{
			return _layoutTarget;
		}
		
		public function get displayObject():DisplayObject
		{
			return _displayObject;
		}
		
		public function get index():int
		{
			return _index;
		}
		
		// Overrides
		//
		
		/**
		 * @private
		 */		
		override public function clone():Event
		{
			return new LayoutTargetEvent
						( type, bubbles, cancelable
						, _layoutRenderer
						, _layoutTarget
						, _displayObject
						, _index
						);
		}
		
		// Internals
		//
		
		private var _layoutRenderer:LayoutRendererBase;
		private var _layoutTarget:ILayoutTarget;
		private var _displayObject:DisplayObject;
		private var _index:int;
	}
}