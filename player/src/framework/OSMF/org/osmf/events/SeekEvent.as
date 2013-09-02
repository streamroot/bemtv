/******************************************************
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
	 * A SeekEvent is dispatched when the properties of a SeekTrait change.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class SeekEvent extends Event
	{
		/**
		 * The SeekEvent.SEEKING_CHANGE constant defines the value
		 * of the type property of the event object for a seekingChange
		 * event.
		 * 
		 * @eventType SEEKING_CHANGE  
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const SEEKING_CHANGE:String = "seekingChange";
		
		/**
		 * 
		 * @param type Event type.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
 		 * @param seeking The new seeking state.
		 * @param time The seek's target time, in seconds.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function SeekEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, seeking:Boolean=false, time:Number=NaN)
		{
			super(type, bubbles, cancelable);

			_seeking = seeking;
			_time = time;
		}
		
		/**
		 * The new seeking state.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get seeking():Boolean
		{
			return _seeking;
		}
		/**
		 * The seek's target time in seconds.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get time():Number
		{
			return _time;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new SeekEvent(type, bubbles, cancelable, _seeking, _time);
		}
		
		// Internals
		//
		
		private var _seeking:Boolean = false;
		private var _time:Number;
	}
}