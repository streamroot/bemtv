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
package org.osmf.elements.compositeClasses
{
	import __AS3__.vec.Vector;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.osmf.events.MetadataEvent;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataGroup;
	import org.osmf.metadata.MetadataSynthesizer;
	import org.osmf.metadata.NullMetadataSynthesizer;
	import org.osmf.utils.OSMFStrings;
	
	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	}

	[ExcludeClass]
	
	/**
	 * Event fired when a child was added to the composite. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="childAdd", type="org.osmf.events.CompositeMetadataEvent")]
	
	/**
	 * Event fired when a child was removed from the composite. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="childRemove", type="org.osmf.events.CompositeMetadataEvent")]
		
	/**
	 * Event fired when a new metadata group emerged. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="metadataGroupAdd", type="org.osmf.event.CompositeMetadataEvent")]
	
	/**
	 * Event fired when an existing metadata group ceased to exist. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="metadataGroupRemove", type="org.osmf.event.CompositeMetadataEvent")]
	
	/**
	 * Event fired when a metadata group changed. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="metadataGroupChange", type="org.osmf.event.CompositeMetadataEvent")]
	
	/**
	 * @private
	 * 
	 * Defines a collection of meta data that keeps track of a collection
	 * of child meta data references as a plain list.
	 * 
	 * By default, no synthesis takes place. External clients can inspect metadata
	 * groups at will, and monitor them for change. However, the class provides
	 * an infrastructure for synthesis like so:
	 * 
	 * By using 'addMetadataSynthesizer' and 'removeMetadataSynthesizer', clients can
	 * define how metadata groups of a given name space will be synthesized into
	 * a new metadata. If a metadata group changes that matches an added metadata
	 * synthesizer's namespace, then this synthesizer is used to synthesize the
	 * composite value. After synthesis, the value gets added as one of the
	 * composite's own metadatas.
	 * 
	 * If a CompositeMetadata instance is itself a child of another
	 * CompositeMetadata instance, then any metadata synthesizer that is set on
	 * the parent instance, will be used by the child instance automatically
	 * too. If the child has its own metadata synthesizer listed, than that
	 * synthesizer takes precedence over the inherited one.
	 * 
	 * Last, metadata synthesis occurs if the first metadata from a metadata group
	 * returns a metadata synthesizer for its synthesizer property. Metadata
	 * synthesizers set on this class directly, or indirectly via its parent,
	 * take precedence over the metadata's suggested synthesizer.
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class CompositeMetadata extends Metadata
	{
		// Public Interface
		//
		
		/**
		 * Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function CompositeMetadata()
		{
			super();
			
			children = new Vector.<Metadata>();
			childMetadataGroups = new Dictionary();
			
			metadataSynthesizers = new Dictionary();
		}
		
		/**
		 * Adds a metadata child.
		 * 
		 * @param child The child to add.
		 * @throws IllegalOperationError Thrown if the specified child is
		 * already a child.
		 * @throws ArgumentError if the specified child is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function addChild(child:Metadata):void
		{
			if (child == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			var childIndex:int = children.indexOf(child);
			if (childIndex != -1)
			{
				throw new IllegalOperationError();	
			}
			else
			{
				children.push(child);
				
				child.addEventListener
					( MetadataEvent.VALUE_ADD
					, onChildMetadataAdd
					);
					
				child.addEventListener
					( MetadataEvent.VALUE_REMOVE
					, onChildMetadataRemove
					);
					
				if (child is CompositeMetadata)
				{
					child.addEventListener
						( CompositeMetadataEvent.METADATA_GROUP_CHANGE
						, onChildMetadataGroupChange
						);
				}
				
				for each (var url:String in child.keys)
				{
					processChildMetadataAdd
						( child
						, child.getValue(url) as Metadata
						, url
						);
				}
				
				dispatchEvent
					( new CompositeMetadataEvent
						( CompositeMetadataEvent.CHILD_ADD
						, false, false
						, child
						)
					);
			}
		}
		
		/**
		 * Removes a metadata child.
		 * 
		 * @param child The child to remove.
		 * @throws IllegalOperationError Thrown if the specified child is
		 * not a child.
		 * @throws ArgumentError if the specified child is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function removeChild(child:Metadata):void
		{
			if (child == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			var childIndex:int = children.indexOf(child);
			if (childIndex == -1)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}	
			else
			{
				children.splice(childIndex,1);
				
				child.removeEventListener
					( MetadataEvent.VALUE_ADD
					, onChildMetadataAdd
					);
					
				child.removeEventListener
					( MetadataEvent.VALUE_REMOVE
					, onChildMetadataRemove
					);
				
				if (child is CompositeMetadata)
				{
					child.removeEventListener
						( CompositeMetadataEvent.METADATA_GROUP_CHANGE
						, onChildMetadataGroupChange
						);
				}
				
				for each (var url:String in child.keys)
				{
					processChildMetadataRemove
						( child
						, child.getValue(url) as Metadata
						, url
						);
				}
				
				dispatchEvent
					( new CompositeMetadataEvent
						( CompositeMetadataEvent.CHILD_REMOVE
						, false, false
						, child
						)
					);
			}
		}
		
		/**
		 * Defines the number of children.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get numChildren():int
		{
			return children.length;
		}
		
		/**
		 * Fetches the child at the indicated index. 
		 * 
		 * @param index The index of the child metadata to fetch.
		 * @return The requested metadata.
		 * @throws RangeError Thrown when the specified index is out of
		 * bounds.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function getChildAt(index:int):Metadata
		{
			if (index >= children.length || index < 0)
			{
				throw new RangeError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));	
			}
			
			return children[index];
		}
		
		/**
		 * Defines the composition mode that will be forwarded to metadata
		 * synthesizers when synthesizing a merged metadata is required.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function set mode(value:String):void
		{
			if (_mode != value)
			{
				_mode = value;
				
				processSynthesisDependencyChanged();
			}
		}
		public function get mode():String
		{
			return _mode;
		}
		
		/**
		 * Defines the active metadata that will be forwarded
		 * to metadata synthesizers when synthesizing a merged metadata is
		 * required.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set activeChild(value:Metadata):void
		{
			if (_activeChild != value)
			{
				_activeChild = value;
				
				processSynthesisDependencyChanged();
			}
		}
		public function get activeChild():Metadata
		{
			return _activeChild;
		}
		
		/**
		 * Adds a metadata synthesizer.
		 * 
		 * A metadata synthesizer can synthesize a metadata from a given MetadataGroup,
		 * composition mode, and active child (if any).
		 * 
		 * Only one synthesizer can be registered for a given namespace URL.
		 * 
		 * @param namespaceURL The namespace URL to synthesize values for.
		 * @param synthesizer The metadata synthesizer to add.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function addMetadataSynthesizer(namespaceURL:String, synthesizer:MetadataSynthesizer):void
		{
			if (synthesizer == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			if (getMetadataSynthesizer(namespaceURL) != null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			metadataSynthesizers[namespaceURL] = synthesizer;
		}
		
		/**
		 * Removes a metadata synthesizer.
		 * 
		 * @param namespaceURL The namespace URL that corresponds to the synthesizer to remove.
		 * @throws ArgumentError If namespaceURL is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function removeMetadataSynthesizer(namespaceURL:String):void
		{
			if (namespaceURL == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			if (getMetadataSynthesizer(namespaceURL) != null)
			{
				delete metadataSynthesizers[namespaceURL];
			}
		}
		
		/**
		 * Fetches the metadata synthesizer (if any) for the given namespace URL.
		 * 
		 * @param namespaceURL The namespace to retrieve the set synthesizer for.
		 * @return The requested syntesizer, if it was set, null otherwise.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function getMetadataSynthesizer(namespaceURL:String):MetadataSynthesizer
		{
			var result:MetadataSynthesizer;
			
			if (namespaceURL != null)
			{
				for (var rawUrl:String in metadataSynthesizers)
				{
					if (rawUrl == namespaceURL)
					{
						result = metadataSynthesizers[rawUrl];
						break;
					}
				}
			}
			
			return result;
		}
		
		/**
		 * Collects the namespaces of the metadata groups that are currently in existence.
		 *  
		 * @return The collected namespaces.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function getMetadataGroupNamespaceURLs():Vector.<String>
		{
			var result:Vector.<String> = new Vector.<String>();
			
			for (var url:String in childMetadataGroups)
			{
				result.push(url);
			}
			
			return result;
		}
		
		/**
		 * Fetches the metadata group for the given namenspace.
		 *  
		 * @param namespaceURL The namespace to fetch the metadata group for.
		 * @return The requested metadata group, or null if there is no such group.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getMetadataGroup(namespaceURL:String):MetadataGroup
		{
			if (namespaceURL == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			return childMetadataGroups[namespaceURL];
		}
		
		// Internals
		//
		
		private function processChildMetadataAdd(child:Metadata, metadata:Metadata, metadataNamespaceURL:String):void
		{
			var groupAddEvent:CompositeMetadataEvent;
			
			if (metadata != null)
			{
				var childrenNamespaceURL:String = metadataNamespaceURL;
				
				var metadataGroup:MetadataGroup = childMetadataGroups[childrenNamespaceURL];
				if (metadataGroup == null)
				{
					childMetadataGroups[childrenNamespaceURL]
						= metadataGroup
						= new MetadataGroup(childrenNamespaceURL);
						
					metadataGroup.addEventListener(Event.CHANGE, onMetadataGroupChange);
						
					groupAddEvent
						= new CompositeMetadataEvent
							( CompositeMetadataEvent.METADATA_GROUP_ADD
							, false, false
							, child
							, metadataNamespaceURL
							, metadata
							, metadataGroup
							);
				}
				
				metadataGroup.addMetadata(child, metadata);
			}
					
			if (groupAddEvent != null)
			{
				dispatchEvent(groupAddEvent);
			}
		}
		
		private function processChildMetadataRemove(child:Metadata, metadata:Metadata, metadataNamespaceURL:String):void
		{
			var groupRemoveEvent:CompositeMetadataEvent;
			
			if (metadata != null)
			{
				var childrenNamespaceURL:String = metadataNamespaceURL;
				var metadataGroup:MetadataGroup = childMetadataGroups[childrenNamespaceURL];
				metadataGroup.removeMetadata(child, metadata);
				
				if (metadataGroup.metadatas.length == 0)
				{
					metadataGroup.removeEventListener(Event.CHANGE, onMetadataGroupChange);
					
					groupRemoveEvent
						= new CompositeMetadataEvent
							( CompositeMetadataEvent.METADATA_GROUP_REMOVE
							, false, false
							, child
							, metadataNamespaceURL
							, metadata
							, metadataGroup
							);
							
					delete childMetadataGroups[childrenNamespaceURL];
					
				}
			}
			
			if (groupRemoveEvent != null)
			{
				dispatchEvent(groupRemoveEvent);
			}
		}
		
		private function processSynthesisDependencyChanged():void
		{
			for each (var metadataGroup:MetadataGroup in childMetadataGroups)
			{
				onMetadataGroupChange(null, metadataGroup);
			}
		}
		
		// Event Handlers
		//
		
		private function onChildMetadataAdd(event:MetadataEvent):void
		{
			processChildMetadataAdd(event.target as Metadata, event.value as Metadata, event.key);	
		}
		
		private function onChildMetadataRemove(event:MetadataEvent):void
		{
			processChildMetadataRemove(event.target as Metadata, event.value as Metadata, event.key);
		}
		
		private function onChildMetadataGroupChange(event:CompositeMetadataEvent):void
		{
			// If no one before us was able to deliver a metadata synthesizer, then perhaps we can:
			if (event.suggestedMetadataSynthesizer == null)
			{
				event.suggestedMetadataSynthesizer = metadataSynthesizers[event.metadataGroup.namespaceURL];
			}
						
			var clonedEvent:CompositeMetadataEvent 
				=	event.clone()
				as	CompositeMetadataEvent;
				
			// Re-dispatch the event:
			dispatchEvent(clonedEvent);
			
			// If we didn't assign a metadata synthesizer, then perhaps another handler did:
			if (event.suggestedMetadataSynthesizer == null)
			{
				event.suggestedMetadataSynthesizer = clonedEvent.suggestedMetadataSynthesizer;
			}
		}
		
		private function onMetadataGroupChange(event:Event, metadataGroup:MetadataGroup = null):void
		{
			// This method is invoked as both a regular event handler, as well as directly
			// from processSynthesisDependencyChanged. In the latter case, the event will be
			// null, and the metadataGroup parameter will be set instead. To be prudent, check
			// for a metadata group being present either way:
			metadataGroup ||= event ? event.target as MetadataGroup : null;
			if (metadataGroup == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			var synthesizedMetadata:Metadata;
			var metadataSynthesizer:MetadataSynthesizer = metadataSynthesizers[metadataGroup.namespaceURL];
			
			var localEvent:CompositeMetadataEvent
				= new CompositeMetadataEvent
					( CompositeMetadataEvent.METADATA_GROUP_CHANGE
					, false, false
					, null, null, null
					, metadataGroup
					, metadataSynthesizer
					)
			
			dispatchEvent(localEvent);
			
 			// If no metadata synthesizer is set yet, then first see if any of the
			// event handlers provided us with one. If not, then use the metadata's
			// default synthesizer (if it provides for one):
			metadataSynthesizer
				||= localEvent.suggestedMetadataSynthesizer
				// If no synthesizer has been suggested by our parents, then look
				// at the metadata group, and take the synthesizer set on the first
				// metadata that we encounter:
				||	(	(metadataGroup.metadatas.length > 0)
							? metadataGroup.metadatas[0].synthesizer
							: null
				 	)
				// Last, revert to the default synthesizer:
				|| new MetadataSynthesizer();
			
			// If the activeChild was just removed, don't let it influence the
			// synthesis decision.
			var serialElementActiveChild:Metadata = _activeChild;
			if (_activeChild != null && children.indexOf(_activeChild) == -1)
			{
				serialElementActiveChild = null;
			}
			
			// Run the metadata synthesizer:
			synthesizedMetadata
				= metadataSynthesizer.synthesize
					( metadataGroup.namespaceURL
					, this
					, metadataGroup.metadatas
					, _mode
					, serialElementActiveChild
					);
 		
			if (synthesizedMetadata == null)
			{
				// If the synthesized value is null, then we might need to clear
				// out a previously set value. Don't clear out the value if the
				// current synthesizer is a null synthesizer.
				var currentMetadata:Metadata = getValue(metadataGroup.namespaceURL) as Metadata;
				if	(	currentMetadata != null
					&&	currentMetadata.synthesizer is NullMetadataSynthesizer == false
					)
				{
					CONFIG::LOGGING { logger.debug("removing metadata {0}", metadataGroup.namespaceURL); }
					removeValue(metadataGroup.namespaceURL);
				}
			}
			else
			{
				// Add, or overwrite the last set metadata value:
				addValue(metadataGroup.namespaceURL, synthesizedMetadata);
			}
		}
		
		private var children:Vector.<Metadata>;
		private var childMetadataGroups:Dictionary; 
		private var metadataSynthesizers:Dictionary;
		
		private var _mode:String;
		private var _activeChild:Metadata;
		
		CONFIG::LOGGING private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.elements.compositeClasses.CompositeMetadata");
	}
}