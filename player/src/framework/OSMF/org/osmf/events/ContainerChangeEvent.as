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
package org.osmf.events
{
	import flash.events.Event;
	
	import org.osmf.containers.IMediaContainer;

	/**
	 * A ContainerChangeEvent is dispatched when a reference to an IMediaContainer changes.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class ContainerChangeEvent extends Event
	{
		/**
		 * The ContainerChangeEvent.CONTAINER_CHANGE constant defines the value
		 * of the type property of the event object for a containerChange
		 * event.
		 * 
		 * @eventType CONTAINER_CHANGE
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const CONTAINER_CHANGE:String = "containerChange";
		
		/**
		 * Constructor.
		 * 
		 * @param type Event type.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented. 
		 * @param oldContainer Old IMediaContainer reference.
		 * @param newContainer New IMediaContainer reference.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function ContainerChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, oldContainer:IMediaContainer=null, newContainer:IMediaContainer=null)
		{
			super(type, bubbles, cancelable);
			
			_oldContainer = oldContainer;
			_newContainer = newContainer;
		}
		
		/**
		 * Defines the old container reference.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get oldContainer():IMediaContainer
		{
			return _oldContainer;
		}
		
		/**
		 * Defines the new container reference.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get newContainer():IMediaContainer
		{
			return _newContainer;
		}
		
		// Overrides
		//
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new ContainerChangeEvent(type, bubbles, cancelable, _oldContainer, _newContainer);
		}
		
		// Internals
		//
		
		private var _oldContainer:IMediaContainer;
		private var _newContainer:IMediaContainer;
	}
}