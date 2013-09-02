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
	import flash.errors.IllegalOperationError;
	
	import org.osmf.events.MetadataEvent;
	import org.osmf.utils.OSMFStrings;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The MetadataWatcher class is a convenience class for monitoring nested Metadata
	 * for change.  It is capable of watching for value add, remove, or change
	 * events.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class MetadataWatcher
	{
		/**
		 * Constructor.
		 * 
		 * @param parentMetadata The parent Metadata to watch for change.
		 * @param namespaceURL The namespace that identifies the Metadata instance to watch
		 * for change.
		 * @param key The key pointing to the value of interest to watch
		 * for change. Note that this parameter is optional: not specifying a key
		 * will result in the Metadata as a whole being watched for change.
		 * @param callback The method to invoke on either the Metadata or Metadata value (see
		 * key parameter description) changing. The callback function is expected
		 * to take one argument, which will be set to the new value.
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function MetadataWatcher(parentMetadata:Metadata, namespaceURL:String, key:String, callback:Function)
		{
			if (parentMetadata == null || namespaceURL == null || callback == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}

			this.parentMetadata = parentMetadata;
			this.namespaceURL = namespaceURL;
			this.key = key;
			this.callback = callback;
		}
		
		/**
		 * Starts watching the target metadata.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function watch(dispatchInitialChangeEvent:Boolean=true):void
		{
			if (watching == false)
			{
				watching = true;
				
				// Make sure we are watching for metadatas being added. process-
				// WatchedMetadataChange that is invoked later, will remove the
				// listener should it already be present on our metadata:
				parentMetadata.addEventListener
					( MetadataEvent.VALUE_ADD, onMetadataAdd
					, false, 0, true
					);
				
				processWatchedMetadataChange(parentMetadata.getValue(namespaceURL) as Metadata);
				
				// For convenience, always trigger a first change callback when
				// start watching:
				if (dispatchInitialChangeEvent == true)
				{
					if (key != null)
					{
						callback(currentMetadata ? currentMetadata.getValue(key) : undefined);
					}
					else
					{
						callback(currentMetadata ? currentMetadata : undefined);
					}
				}
			}
		}
		
		/**
		 * Stops watching the target.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function unwatch():void
		{
			if (watching == true)
			{
				processWatchedMetadataChange(null, false);
				
				// If we weren't watching our metadata yet, then processWatched-
				// MetadataChange will not have remove our addition listener:
				parentMetadata.removeEventListener(MetadataEvent.VALUE_ADD, onMetadataAdd);
				
				watching = false;
			}
		}	
		
		// Internals
		//
			
		private function processWatchedMetadataChange(metadata:Metadata, dispatchChange:Boolean = true):void
		{
			// Don't change anything if the new metadata matches the old one:
			if (currentMetadata != metadata)
			{
				var oldMetadata:Metadata = currentMetadata;
				
				if (currentMetadata)
				{
					// Remove the event listeners for the currently set metadata:
					currentMetadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onValueChange);
					currentMetadata.removeEventListener(MetadataEvent.VALUE_ADD, onValueAdd);
					currentMetadata.removeEventListener(MetadataEvent.VALUE_REMOVE, onValueRemove);
					
					parentMetadata.removeEventListener(MetadataEvent.VALUE_REMOVE, onMetadataRemove);
				}
				else
				{
					// If there's currently no metadata set, then remove the listener
					// that's out to capture the addition of the metadata:
					parentMetadata.removeEventListener(MetadataEvent.VALUE_ADD, onMetadataAdd);
				}
				
				// Now assign the new metadata value:
				currentMetadata = metadata;
				
				if (metadata)
				{
					// Listen to the metadata informing us about value changes:
					metadata.addEventListener
						( MetadataEvent.VALUE_CHANGE, onValueChange
						, false, 0, true
						);
					metadata.addEventListener
						( MetadataEvent.VALUE_ADD, onValueAdd
						, false, 0, true
						);
					metadata.addEventListener
						( MetadataEvent.VALUE_REMOVE, onValueRemove
						, false, 0, true
						);
					
					// Listen to the parent metadata informing us about the metadata being removed:
					parentMetadata.addEventListener(MetadataEvent.VALUE_REMOVE, onMetadataRemove);
				}
				else
				{
					// If there's currently no metadata set, then listen to the parent metadata
					// instance informing us about new metadatas being added:
					parentMetadata.addEventListener(MetadataEvent.VALUE_ADD, onMetadataAdd);
				}
			}
		}
		
		// Metadata Handlers
		//
		
		private function onMetadataAdd(event:MetadataEvent):void
		{
			// See if this is the metadata that we're watching:
			var metadata:Metadata = event.value as Metadata;
			if (metadata && event.key == namespaceURL)
			{
				processWatchedMetadataChange(metadata);
				
				// In case we're watching at the metadata level only, then
				// trigger the callback:
				if (key == null)
				{
					callback(metadata);
				}
				else
				{
					callback(metadata.getValue(key));
				}
			}
		}
		
		private function onMetadataRemove(event:MetadataEvent):void
		{
			// See if this is the metadata that we're watching:
			var metadata:Metadata = event.value as Metadata;
			if (metadata && event.key == namespaceURL)
			{
				processWatchedMetadataChange(null);
				
				callback(undefined);
			}
		}
		
		// Value Handlers
		//
		
		private function onValueChange(event:MetadataEvent):void
		{
			if (key)
			{
				// We're watching a specific value: only invoke the callback
				// if this is 'our' value that is changing:
				if (key == event.key)
				{
					callback(event.value);
				}	
			}
			else
			{
				// We're watching the entire metadata: invoke callback:
				callback(event.target as Metadata);
			}
		}
		
		private function onValueAdd(event:MetadataEvent):void
		{
			if (key)
			{
				// We're watching a specific value: only invoke the callback
				// if this is 'our' value that is being added:
				if (key == event.key)
				{
					callback(event.value);
				}	
			}
			else
			{
				// We're watching the entire metadata: invoke callback:
				callback(event.target as Metadata);
			}
		}
		
		private function onValueRemove(event:MetadataEvent):void
		{
			if (key)
			{
				// We're watching a specific value: only invoke the callback
				// if this is 'our' value that is being removed:
				if (key == event.key)
				{
					callback(undefined);
				}	
			}
			else
			{
				// We're watching the entire metadata: invoke callback:
				callback(event.target as Metadata);
			}
		}
		
		private var parentMetadata:Metadata;
		private var namespaceURL:String;
		private var key:String;
		private var callback:Function;
		
		private var currentMetadata:Metadata;
		private var watching:Boolean;
	}
}