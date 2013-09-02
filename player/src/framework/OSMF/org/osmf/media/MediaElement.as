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
package org.osmf.media
{
	import __AS3__.vec.Vector;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.osmf.containers.IMediaContainer;
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.utils.OSMFStrings;

	/**
	 * Dispatched when a trait is added to the media element.
	 *
	 * @eventType org.osmf.events.MediaElementEvent.TRAIT_ADD
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="traitAdd",type="org.osmf.events.MediaElementEvent")]
	
	/**
	 * Dispatched when a trait is removed from the media element.
	 *
	 * @eventType org.osmf.events.MediaElementEvent.TRAIT_REMOVE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="traitRemove",type="org.osmf.events.MediaElementEvent")]

	/**
	 * Dispatched when a Metadata object has been added to this media element.
	 * 
	 * @eventType org.osmf.events.MediaElementEvent.METADATA_ADD
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="metadataAdd",type="org.osmf.events.MediaElementEvent")]
	
	/**
	 * Dispatched when a Metadata object has been removed from this media element.
	 * 
	 * @eventType org.osmf.events.MediaElementEvent.METADATA_REMOVE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="metadataRemove",type="org.osmf.events.MediaElementEvent")]
	
	/**
	 * Dispatched when an error which impacts the operation of the media
	 * element occurs.
	 *
	 * @eventType org.osmf.events.MediaErrorEvent.MEDIA_ERROR
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="mediaError",type="org.osmf.events.MediaErrorEvent")]
	
	/**
	 * Dispatched when the element's container property changed.
	 * 
	 * @eventType org.osmf.events.ContainerChangeEvent.CONTAINER_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="containerChange",type="org.osmf.events.ContainerChangeEvent")]
		
	/**
     * A MediaElement represents a unified media experience.
     * It may consist of a simple media item, such as a video or a sound.
     * Different instances (or subclasses) can represent different types of media.
     * A MediaElement may also represent a complex media experience composed of 
     * multiple items, such as videos, ad banners, SWF overlays, background page branding, etc.
	 * 
     * <p>Programmatically, a media element encapsulates a set of media traits and
     * a state space.
	 * The media traits
	 * represent the capabilities of the media element and are dynamic in
	 * nature.  At one moment in time a media element might be
	 * seekable, at another moment it might not be. For example, this could occur 
     * if the media element is a video sequence containing unskippable ads.</p>
	 * <p>A media element operates on a media resource.  For example, if the
	 * media element represents a video player, the media resource might
	 * encapsulate a URL to a video stream.
     * If the media element represents a complex media composition, 
     * the media resource URL might be a document that references
     * the multiple resources used in the media composition.</p>
     * @see MediaTraitBase
     * @see MediaResourceBase
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class MediaElement extends EventDispatcher
	{
		// Public interface
		//
		
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function MediaElement()
		{
			super();
			
			_metadata = createMetadata();
			_metadata.addEventListener(MetadataEvent.VALUE_ADD, onMetadataValueAdd);
			_metadata.addEventListener(MetadataEvent.VALUE_REMOVE, onMetadataValueRemove);
			_metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataValueChange);
			
			setupTraitResolvers();		
			setupTraits();
			
			addEventListener
				( ContainerChangeEvent.CONTAINER_CHANGE
				, onContainerChange
				, false
				, Number.MAX_VALUE
				);
		}
	
		/**
		 * A Vector of MediaTraitType values representing the trait types on this
		 * media element.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get traitTypes():Vector.<String>
		{
			// Return a copy of our types vector.
			return _traitTypes.concat();
		}
		
		/**
		 * Determines whether this media element has a media trait of the
		 * specified type.
		 * 
         * @param type The MediaTraitType for the media trait to check for.
		 * 
		 * @throws ArgumentError If the parameter is <code>null</code>.
		 * @return <code>true</code> if this media element has a media
		 * trait of the specified class, <code>false</code> otherwise.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function hasTrait(type:String):Boolean
		{
			if (type == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return traits[type] != null;
		}
		
		/**
		 * Returns the media trait of the specified type.
		 * 
         * @param type The MediaTraitType for the media trait to return.
		 * 
         * @throws ArgumentError If the parameter is <code>null</code>.
         * @return The retrieved trait or <code>null</code> if no such trait exists on this
		 * media element.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getTrait(type:String):MediaTraitBase
		{
			if (type == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}

			return traits[type];
		}
		
		/**
		 * The media resource that this media element operates on.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get resource():MediaResourceBase
		{
			return _resource;
		}
		
		public function set resource(value:MediaResourceBase):void
		{
			_resource = value;		
		}
		
		/**
		 * The media container that this element uses.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get container():IMediaContainer
		{
			return _container;
		}
		
		/** 
		 * Adds a Metadata object to this MediaElement under the specified namespace URL.
		 * 
		 * @param namespaceURL The namespace URL used to store the Metadata.
		 * @param metadata The Metadata to add.
		 * 
		 * @throws ArgumentError if namespaceURL or metadata is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function addMetadata(namespaceURL:String, metadata:Metadata):void
		{
			if (namespaceURL == null || metadata == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			this.metadata.addValue(namespaceURL, metadata);
		}
		
		/**
		 * Removes the Metadata object that was stored under this MediaElement with
		 * the specified namespace URL.
		 * 
		 * @param namespaceURL The namespace URL of the Metadata to remove.
		 * 
		 * @returns The removed Metadata, null if no Metadata with the given
		 * namespaceURL exists one this MediaElement.
		 * 
		 * @throws ArgumentError If namespaceURL is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function removeMetadata(namespaceURL:String):Metadata
		{
			if (namespaceURL == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}

			return metadata.removeValue(namespaceURL) as Metadata;
		}
		
		/** 
		 * Returns the Metadata object that is stored under this MediaElement with
		 * the specified namespace URL.
		 * 
		 * @param namespaceURL The namespace URL of the Metadata object to retrieve.
		 * 
		 * @returns The Metadata object with the specified namespace URL, null if
		 * no such Metadata object exists on this MediaElement.
		 * 
		 * @throws ArgumentError If namespaceURL is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function getMetadata(namespaceURL:String):Metadata
		{
			if (namespaceURL == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}

			return metadata.getValue(namespaceURL) as Metadata;
		}
		
		/**
		 * A Vector containing the namespace URLs for all Metadata
		 * objects stored within this MediaElement.
		 **/
		public function get metadataNamespaceURLs():Vector.<String>
		{
			return metadata.keys;
		}
			
		// Protected
		//
		
		/**
		 * @private
		 * 
		 * Creates the metadata collection class.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		protected function createMetadata():Metadata
		{
			return new Metadata();
		}
		
		/**
		 * @private
		 **/
		public function get metadata():Metadata
		{
			return _metadata;
		}
		
		/**
		 * Adds a new media trait to this media element.  If successful,
		 * dispatches a MediaElementEvent.
		 * 
         * @param type The MediaTraitType for the media trait to add.
		 * @param trait The media trait to add.
		 * 
         * @throws ArgumentError If either parameter is <code>null</code>, or
		 * if the specified type and the type of the media trait don't match,
		 * or if a different instance of the specific trait class has already
		 * been added.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function addTrait(type:String, instance:MediaTraitBase):void
		{
			if (type == null || instance == null || type != instance.traitType)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			// If there's a trait resolver for this type, then add the trait
			// to the resolver:
			var traitResolver:MediaTraitResolver = traitResolvers[type];
			if (traitResolver != null)
			{
				traitResolver.addTrait(instance);		
			}
			else
			{
				setLocalTrait(type, instance);
			}
		}
		
		/**
		 * Removes a media trait from this media element.  If successful,
		 * dispatches a MediaElementEvent.
		 * 
         * @param type The MediaTraitType for the media trait to remove.
		 * 
         * @throws ArgumentError If the parameter is <code>null</code>.
         * @return The removed trait or <code>null</code> if no trait was
         * removed.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function removeTrait(type:String):MediaTraitBase
		{
			if (type == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}

			var trait:MediaTraitBase = traits[type];
			var traitResolver:MediaTraitResolver = traitResolvers[type];
			if (traitResolver != null)
			{
				return traitResolver.removeTrait(trait);		
			}
			else
			{
				return setLocalTrait(type, null);
			}
		}
		
		/**
		 * @private
		 * 
		 * Adds a trait resolver object for a given trait type.
		 * 
		 * Only one resolver can be set per trait type.
		 * 
		 * @param type The MediaTraitType for the media trait to add a resolver for.
		 * @param instance The resolver object to add.
		 * 
		 * @throws ArgumentError If type is null, or if instance is null.
		 * @throws ArgumentError If a resolver has already been added for type.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		final protected function addTraitResolver(type:String, instance:MediaTraitResolver):void
		{
			if (instance == null || instance.type != type)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			if (traitResolvers[type] == null)
			{
				// Store the currently set local trait:
				unresolvedTraits[type] = traits[type];
				
				// Add the resolver to the trait resolvers dictionary:
				traitResolvers[type] = instance;
				
				// If there is a trait instance set for the added resolver's type,
				// then add this trait to the resolver:
				var currentlySetTrait:MediaTraitBase = traits[type];
				if (currentlySetTrait)
				{
					instance.addTrait(currentlySetTrait);
				}
				
				// Run the resolved trait change routine: this will make sure that
				// the local trait gets updated to reflect the resolved trait:
				processResolvedTraitChange(type, instance.resolvedTrait);
				
				// Listen for the resolved trait changing:
				instance.addEventListener(Event.CHANGE, onTraitResolverChange);
			}
			else
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.TRAIT_RESOLVER_ALREADY_ADDED));
			}
		}
		
		/**
		 * @private
		 * 
		 * Removes a trait resolver object for a given trait type.
		 * 
		 * @param type The MediaTraitType for the resolver to remove.
		 * 
		 * @throws ArgumentError If type is null, or if no resolver has been added for type.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		final protected function removeTraitResolver(type:String):MediaTraitResolver
		{
			if (type == null || traitResolvers[type] == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			// Stop listening for the resolver's resolved trait value changing:
			var instance:MediaTraitResolver = traitResolvers[type];
			instance.removeEventListener(Event.CHANGE, onTraitResolverChange);
			
			// Remove the resolver from the trait resolvers dictionary:
			delete traitResolvers[type];
			
			// Reset the unresolved trait to be the current local trait:
			var unresolvedTrait:MediaTraitBase = unresolvedTraits[type];
			if (unresolvedTrait != traits[type])
			{
				setLocalTrait(type, unresolvedTrait);
			}
			delete unresolvedTraits[type];
			
			return instance;
		}
		
		/**
		 * @private
		 * 
		 * Defines the trait resolver that's set for the specified trait type.
		 * 
		 * @param type The MediaTraitType for the resolver object which should be returned.
		 * @return The requested resolver object, or null if none is set for the specified type.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		final protected function getTraitResolver(type:String):MediaTraitResolver
		{
			return traitResolvers[type];
		}
		
		// Subclass stubs
		//
		
		/**
		 * @private
		 * 
		 * Sets up the trait resolvers for the media elements. Occurs during
		 * construction. Subclasses should override this method and call
		 * addTraitResolver for each trait they wish to add a resolver for.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function setupTraitResolvers():void
		{	
		}
		
		/**
		 * Sets up the traits for this media element.  Occurs during
		 * construction.  Subclasses should override this method and call
		 * addTrait for each trait of their own.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function setupTraits():void
		{
		}		

		// Internals
		//
		
		private function onMediaError(event:MediaErrorEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		private function setLocalTrait(type:String, instance:MediaTraitBase):MediaTraitBase
		{
			var result:MediaTraitBase = traits[type];
			if (instance == null)
			{
				// We're processing a trait removal:
				if (result != null)
				{
					// Stop listening for errors:
					result.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
					
					// Dispose of any resources:
					result.dispose();
	
					// Signal removal is about to occur:
					dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_REMOVE, false, false, type));
					
					_traitTypes.splice(_traitTypes.indexOf(type),1);
					delete traits[type];
				}
			}
			else
			{
				// We're processing a trait addition:
				if (result == null)
				{
					traits[type] = result = instance;
					_traitTypes.push(type);
					
					// Listen for errors:
					result.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
					
					// Signal addition:
					dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_ADD, false, false, type));
				}
				else if (result != instance)
				{
					throw new ArgumentError(OSMFStrings.getString(OSMFStrings.TRAIT_INSTANCE_ALREADY_ADDED));
				}
			}
			
			return result;
		}
		
		private function onTraitResolverChange(event:Event):void
		{
			var resolver:MediaTraitResolver = event.target as MediaTraitResolver;
			processResolvedTraitChange(resolver.type, resolver.resolvedTrait);
		}
		
		private function processResolvedTraitChange(type:String, resolvedTrait:MediaTraitBase):void
		{
			if (resolvedTrait != traits[type])
			{
				setLocalTrait(type, resolvedTrait);
			} 
		}

		private function onContainerChange(event:ContainerChangeEvent):void
		{
			if	(	_container == event.oldContainer
				&&	_container != event.newContainer
				)
			{
				_container = event.newContainer;
			}
		}
		
		private function onMetadataValueAdd(event:MetadataEvent):void
		{
			dispatchEvent
				( new MediaElementEvent
					( MediaElementEvent.METADATA_ADD
					, false
					, false
					, null
					, event.key
					, event.value as Metadata
					)
				);
		}
		
		private function onMetadataValueChange(event:MetadataEvent):void
		{
			dispatchEvent
				( new MediaElementEvent
					( MediaElementEvent.METADATA_REMOVE
					, false
					, false
					, null
					, event.key
					, event.oldValue as Metadata
					)
				);

			dispatchEvent
				( new MediaElementEvent
					( MediaElementEvent.METADATA_ADD
					, false
					, false
					, null
					, event.key
					, event.value as Metadata
					)
				);
		}

		private function onMetadataValueRemove(event:MetadataEvent):void
		{
			dispatchEvent
				( new MediaElementEvent
					( MediaElementEvent.METADATA_REMOVE
					, false
					, false
					, null
					, event.key
					, event.value as Metadata
					)
				);
		}
		
		private var traits:Dictionary = new Dictionary();
		private var traitResolvers:Dictionary = new Dictionary();
		private var unresolvedTraits:Dictionary = new Dictionary();

		private var _traitTypes:Vector.<String> = new Vector.<String>();
		private var _resource:MediaResourceBase;
		private var _metadata:Metadata;
		
		private var _container:IMediaContainer;
	}
}