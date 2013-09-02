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

package org.osmf.player.plugins
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.player.errors.StrobePlayerErrorCodes;
	import org.osmf.player.utils.StrobePlayerStrings;

	/**
	 * This class is responsible for loading multiple 
	 * plugins and passing along their configuration settings.
	 * 
	 * It is also responsible for implementing a white-list mechanism to help
	 * protest StrobeMediaPlayback users from security risks.
	 */ 
	public class PluginLoader extends EventDispatcher
	{
		// Public Interface
		//
		
		/** Not exposed as a public setting. */
		public static const PLUGIN_LOAD_MAX_RETRY_COUNT:int = 2;
		
		// Public settings
		public var haltOnError:Boolean = false;
		
		// PluginLoader Stats. Exposed for unit tests.
		// IMPROVEMENT SUGGESTION: (thx Wei) Instead of keeping counts we can keep the list of failed/loaded plugins.
		// This might be interesting information to display in the debug console.
		internal var pluginCount:int = 0;
		internal var loadedCount:int = 0;
		internal var failCount:int = 0;
		internal var retryCount:int = 0;
		
		/**
		 * Constructor
		 *  
		 * @param pluginConfigurations
		 * @param mediaFactory
		 * 
		 */		
		public function PluginLoader(pluginConfigurations:Vector.<MediaResourceBase>, mediaFactory:MediaFactory, pluginHostWhitelist:Vector.<String>)
		{
			this.pluginResources = pluginConfigurations;
			this.mediaFactory = mediaFactory;
			this.pluginHostWhitelist = pluginHostWhitelist;
		}
		
		/**
		 * Loads all the external plugins. The playback of the media will start once all the plugins get loaded.
		 * If a plugin fails to load the Playwe will try to play the media file anyway. 
		 */ 
		public function loadPlugins():void
		{			
			if (pluginResources.length > 0)
			{				
				var resource:MediaResourceBase;				
				var pluginsToLoad:Vector.<MediaResourceBase> 
					= new Vector.<MediaResourceBase>()
					
				// Verify the whitelist first
				if (pluginHostWhitelist && pluginHostWhitelist.length > 0)
				{					
					for each(resource in pluginResources)
					{	
						var url:String = (resource as URLResource).url;
						var protocol:String = url.substring(0, url.indexOf("://"));
						
						var acceptPlugin:Boolean = false;
						for each(var host:String in pluginHostWhitelist)
						{
							// Check if the url starts with the host name (prefixed by the protocol)
							// Note that the trailing "/" is important!
							if (url.indexOf(protocol + "://" + host + "/") == 0)
							{
								acceptPlugin = true;
								break;
							}
						}
						
						if (acceptPlugin)
						{
							pluginsToLoad.push(resource);
						}
						else
						{
							if (haltOnError)
							{
								var details:String = StrobePlayerStrings.getString(StrobePlayerStrings.PLUGIN_NOT_IN_WHITELIST, [url]);
								var mediaError:MediaError
									= new MediaError(StrobePlayerErrorCodes.PLUGIN_NOT_IN_WHITELIST
										, details
									);
								
								dispatchEvent
									( new MediaErrorEvent
										( MediaErrorEvent.MEDIA_ERROR
											, false
											, false
											, mediaError
										)
									);
									
								// Stop loading any other plugins.
								return;
							}
						}						
					}
				}
				else
				{
					pluginsToLoad = pluginResources;
				}
				
				if (pluginsToLoad.length > 0)
				{
					mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoad);
					mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadError);				
					pluginCount = pluginsToLoad.length;
					for each(resource in pluginsToLoad)
					{	
						mediaFactory.loadPlugin(resource);						
					}
				}
				else
				{
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}
			else
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		// Internals
		//			
		private var pluginHostWhitelist:Vector.<String> = null;
		private var pluginResources:Vector.<MediaResourceBase>;
		private var mediaFactory:MediaFactory;
			
		private function onPluginLoad(event:MediaFactoryEvent):void
		{
			loadedCount++;
			
			if (loadedCount + failCount == pluginCount)
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function onPluginLoadError(event: MediaFactoryEvent):void
		{	
			if (retryCount < PLUGIN_LOAD_MAX_RETRY_COUNT)
			{
				retryCount ++;
				mediaFactory.loadPlugin(event.resource);
			}
			else
			{
				failCount ++;
				if (haltOnError)
				{
					var mediaError:MediaError
						= new MediaError(StrobePlayerErrorCodes.PLUGIN_LOAD_FAILED);
					
					dispatchEvent
					( new MediaErrorEvent
						( MediaErrorEvent.MEDIA_ERROR
							, false
							, false
							, mediaError
						)
					);
					
				}
				else if (loadedCount + failCount == pluginCount)
				{					
					dispatchEvent(new Event(Event.COMPLETE));					
				}
			}			
		}
	}
}