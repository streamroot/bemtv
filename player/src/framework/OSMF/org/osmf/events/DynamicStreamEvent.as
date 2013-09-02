/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.events
{
	import flash.events.Event;
	
	/**
	 * A DynamicStreamEvent is dispatched when the properties of a DynamicStreamTrait
	 * change.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */		
	public class DynamicStreamEvent extends Event
	{
		/**
		 * The DynamicStreamEvent.SWITCHING_CHANGE constant defines the value
		 * of the type property of the event object for a switchingChange
		 * event.
		 * 
		 * @eventType SWITCHING_CHANGE  
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public static const SWITCHING_CHANGE:String = "switchingChange";
		
		/**
		 * The DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE constant defines the value
		 * of the type property of the event object for a numDynamicStreamsChange
		 * event.
		 * 
		 * @eventType NUM_DYNAMIC_STREAMS_CHANGE 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public static const NUM_DYNAMIC_STREAMS_CHANGE:String = "numDynamicStreamsChange";
		
		/**
		 * The DynamicStreamEvent.AUTO_SWITCH_CHANGE constant defines the value
		 * of the type property of the event object for an autoSwitchChange
		 * event.
		 * 
		 * @eventType AUTO_SWITCH_CHANGE 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public static const AUTO_SWITCH_CHANGE:String = "autoSwitchChange";
		
		/**
		 * Constructor.
		 * 
		 * @param type Event type.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented. 
		 * @param switching The new switching value.
		 * @param autoSwitch The new autoSwitch value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function DynamicStreamEvent
			( type:String
			, bubbles:Boolean=false
			, cancelable:Boolean=false
			, switching:Boolean=false
			, autoSwitch:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_switching = switching;
			_autoSwitch = autoSwitch;
		}
		
		/**
		 * The new switching value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get switching():Boolean
		{
			return _switching;
		}
		
		/**
		 * The new autoSwitch value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get autoSwitch():Boolean
		{
			return _autoSwitch;
		}

		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new DynamicStreamEvent(type, bubbles, cancelable, _switching, _autoSwitch);
		}
		
		private var _switching:Boolean;	
		private var _autoSwitch:Boolean;
	}
}
