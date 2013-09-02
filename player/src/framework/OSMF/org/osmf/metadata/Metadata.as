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
package org.osmf.metadata
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.osmf.events.MetadataEvent;
	import org.osmf.utils.OSMFStrings;
		 
     /**
	 * Dispatched when a new value is added to the Metadata object.
	 * 
	 * @eventType org.osmf.events.MetadataEvent.VALUE_ADD
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
     [Event(name='valueAdd', type='org.osmf.events.MetadataEvent')]
	
     /**
	 * Dispatched when a value is removed from the Metadata object.
	 * 
	 * @eventType org.osmf.events.MetadataEvent.VALUE_REMOVE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
     [Event(name='valueRemove', type='org.osmf.events.MetadataEvent')]
	
     /**
	 * Dispatched when a value within the Metadata object changes.
	 * 
	 * @eventType org.osmf.events.MetadataEvent.VALUE_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
     [Event(name='valueChange', type='org.osmf.events.MetadataEvent')]
	
	/**
	 * The Metadata class encapsulates a related collection of metadata.
	 * 
	 * <p>Metadata consists of key-value pairs, where keys are Strings
	 * and values are arbitrary Objects.  The Metadata class provides a
	 * strongly-typed API for working with these key-value pairs, as well
	 * as events for detecting changes to the metadata.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */  
	public class Metadata extends EventDispatcher
	{		
		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function Metadata()		
		{						
		}
		
		/**
		 * Returns the value associate with the specified key.
		 * 
		 * Returns 'undefined' if the Metadata object fails to resolve the key.
		 * 
		 * @throws ArgumentError If key is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getValue(key:String):*
		{
			if (key == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			return data != null ? data[key] : null
		}
		
		/**
		 * Stores the specified value in this Metadata object, using the specified
		 * key.  The key can subsequently be used to retrieve the value.  If the
		 * key is equal to the key of another object already in the Metadata object
		 * this will overwrite the association with the new value.
		 * 
		 * @param key The key to associate the value with.
		 * @param value The value to add to the Metadata object.
		 * 
		 * @throws ArgumentError If key is null or somehow invalid.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function addValue(key:String, value:Object):void
		{
			if (key == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			if (data == null)
			{
				data = new Dictionary();
			}
			
			var oldValue:* = data[key];			
			data[key] = value;
			
			if (oldValue != value)
			{				
				var event:Event
					= oldValue === undefined
						? new MetadataEvent
							( MetadataEvent.VALUE_ADD
							, false
							, false
							, key
							, value
							)
						: new MetadataEvent
							( MetadataEvent.VALUE_CHANGE
							, false
							, false
							, key
							, value
							, oldValue
							)
						;
						
				dispatchEvent(event);
			}
		}
		
		/**
		 * Removes the value associated with the specified key from this
		 * Metadata object. Returns undefined if there is no value
		 * associated with the key in this Metadata object.
		 * 
		 * @param key The key associated with the value to be removed.
		 * @returns The removed item, null if no such item exists.
		 * 
		 * @throws ArgumentError If key is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function removeValue(key:String):*
		{
			if (key == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}

			var value:* = data[key];
			if (value !== undefined)
			{
				delete data[key];
								
				dispatchEvent
					( new MetadataEvent
						( MetadataEvent.VALUE_REMOVE
						, false
						, false
						, key
						, value
						)
					);
			}
			return value;
		}
		
		/**
		 * The keys stored in this Metadata object.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function get keys():Vector.<String>
		{
			var allKeys:Vector.<String> = new Vector.<String>;
			if (data != null)
			{
				for (var key:Object in data)
				{
					allKeys.push(key);
				}
			}
			return allKeys;
		}

		/**
		 * @private
		 * 
		 * Defines the metadata synthesizer that will be used by default to
		 * synthesize a new value based on a group of Metadata objects that share
		 * the namespace that this metadata is registered under.
		 * 
		 * Note that metadata synthesizers that get set on the metadata's parent
		 * take precedence over the one that is defined here.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
 		public function get synthesizer():MetadataSynthesizer
		{
			return null;
		}
 				
		private var data:Dictionary;
	}
}