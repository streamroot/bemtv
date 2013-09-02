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
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The BeaconEvent is dispatched by a Beacon when its HTTP request
	 * either succeeds or fails.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class BeaconEvent extends Event
	{
		/**
		 * The BeaconEvent.PING_COMPLETE constant defines the value
		 * of the type property of the event object for a pingComplete
		 * event.
		 * 
		 * @eventType PING_COMPLETE
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const PING_COMPLETE:String = "pingComplete";

		/**
		 * The BeaconEvent.PING_ERROR constant defines the value
		 * of the type property of the event object for a pingError
		 * event.
		 * 
		 * @eventType PING_ERROR
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const PING_ERROR:String = "pingError";

		/**
		 * Constructor.
		 * 
		 * @param type Event type.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented. 
		 * @param errorText Textual description of the error.  Only valid for
		 * events of type PING_ERROR.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function BeaconEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, errorText:String=null)
		{
			super(type, bubbles, cancelable);
			
			_errorText = errorText;
		}
		
		/**
		 * Textual description of the error.  Only valid for events of type
		 * PING_ERROR.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get errorText():String
		{
			return _errorText;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new BeaconEvent(type, bubbles, cancelable, errorText);
		}
		
		// Internals
		//
		
		private var _errorText:String;
	}  
}