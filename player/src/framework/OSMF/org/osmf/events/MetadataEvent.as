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
	 * A MetadataEvent is dispatched by a Metadata object when metadata
	 * values are added, removed, or changed.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */ 
	public class MetadataEvent extends Event
	{
		/**
		 * The MetadataEvent.VALUE_ADD constant defines the value of the
		 * type property of the event object for a valueAdd event.
		 * 
		 * @eventType valueAdd 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const VALUE_ADD:String = "valueAdd";
		
		/**
		 * The MetadataEvent.VALUE_REMOVE constant defines the value of the
		 * type property of the event object for a valueRemove event.
		 * 
		 * @eventType valueRemove 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const VALUE_REMOVE:String = "valueRemove";
		
		/**
		 * The MetadataEvent.VALUE_CHANGE constant defines the value
		 * of the type property of the event object for a valueChange
		 * event.
		 * 
		 * @eventType valueChange
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const VALUE_CHANGE:String = "valueChange";

		/**
		 * Constructor.
		 * 
		 * @param type Event type.
 		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented. 
		 * @param key The key associated with the event.
		 * @param value The value associated with the event.
		 * @param oldValue The old value associated with the event.  Only valid for VALUE_CHANGE events.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 				
		public function MetadataEvent
			( type:String
			, bubbles:Boolean=false
			, cancelable:Boolean=false
			, key:String=null
			, value:*=null
			, oldValue:*=null
			)
		{
			super(type, bubbles, cancelable);
			
			_key = key;
			_value = value;
			_oldValue = oldValue;
		}
		
		/**
		 * The key associated with this event. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function get key():String
		{
			return _key;
		}

		/**
		 * The value associated with this event. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function get value():*
		{
			return _value;
		}

		/**
		 * The old value associated with this event.  Only valid for VALUE_CHANGE events.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function get oldValue():*
		{
			return _oldValue;
		}
		
		/**
		 * @private
		 */ 
		override public function clone():Event
		{
			return new MetadataEvent(type, bubbles, cancelable, _key, _value, _oldValue);
		}
		
		private var _key:String;
		private var _value:*;
		private var _oldValue:*;		
	}
}