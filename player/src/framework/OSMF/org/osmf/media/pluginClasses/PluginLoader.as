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
	import flash.display.Loader;
	
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.PluginInfo;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.Version;
	
	CONFIG::LOGGING
	{
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;
	}

	/**
	 * The PluginLoader class extends LoaderBase to provide
	 * loading support for plugins.
	 * It is the base class
	 * for creating static and dynamic plugin loaders.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	internal class PluginLoader extends LoaderBase
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function PluginLoader(mediaFactory:MediaFactory, minimumSupportedFrameworkVersion:String)
		{			
			this.mediaFactory = mediaFactory;
			this.minimumSupportedFrameworkVersion = minimumSupportedFrameworkVersion;
		}
		
		/**
		 * Unloads the given PluginInfo.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		protected function unloadFromPluginInfo(pluginInfo:PluginInfo):void
		{
			if (pluginInfo != null)
			{
				for (var i:int = 0; i < pluginInfo.numMediaFactoryItems; i++)
				{
					var item:MediaFactoryItem = pluginInfo.getMediaFactoryItemAt(i);
					
					var actualItem:MediaFactoryItem = mediaFactory.getItemById(item.id);
					if (actualItem != null)
					{
						mediaFactory.removeItem(actualItem);
					}
				}
			}
		}
		
		/**
		 * Loads the plugin into the LoadTrait.
		 * On success sets the LoadState of the LoadTrait to LOADING, 
		 * on failure to LOAD_ERROR.
		 * @param pluginInfo PluginInfo instance to use for this load operation.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function loadFromPluginInfo(loadTrait:LoadTrait, pluginInfo:PluginInfo, loader:Loader = null):void
		{
			var invalidImplementation:Boolean = false;
			
			if (pluginInfo != null)
			{
				if (isPluginCompatible(pluginInfo))	
				{
					try
					{
						// Make sure the plugin metadata has the expected default params
						// (such as MediaFactory).
						var passedMediaFactory:MediaFactory = loadTrait.resource.getMetadataValue(PluginInfo.PLUGIN_MEDIAFACTORY_NAMESPACE) as MediaFactory;
						if (passedMediaFactory == null)
						{
							loadTrait.resource.addMetadataValue(PluginInfo.PLUGIN_MEDIAFACTORY_NAMESPACE, mediaFactory);
						}
						
						pluginInfo.initializePlugin(loadTrait.resource);
					
						for (var i:int = 0; i < pluginInfo.numMediaFactoryItems; i++)
						{
							// Range error usually comes from this method call.  But
							// we generate an error if the returned value is null.
							var item:MediaFactoryItem = pluginInfo.getMediaFactoryItemAt(i);
							if (item == null)
							{
								throw new RangeError();
							}
							
							mediaFactory.addItem(item);							
						}
						
						var pluginLoadTrait:PluginLoadTrait = loadTrait as PluginLoadTrait;
						pluginLoadTrait.pluginInfo = pluginInfo;
						pluginLoadTrait.loader = loader;
						updateLoadTrait(pluginLoadTrait, LoadState.READY);
					}
					catch (error:RangeError)
					{
						// Range error when retrieving media infos.
						invalidImplementation = true;
					}
				}
				else
				{
					// Version not supported by plugin.
					updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
					loadTrait.dispatchEvent
						( new MediaErrorEvent
							( MediaErrorEvent.MEDIA_ERROR
							, false
							, false
							, new MediaError(MediaErrorCodes.PLUGIN_VERSION_INVALID)
							)
						);
				}
			}
			else
			{
				// No PluginInfo on root.
				invalidImplementation = true;
			}
			
			if (invalidImplementation)
			{
				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
				loadTrait.dispatchEvent
					( new MediaErrorEvent
						( MediaErrorEvent.MEDIA_ERROR
						, false
						, false
						, new MediaError(MediaErrorCodes.PLUGIN_IMPLEMENTATION_INVALID)
						)
					);
			}
		}
		
		protected function isPluginCompatible(pluginInfo:Object):Boolean
		{
			var isCompatible:Boolean = false;
			
			var version:String = 	pluginInfo.hasOwnProperty(FRAMEWORK_VERSION_PROPERTY_NAME)
								 ?	pluginInfo[FRAMEWORK_VERSION_PROPERTY_NAME]
								 : null;
			var isSupported:Boolean = isPluginVersionSupported(version)
			if (isSupported)
			{
				var versionSupportedFunction:Function
					= pluginInfo.hasOwnProperty(IS_FRAMEWORK_VERSION_SUPPORTED_PROPERTY_NAME)
					? pluginInfo[IS_FRAMEWORK_VERSION_SUPPORTED_PROPERTY_NAME] as Function
					: null
				
				if (versionSupportedFunction != null)
				{
					try
					{
						isCompatible = versionSupportedFunction(Version.version);
					}
					catch (error:Error)
					{
						// Swallow -- if the function is missing or incorrectly
						// specified, then it's clearly not compatible.
					}
				}
				
				CONFIG::LOGGING
				{
					if (!isCompatible)
					{
						logger.debug("Player version '" + Version.version + "' not supported by loaded plugin");
					}
				}
			}
			
			CONFIG::LOGGING
			{
				if (!isSupported)
				{
					logger.debug("Plugin version '" + version + "' not supported by loading player (whose version is " + Version.version + ")");
				}
			}
			
			return isCompatible;
		}

		private function isPluginVersionSupported(pluginVersion:String):Boolean
		{
			if (pluginVersion == null || pluginVersion.length == 0)
			{
				return false;
			}
			
			var minVersion:Object = VersionUtils.parseVersionString(minimumSupportedFrameworkVersion);
			var pVersion:Object = VersionUtils.parseVersionString(pluginVersion);
			
			// A player can load a plugin provided that the plugin's version is
			// at least as great as the minimum supported framework version.
			return 		pVersion.major > minVersion.major
					||	(	pVersion.major == minVersion.major
						&&	pVersion.minor >= minVersion.minor
						);
		}
		
		private var minimumSupportedFrameworkVersion:String;
		private var mediaFactory:MediaFactory;
		
		private static const FRAMEWORK_VERSION_PROPERTY_NAME:String = "frameworkVersion";
		private static const IS_FRAMEWORK_VERSION_SUPPORTED_PROPERTY_NAME:String = "isFrameworkVersionSupported";
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.media.pluginClasses.PluginLoader");
		}
	}
}