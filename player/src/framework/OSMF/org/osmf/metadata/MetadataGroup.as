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
	import __AS3__.vec.Vector;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.osmf.events.MetadataEvent;
	import org.osmf.utils.OSMFStrings;
	
	[ExcludeClass]
	
	/**
	 * Dispatched when the metadata group changes as a result of either
	 * a value being added, removed, or changed on a Metadata object, or
	 * when a Metadata object is being added to, or removed from the group.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * @private
	 * 
	 * Defines a group of Metadata objects that share one and the same name
	 * space.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class MetadataGroup extends EventDispatcher
	{
		// Public interface
		//
		
		/**
		 * Constructor.
		 *  
		 * @param namespaceURL The namespace of the Metadata objects that all children of
		 * this group have in common.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function MetadataGroup(namespaceURL:String)
		{
			_namespaceURL = namespaceURL;
			
			_parentMetadatas = new Vector.<Metadata>();
			_metadatas = new Vector.<Metadata>();
		}
		
		/**
		 * Defines the namespace of the Metadata objects that all children of this group
		 * have in common.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get namespaceURL():String
		{
			return _namespaceURL;
		}

		/**
		 * Adds a Metadata object to the group.
		 * 
		 * @param parentMetadata The parent metadata instance that the metadata is to be
		 * tracked in relation to. This relation is tracked because one metadata may be
		 * the child of multiple metadata instances.
		 * @param metadata The metadata to add.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function addMetadata(parentMetadata:Metadata, metadata:Metadata):void
		{
			if (parentMetadata == null || metadata == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			_parentMetadatas.push(parentMetadata);
			_metadatas.push(metadata);
			metadata.addEventListener(MetadataEvent.VALUE_CHANGE, changeDispatchingEventHandler);
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Removes a Metadata object from the group.
		 *  
		 * @param parentMetadata The parent metadata instance that the metadata is to be
		 * tracked in relation to. This relation is tracked because one metadata may be
		 * the child of multiple metadata instances.
		 * @param metadata The metadata to remove.
		 * @returns The removed metadata, or null if the specified item wasn't listed.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function removeMetadata(parentMetadata:Metadata, metadata:Metadata):Metadata
		{
			var result:Metadata;
			var index:int = indexOf(parentMetadata, metadata);
			
			if (index != -1)
			{
				_parentMetadatas.splice(index, 1);
				result = _metadatas.splice(index, 1)[0];
				metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, changeDispatchingEventHandler);
				dispatchEvent(new Event(Event.CHANGE));
			}
			
			return result;
		}
	
		/**
		 * The Metadata objects that are in the group.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get metadatas():Vector.<Metadata>
		{
			return _metadatas;
		}

		/**
		 * The parents of the Metadata objects that are in the group.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get parentMetadatas():Vector.<Metadata>
		{
			return _parentMetadatas;
		}
		
		/**
		 * Gets the index of a given parent/metadata pair.
		 * 
		 * @param parentMetadata The parent metadata reference to localize.
		 * @param metadata The metadata to localize.
		 * @return -1 if the pair was not found, or the requested index.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function indexOf(parentMetadata:Metadata, metadata:Metadata):int
		{
			var result:int = -1;
			
			for (var i:int = 0; i < _metadatas.length; i++)
			{
				var iterMetadata:Metadata = _metadatas[i];
				
				if 	(	iterMetadata == metadata
					&&	parentMetadatas[i] == parentMetadata
					)
				{
					result = i;
					break;
				}
			}
			
			return result;
		}

		// Internals
		//
		
		private function changeDispatchingEventHandler(event:Event):void
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private var _namespaceURL:String;
		private var _parentMetadatas:Vector.<Metadata>;
		private var _metadatas:Vector.<Metadata>;
	}
}