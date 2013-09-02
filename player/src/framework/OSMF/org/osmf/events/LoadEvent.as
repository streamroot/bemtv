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
	
	/**
	 * A LoadEvent is dispatched when the properties of a LoadTrait change.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 *  @productversion FLEXOSMF 4.0
	 */
	public class LoadEvent extends Event
	{
		/**
		 * The LoadEvent.LOAD_STATE_CHANGE constant defines the value
		 * of the type property of the event object for a loadStateChange
		 * event.
		 * 
		 * @eventType loadStateChange
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public static const LOAD_STATE_CHANGE:String = "loadStateChange";

		/**
		 * The LoadEvent.BYTES_LOADED_CHANGE constant defines the value
		 * of the type property of the event object for a bytesLoadedChange
		 * event.
		 * 
		 * @eventType bytesLoadedChange
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public static const BYTES_LOADED_CHANGE:String = "bytesLoadedChange";
		
		/**
		 * The LoadEvent.BYTES_TOTAL_CHANGE constant defines the value
		 * of the type property of the event object for a bytesTotalChange
		 * event.
		 * 
		 * @eventType bytesTotalChange
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public static const BYTES_TOTAL_CHANGE:String = "bytesTotalChange";
		
		/**
		 * Constructor.
		 * 
		 * @param type Event type.
 		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented. 
		 * @param loadState New LoadState of the LoadTrait.
		 * @param bytes New value of bytesLoaded or bytesTotal. Returns NaN when media is unloaded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public function LoadEvent
							( type:String,
							  bubbles:Boolean=false,
							  cancelable:Boolean=false,
							  loadState:String=null,
							  bytes:Number=NaN
							)
		{
			super(type, bubbles, cancelable);
			
			_loadState = loadState;
			_bytes = bytes;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new LoadEvent(type, bubbles, cancelable, loadState, bytes);
		}

		/**
		 * New LoadState of the LoadTrait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public function get loadState():String
		{
			return _loadState;
		}

		/**
		 * New value of bytesLoaded or bytesTotal.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public function get bytes():Number
		{
			return _bytes;
		}
		
		// Internals
		//
		
		private var _loadState:String;
		private var _bytes:Number;
	}
}
