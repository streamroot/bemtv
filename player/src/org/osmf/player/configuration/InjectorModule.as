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

package org.osmf.player.configuration
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.player.chrome.configuration.ConfigurationUtils;
	
	CONFIG::LOGGING
	{
		import org.osmf.player.debug.DebugStrobeMediaPlayer;
	}

	import org.osmf.player.media.StrobeMediaPlayer;
	import org.osmf.media.MediaFactory;
	import org.osmf.player.media.StrobeMediaFactory;
	import org.osmf.net.MulticastResource;

	/**
	 * A basic implementation of a dependency injection module.
	 * Used for separating the UI logic from dependency setup code.
	 */ 
	public class InjectorModule
	{
		public function InjectorModule()
		{
			initialize();
		}
		
		/**
		 * Provides an instance of the specified class.
		 */ 
		public function getInstance(kind:Class):*
		{
			var className:String = getQualifiedClassName(kind);
			if (instances.hasOwnProperty(className))
			{
				return instances[className];
			}
			else if (classBindings.hasOwnProperty(className))
			{
				return new classBindings[className];
			}
			else if (providers.hasOwnProperty(className))
			{
				var provider:Function = providers[className];
				return provider.call();				
			}
		}
		
		public function bindClass(kind:Class, targetClass:Class):void
		{
			classBindings[getQualifiedClassName(kind)] = targetClass;
		}
		
		public function bindInstance(kind:Class, instance:*):void
		{
			instances[getQualifiedClassName(kind)] = instance;
		}
		
		public function bindProvider(kind:Class, providerMethod:Function):void
		{
			providers[getQualifiedClassName(kind)] = providerMethod;
		}
		
		// Internals
		private var classBindings:Dictionary = new Dictionary();
		private var instances:Dictionary = new Dictionary();
		
		private var providers:Dictionary = new Dictionary();
		private var providerConfigurations:Dictionary = new Dictionary();

		private function initialize():void
		{
			bindInstance(PlayerConfiguration, new PlayerConfiguration());
			bindInstance(MediaPlayer, new StrobeMediaPlayer());
				
			CONFIG::LOGGING
			{
				// Overwrite the MediaPlayer with the Debug version
				CONFIG::FLASH_10_1
				{
					bindInstance(MediaPlayer, new DebugStrobeMediaPlayer());
				}
			}
		
			bindProvider(MediaResourceBase, provideResource);
			bindProvider(ConfigurationFlashvarsDeserializer, provideConfigurationFlashvarsDeserializer);
			bindProvider(ConfigurationXMLDeserializer, provideConfigurationXMLDeserializer);
			bindProvider(ConfigurationProxy, provideConfigurationProxy);
			
			bindProvider(ConfigurationLoader, provideConfigurationLoader);
			
			bindProvider(MediaFactory, provideMediaFactory);
		}
		
		private function provideResource():MediaResourceBase
		{
			var configuration:PlayerConfiguration = getInstance(PlayerConfiguration);
			var resource:MediaResourceBase;
			
			if (configuration.resource.hasOwnProperty("groupspec"))
			{
				resource = new MulticastResource(configuration.src);
				
				if (configuration.resource.hasOwnProperty("multicastStreamName"))
				{
					// The public f4m config value and the API name of the multicastStreamName do not match
					(resource as MulticastResource).streamName = configuration.resource.multicastStreamName;					
				}
			}
			else
			{
				resource = new StreamingURLResource(configuration.src);
			}
			for (var name:String in configuration.resource)
			{
				var value:Object = configuration.resource[name];
				resource[name] = value;
			}
			// Add the configuration metadata to the resource.
			// Transform the Object to Metadata instance.
			ConfigurationUtils.addMetadataToResource(configuration.metadata, resource);
			return resource;
		}
		
		private function provideConfigurationFlashvarsDeserializer():ConfigurationFlashvarsDeserializer			
		{
			var configurationDeserializer:ConfigurationFlashvarsDeserializer = new ConfigurationFlashvarsDeserializer(getInstance(ConfigurationProxy));			
			return configurationDeserializer;
		}
		
		private function provideConfigurationProxy():ConfigurationProxy
		{
			var configurationProxy:ConfigurationProxy = new ConfigurationProxy();
					
			var pcf:Dictionary = ConfigurationUtils.retrieveFields(PlayerConfiguration);
			configurationProxy.registerConfigurableProperties(pcf, getInstance(PlayerConfiguration));				
			
			var mpf:Dictionary = ConfigurationUtils.retrieveFields(StrobeMediaPlayer);
			configurationProxy.registerConfigurableProperties(mpf, getInstance(MediaPlayer));				
				
			var resourceFields:Dictionary = ConfigurationUtils.retrieveFields(MulticastResource);
			delete resourceFields["connectionArguments"];
			delete resourceFields["drmContentData"];
			configurationProxy.registerConfigurableProperties(resourceFields, 
				getInstance(PlayerConfiguration).resource);
			
			return configurationProxy;
		}
		
		private function provideConfigurationXMLDeserializer():ConfigurationXMLDeserializer
		{
			var deserializer:ConfigurationXMLDeserializer = new ConfigurationXMLDeserializer(getInstance(ConfigurationProxy));
			return deserializer;
		}
		
		private function provideConfigurationLoader():ConfigurationLoader
		{
			var configurationLoader:ConfigurationLoader = new ConfigurationLoader(getInstance(ConfigurationFlashvarsDeserializer), getInstance(ConfigurationXMLDeserializer));			
			return configurationLoader;	
		}
		
		private function provideMediaFactory():MediaFactory
		{
			var mediaFactory:MediaFactory = new StrobeMediaFactory(getInstance(PlayerConfiguration));
			return mediaFactory;
		}
	}
}