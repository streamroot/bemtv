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
	 * A BufferEvent is dispatched when the properties of a BufferTrait change.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class BufferEvent extends Event
	{
		/**
		 * The BufferEvent.BUFFERING_CHANGE constant defines the value
		 * of the type property of the event object for a bufferingChange
		 * event.
		 * 
		 * @eventType BUFFERING_CHANGE
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const BUFFERING_CHANGE:String = "bufferingChange";

		/**
		 * The BufferEvent.BUFFER_TIME_CHANGE constant defines the value
		 * of the type property of the event object for a bufferTimeChange
		 * event.
		 * 
		 * @eventType BUFFER_TIME_CHANGE
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const BUFFER_TIME_CHANGE:String = "bufferTimeChange";

		/**
		 * Constructor.
		 * 
		 * @param type The type of the event.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
 		 * @param buffering Specifies whether or not the trait is currently buffering. 
 		 * @param time The new bufferTime for the trait. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function BufferEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, buffering:Boolean=false, bufferTime:Number=NaN)
		{
			super(type, bubbles, cancelable);

			_buffering = buffering;
			_bufferTime = bufferTime;
		}
		
		/**
		 * New value of <code>buffering</code> resulting from this change.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get buffering():Boolean
		{
			return _buffering;
		}
		
		/**
		 * New value of <code>bufferTime</code> resulting from this change.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get bufferTime():Number
		{
			return _bufferTime;
		}

		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new BufferEvent(type, bubbles, cancelable, _buffering, _bufferTime);
		}  
		
		// Internals
		//
		
		private var _buffering:Boolean;
		private var _bufferTime:Number;
	}
}