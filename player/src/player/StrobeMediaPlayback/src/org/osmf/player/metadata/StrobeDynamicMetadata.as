/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 * 
 **********************************************************/

package org.osmf.player.metadata
{
	import org.osmf.metadata.Metadata;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.osmf.events.MetadataEvent;
	import org.osmf.utils.OSMFStrings;

	/**
	 * Dynamic object that accomodates both Metadata and plain AS Object metadata.
	 */ 
	public dynamic class StrobeDynamicMetadata extends Metadata
	{
		// All the metadata fields will be added using
		// both addValue and by setting a property on 
		// an instance of this dynamic class. 
		
		// imo, we should consider a proxy approach, similar to http://www.actionscript.org/forums/showthread.php3?p=1019621
		
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
		override public function getValue(key:String):*
		{
			if (key == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			return this != null ? this[key] : null
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
		override public function addValue(key:String, value:Object):void
		{
			if (key == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
		
			var oldValue:* = this[key];			
			this[key] = value;
			
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
		override public function removeValue(key:String):*
		{
			if (key == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			var value:* = this[key];
			if (value !== undefined)
			{
				delete this[key];
				
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
		override public function get keys():Vector.<String>
		{
			var allKeys:Vector.<String> = new Vector.<String>;
			if (this != null)
			{
				for (var key:Object in this)
				{
					allKeys.push(key);
				}
			}
			return allKeys;
		}
	}
}