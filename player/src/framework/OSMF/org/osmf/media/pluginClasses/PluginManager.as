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
package org.osmf.media.pluginClasses
{
	import __AS3__.vec.Vector;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.events.PluginManagerEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.utils.Version;
	
	[ExcludeClass]
	
	/**
	 * Dispatched when the PluginManager has successfully loaded a plugin.
	 *
	 * @eventType org.osmf.events.PluginManagerEvent.PLUGIN_LOAD
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="pluginLoad", type="org.osmf.events.PluginManagerEvent")]

	/**
	 * Dispatched when the PluginManager has failed to load a plugin due to an error.
	 *
	 * @eventType org.osmf.events.PluginManagerEvent.PLUGIN_LOAD_ERROR
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="pluginLoadError", type="org.osmf.events.PluginManagerEvent")]

	/**
	 * @private
	 * 
	 * This class is a manager that provide access to plugin related
	 * features.
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class PluginManager extends EventDispatcher
	{
		/**
		 * Constructor.
		 *
		 * @param mediaFactory MediaFactory within which the PluginManager will place the
		 * information from loaded plugins.
		 *
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function PluginManager(mediaFactory:MediaFactory)
		{
			super();
			
			_mediaFactory = mediaFactory;
			_mediaFactory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onMediaElementCreate);
			
			minimumSupportedFrameworkVersion = Version.lastAPICompatibleVersion;
			initPluginFactory();
			_pluginMap = new Dictionary();
			_pluginList = new Vector.<PluginEntry>();
		}
		
		/**
		 * Load a plugin identified by resource. The PluginManager will not reload the plugin
		 * if it has been loaded. Upon successful loading, a PluginManagerEvent.PLUGIN_LOAD
		 * event will be dispatched. Otherwise, a PluginManagerEvent.PLUGIN_LOAD_ERROR
		 * event will be dispatched.
		 *
		 * @param resource MediaResourceBase at which the plugin (SWF file or class) is hosted. It is assumed that 
		 * it is sufficient to identify a plugin using the MediaResourceBase.  
		 *
		 * @throws ArgumentError If resource is null or resource is not URLResource or PluginInfoResource 
		 *
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function loadPlugin(resource:MediaResourceBase):void
		{
			if (resource == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			var identifier:Object = getPluginIdentifier(resource);
			var pluginEntry:PluginEntry = _pluginMap[identifier] as PluginEntry;
			if (pluginEntry != null)
			{
				dispatchEvent
					( new PluginManagerEvent
						( PluginManagerEvent.PLUGIN_LOAD
						, false
						, false
						, resource
						)
					);
			}
			else
			{
				var pluginElement:MediaElement = _pluginFactory.createMediaElement(resource);
				
				if (pluginElement != null)
				{
					pluginEntry = new PluginEntry(pluginElement, PluginLoadingState.LOADING);
					_pluginMap[identifier] = pluginEntry;
					
					var loadTrait:LoadTrait = pluginElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
					if (loadTrait != null)
					{
						loadTrait.addEventListener(
							LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
						loadTrait.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
						loadTrait.load();
					}
					else
					{
						dispatchEvent(new PluginManagerEvent(PluginManagerEvent.PLUGIN_LOAD_ERROR, false, false, resource));
					}
				}
				else
				{
					dispatchEvent(new PluginManagerEvent(PluginManagerEvent.PLUGIN_LOAD_ERROR, false, false, resource));
				}
			}
			
			function onLoadStateChange(event:LoadEvent):void
			{
				if (event.loadState == LoadState.READY)
				{
					pluginEntry.state = PluginLoadingState.LOADED;
					_pluginList.push(pluginEntry);
					
					var pluginLoadTrait:PluginLoadTrait = pluginElement.getTrait(MediaTraitType.LOAD) as PluginLoadTrait;
					if (pluginLoadTrait.pluginInfo.mediaElementCreationNotificationFunction != null)
					{
						// Inform the newly added plugin about all previously created
						// MediaElements.
						invokeMediaElementCreationNotificationForCreatedMediaElements(pluginLoadTrait.pluginInfo.mediaElementCreationNotificationFunction);
						
						// Add our notification function to the list of functions to
						// call for future-created MediaElements.
						if (notificationFunctions == null)
						{
							notificationFunctions = new Vector.<Function>();
						}
						notificationFunctions.push(pluginLoadTrait.pluginInfo.mediaElementCreationNotificationFunction);
					}
					
					dispatchEvent
						( new PluginManagerEvent
							( PluginManagerEvent.PLUGIN_LOAD
							, false
							, false
							, resource
							)
						);
				}
				else if (event.loadState == LoadState.LOAD_ERROR)
				{
					// Remove from the pluginMap when the load failed!!!!
					delete _pluginMap[identifier];
					dispatchEvent(new PluginManagerEvent(PluginManagerEvent.PLUGIN_LOAD_ERROR, false, false, resource));
				}
			}
			function onMediaError(event:MediaErrorEvent):void
			{
				dispatchEvent(event.clone());
			}
		}

		/**
		 * Get access to the media factory that is used for plugin loading and 
		 * MediaInfo registering. Plugins can use this MediaFactory to create
		 * other types of MediaElement.
		 *
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get mediaFactory():MediaFactory
		{
			return _mediaFactory;
		}
		
		// Internals
		//
		
		private function getPluginIdentifier(resource:MediaResourceBase):Object
		{
			var identifier:Object = null;
			
			if (resource is URLResource)
			{
				identifier = (resource as URLResource).url;
			}
			else if (resource is PluginInfoResource)
			{
				identifier = (resource as PluginInfoResource).pluginInfo;
			}
					
			return identifier;
		}
				
		private function initPluginFactory():void
		{
			_pluginFactory = new MediaFactory();
			staticPluginLoader = new StaticPluginLoader(mediaFactory, minimumSupportedFrameworkVersion);
			dynamicPluginLoader = new DynamicPluginLoader(mediaFactory, minimumSupportedFrameworkVersion);
			
			// Add MediaInfo objects for the static and dynamic plugin loaders.
			//
			
			var staticPluginItem:MediaFactoryItem = new MediaFactoryItem
					( STATIC_PLUGIN_MEDIA_INFO_ID
					, staticPluginLoader.canHandleResource
					, createStaticPluginElement
					);
			_pluginFactory.addItem(staticPluginItem);
			
			var dynamicPluginItem:MediaFactoryItem = new MediaFactoryItem
					( DYNAMIC_PLUGIN_MEDIA_INFO_ID
					, dynamicPluginLoader.canHandleResource
					, createDynamicPluginElement
					);
			_pluginFactory.addItem(dynamicPluginItem);
		}
		
		private function createStaticPluginElement():MediaElement
		{
			return new PluginElement(staticPluginLoader);
		}

		private function createDynamicPluginElement():MediaElement
		{
			return new PluginElement(dynamicPluginLoader);
		}
		
		private function onMediaElementCreate(event:MediaFactoryEvent):void
		{
			// Inform any plugins that need to know about newly-created
			// MediaElements about this one.
			invokeMediaElementCreationNotifications(event.mediaElement);
			
			// Add the newly created MediaElement to our list of created
			// elements, so that it can be passed to the creation notification
			// function for any subsequently added plugins.  (Note that we
			// store it as the key only, so that it will be GC'd if this is
			// the only object that holds a reference to it.  We set the
			// value to an arbitrary Boolean.)
			if (createdElements == null)
			{
				createdElements = new Dictionary(true);
			}
			createdElements[event.mediaElement] = true;			
		}

		/**
		 * Invokes the callback for all stored notification functions, for the given
		 * MediaElement.
		 **/
		private function invokeMediaElementCreationNotifications(mediaElement:MediaElement):void
		{
			for each (var func:Function in notificationFunctions)
			{
				invokeMediaElementCreationNotificationFunction(func, mediaElement);
			}
		}
		
		private function invokeMediaElementCreationNotificationFunction(func:Function, mediaElement:MediaElement):void
		{
			try
			{
				func.call(null, mediaElement);
			}
			catch (error:Error)
			{
				// Swallow, the notification function is wrongly
				// specified.  We'll continue as-is.
			}
		}

		/**
		 * Invokes the creation callback on the given MediaFactoryItem, for
		 * all created MediaElements.
		 **/
		private function invokeMediaElementCreationNotificationForCreatedMediaElements(func:Function):void
		{
			// Remember, the MediaElements are stored as the keys (so
			// that they can be GC'd if the Dictionary holds the only
			// reference), hence we need to do a for..in.
			for (var elem:Object in createdElements)
			{
				invokeMediaElementCreationNotificationFunction(func, elem as MediaElement);
			}
		}

		private var _mediaFactory:MediaFactory;	
		private var _pluginFactory:MediaFactory;	
		private var _pluginMap:Dictionary;
		private var _pluginList:Vector.<PluginEntry>;
		
		private var notificationFunctions:Vector.<Function>;
		private var createdElements:Dictionary;
			// Keys are: MediaElement
			// Values are: Boolean (just a placeholder, the important part is the key)
		
		private var minimumSupportedFrameworkVersion:String;
		private var staticPluginLoader:StaticPluginLoader;
		private var dynamicPluginLoader:DynamicPluginLoader;

		private static const STATIC_PLUGIN_MEDIA_INFO_ID:String = "org.osmf.plugins.StaticPluginLoader";
		private static const DYNAMIC_PLUGIN_MEDIA_INFO_ID:String = "org.osmf.plugins.DynamicPluginLoader";
	}
}