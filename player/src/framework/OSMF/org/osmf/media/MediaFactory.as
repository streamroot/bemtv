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
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.events.PluginManagerEvent;
	import org.osmf.media.pluginClasses.PluginManager;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * Dispatched when the MediaFactory has successfully loaded a plugin.
	 *
	 * @eventType org.osmf.events.MediaFactoryEvent.PLUGIN_LOAD
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="pluginLoad", type="org.osmf.events.MediaFactoryEvent")]

	/**
	 * Dispatched when the MediaFactory has failed to load a plugin due to an error.
	 *
	 * @eventType org.osmf.events.MediaFactoryEvent.PLUGIN_LOAD_ERROR
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="pluginLoadError", type="org.osmf.events.MediaFactoryEvent")]

	/**
	 * Dispatched when the MediaFactory has created a MediaElement.
	 *
	 * @eventType org.osmf.events.MediaFactoryEvent.MEDIA_ELEMENT_CREATE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="mediaElementCreate", type="org.osmf.events.MediaFactoryEvent")]

	/**
	 * MediaFactory represents a factory class for media elements.
	 * 
	 * <p>The factory operation takes a MediaResourceBase as input and produces a MediaElement
	 * as output.</p>
	 * <p>The MediaFactory maintains a list of MediaFactoryItem objects,
	 * each of which encapsulates all the information necessary to create 
	 * a specific MediaElement. The MediaFactory relies on
	 * the canHandleResourceFunction method of each MediaFactoryItem to find a
	 * MediaFactoryItem object that can handle the specified MediaResourceBase.</p>
	 *
	 * <p>The factory interface also exposes methods for querying for specific MediaFactoryItem 
	 * objects, and for loading plugins (which hold MediaFactoryItem objects).</p>
	 * 
	 * @see MediaFactoryItem
	 * @see MediaResourceBase
	 * @see MediaElement
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 * 
	 *  @includeExample MediaFactoryExample.as -noswf
	 */	
	public class MediaFactory extends EventDispatcher
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function MediaFactory()
		{
			super();
			
			allItems = new Dictionary();
		}
		
		/**
		 * Adds the specified MediaFactoryItem to the factory.
		 * After the MediaFactoryItem has been added, for any MediaResourceBase
		 * that this MediaFactoryItem can handle, the factory will be able to create
		 * the corresponding media element.
		 * 
		 * If a MediaFactoryItem with the same ID already exists in this
		 * factory, the new MediaFactoryItem object replaces it.
		 * 
		 * @param item The MediaFactoryItem to add.
		 * 
		 * @throws ArgumentError If the argument is <code>null</code> or if the argument
		 * has a <code>null</code> ID field.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function addItem(item:MediaFactoryItem):void
		{
			if (item == null || item.id == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			var items:Vector.<MediaFactoryItem> = findOrCreateItems(item.type);
			
			// Make sure to overwrite any duplicate.
			var existingIndex:int = getIndexOfItem(item.id, items);
			if (existingIndex != -1)
			{
				items[existingIndex] = item;
			}
			else
			{
				items.push(item);		
			}
		}
		
		/**
		 * Removes the specified MediaFactoryItem from the factory.
		 * 
		 * If no such MediaFactoryItem exists in this factory, does nothing.
		 * 
		 * @param item The MediaFactoryItem to remove.
		 * 
		 * @throws ArgumentError If the argument is <code>null</code> or if the argument
		 * has a <code>null</code> ID field.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function removeItem(item:MediaFactoryItem):void
		{
			if (item == null || item.id == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			var items:Vector.<MediaFactoryItem> = allItems[item.type];
			if (items != null)
			{
				var existingIndex:int = items.indexOf(item);
				if (existingIndex != -1)
				{
					items.splice(existingIndex, 1);
				}
			}
		}

		/**
		 * The number of MediaFactoryItems managed by the factory.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get numItems():int
		{
			var numItems:int = 0;
			
			for each (var type:String in MediaFactoryItemType.ALL_TYPES)
			{
				var items:Vector.<MediaFactoryItem> = allItems[type];
				if (items != null)
				{
					numItems += items.length;
				}
			}
			
			return numItems;
		}
		
		/**
		 * Gets the MediaFactoryItem at the specified index.
		 * 
		 * @param index The index in the list from which to retrieve the MediaFactoryItem.
		 * 
		 * @return The MediaFactoryItem at that index or <code>null</code> if there is none.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getItemAt(index:int):MediaFactoryItem
		{
			var result:MediaFactoryItem = null;
			
			if (index >= 0)
			{
				for each (var type:String in MediaFactoryItemType.ALL_TYPES)
				{
					var items:Vector.<MediaFactoryItem> = allItems[type];
					if (items != null)
					{
						if (index < items.length)
						{
							result = items[index];
							break;
						}
						else
						{
							// Not in this list, try the next.
							index -= items.length;
						}
					}
				}
			}
			
			return result;
		}

		/**
		 * Returns the MediaFactoryItem with the specified ID or <code>null</code> if the
		 * specified MediaFactoryItem does not exist in this factory.
		 * 
		 * @param The ID of the MediaFactoryItem to retrieve.
		 * 
		 * @return The MediaFactoryItem with the specified ID or <code>null</code> if the specified
		 * MediaFactoryItem does not exist in this factory. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getItemById(id:String):MediaFactoryItem
		{
			var result:MediaFactoryItem = null;
			
			for each (var type:String in MediaFactoryItemType.ALL_TYPES)
			{
				var items:Vector.<MediaFactoryItem> = allItems[type];
				if (items != null)
				{
					var existingIndex:int = getIndexOfItem(id, items);
					if (existingIndex != -1)
					{
						result = items[existingIndex];
						break;
					}
				}
			}
			
			return result;
		}
		
		/**
		 * Load a plugin identified by the specified resource. The MediaFactory will not
		 * reload the plugin if it has already been loaded. Upon successful loading, the
		 * MediaFactoryItems within the plugin's PluginInfo property will be added to
		 * this MediaFactory, and a MediaFactoryEvent.PLUGIN_LOAD event will be dispatched.
		 * OtherwiseIf the load fails, a MediaFactoryEvent.PLUGIN_LOAD_ERROR event will be
		 * dispatched.
		 *
		 * @param resource MediaResourceBase representing the plugin.  For remote (dynamic)
		 * plugins, use an URLResource pointing to the remote SWF to load.  For local
		 * (static) plugins, use a PluginInfoResource.  
		 *
		 * @throws ArgumentError If resource is null or resource is neither an URLResource
		 * nor a PluginInfoResource. 
		 *
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function loadPlugin(resource:MediaResourceBase):void
		{
			createPluginManager();
			
			pluginManager.loadPlugin(resource);
		}

		/**
		 * Returns a MediaElement that can be created based on the specified
		 * MediaResourceBase.
		 * <p>Returns <code>null</code> if the factory cannot         
		 * find a MediaFactoryItem object
		 * capable of creating such a MediaElement in this factory.</p>
		 * 
		 * @param resource The MediaResourceBase for which a corresponding
		 * MediaElement should be created.
		 * 
		 * @return The MediaElement that was created or <code>null</code> if no such
		 * MediaElement could be created from the resource.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function createMediaElement(resource:MediaResourceBase):MediaElement
		{
			// Make sure we have a plugin manager before creating a MediaElement, so
			// that it will catch the mediaElementCreate event.
			createPluginManager();
			
			// Note that proxies are resolved before creation callbacks are called:
			// if a media element is proxied, then the creation callback will be invoked
			// with the root proxy, not the wrapped media element.
			// 

			// We attempt to create a MediaElement of the STANDARD type.
			var mediaElement:MediaElement = createMediaElementByResource(resource, MediaFactoryItemType.STANDARD);
			if (mediaElement != null)
			{
				var proxyElement:MediaElement = 
						createMediaElementByResource
							( mediaElement.resource
							, MediaFactoryItemType.PROXY
							, mediaElement			/* element to wrap */
							);
				
				// If we have a corresponding ProxyElement, then instead of
				// returning the STANDARD MediaElement, we instead return that
				// PROXY element as the wrapper for the STANDARD element.
				mediaElement = (proxyElement != null ? proxyElement : mediaElement);
				
				// Inform clients of the creation.
				dispatchEvent
					( new MediaFactoryEvent
						( MediaFactoryEvent.MEDIA_ELEMENT_CREATE
						, false
						, false
						, null
						, mediaElement
						)
					);
			}
			
			return mediaElement;
		}
		
		// Protected
		//
		
		/**
		 * Returns the most appropriate MediaFactoryItem for the specified resource
		 * out of the MediaFactoryItems in the specified list.
		 * 
		 * This method is invoked when <code>createMediaElement</code> is invoked
		 * with a resource that more than one MediaFactoryItem can handle.  Subclasses
		 * can override to select the most appropriate one.
		 * 
		 * The default behavior is to select the first item which is not "native" to
		 * the framework, under the theory that plugins ought to take precedence over
		 * core media types.  It makes this decision based on the presence or absence
	 	 * of an id value which starts with "org.osmf".
		 */
		protected function resolveItems(resource:MediaResourceBase, items:Vector.<MediaFactoryItem>):MediaFactoryItem
		{
			if (resource == null || items == null)
			{
				return null;
			}
			
			var firstNativeItem:MediaFactoryItem = null;
			
			for (var i:int = 0; i < items.length; i++)
			{
				var item:MediaFactoryItem = items[i] as MediaFactoryItem;
				if (item.id.indexOf("org.osmf") == -1)
				{
					// Non-native, we'll take it.
					return item;
				}
				else if (firstNativeItem == null)
				{
					firstNativeItem = item;
				}
			}
			
			return firstNativeItem;
		}
		
		// Internals
		//
		
		private function findOrCreateItems(type:String):Vector.<MediaFactoryItem>
		{
			if (allItems[type] == null)
			{
				allItems[type] = new Vector.<MediaFactoryItem>();
			}
			
			return allItems[type] as Vector.<MediaFactoryItem>;
		}
		
		private function createMediaElementByResource
			( resource:MediaResourceBase
			, itemType:String
			, wrappedElement:MediaElement=null
			):MediaElement
		{
			var mediaElement:MediaElement = null;
			
			var items:Vector.<MediaFactoryItem> = getItemsByResource(resource, allItems[itemType]);
			
			if (itemType == MediaFactoryItemType.STANDARD)
			{
				var item:MediaFactoryItem = resolveItems(resource, items) as MediaFactoryItem;
				if (item != null)
				{
					mediaElement = invokeMediaElementCreationFunction(item);
				}
			}
			else if (itemType == MediaFactoryItemType.PROXY)
			{
				var nextElementToWrap:MediaElement = wrappedElement;
				
				// Create our chain of proxies, starting from the bottom so
				// that we can assign the base wrapped element.  (Note that
				// we iterate from the end to the beginning simply to make
				// it easier to assign the wrappedElement in our for loop.
				// In the future, we may want to provide control for the
				// ordering to the client through some type of resolver method.
				for (var i:int = items.length; i > 0; i--)
				{
					var proxyItem:MediaFactoryItem = items[i-1] as MediaFactoryItem;
					var proxyElement:ProxyElement = invokeMediaElementCreationFunction(proxyItem) as ProxyElement;
					if (proxyElement != null)
					{
						proxyElement.proxiedElement = nextElementToWrap;
					
						nextElementToWrap = proxyElement;
					}
				}
				
				mediaElement = nextElementToWrap;
			}
			
			if (mediaElement != null)
			{
				mediaElement.resource = resource;
			}
			
			return mediaElement;
		}
		
		private static function getItemsByResource(resource:MediaResourceBase, items:Vector.<MediaFactoryItem>):Vector.<MediaFactoryItem>
		{
			var results:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			
			for each (var item:MediaFactoryItem in items)
			{			
				if (item.canHandleResourceFunction(resource))
				{
					results.push(item);
				}
			}
			
			return results;
		}
		
		private static function getIndexOfItem(id:String, items:Vector.<MediaFactoryItem>):int
		{
			for (var i:int = 0; i < items.length; i++)
			{
				var item:MediaFactoryItem = items[i] as MediaFactoryItem;
				if (item.id == id)
				{
					return i;
				}
			}
			
			return -1;
		}
		
		private function onPluginLoad(event:PluginManagerEvent):void
		{
			dispatchEvent(new MediaFactoryEvent(MediaFactoryEvent.PLUGIN_LOAD, false, false, event.resource));
		}

		private function onPluginLoadError(event:PluginManagerEvent):void
		{
			dispatchEvent(new MediaFactoryEvent(MediaFactoryEvent.PLUGIN_LOAD_ERROR, false, false, event.resource));
		}

		private function invokeMediaElementCreationFunction(item:MediaFactoryItem):MediaElement
		{
			var mediaElement:MediaElement = null;
			try
			{
				mediaElement = item.mediaElementCreationFunction();
			}
			catch (error:Error)
			{
				// Swallow, the creation function is wrongly specified.
				// We'll just return a null MediaElement.
			}
			return mediaElement;
		}
		
		private function createPluginManager():void
		{
			if (pluginManager == null)
			{
				pluginManager = new PluginManager(this);
				pluginManager.addEventListener(PluginManagerEvent.PLUGIN_LOAD, onPluginLoad);
				pluginManager.addEventListener(PluginManagerEvent.PLUGIN_LOAD_ERROR, onPluginLoadError);
			}
		}
		
		private var pluginManager:PluginManager;

		private var allItems:Dictionary;
			// Keys are: String (MediaFactoryItemType)
			// Values are: Vector.<MediaFactoryItem>
	}
}