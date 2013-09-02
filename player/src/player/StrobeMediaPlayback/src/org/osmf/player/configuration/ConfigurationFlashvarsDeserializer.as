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
	import flash.utils.*;
	import flash.utils.Dictionary;
	
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.player.chrome.configuration.ConfigurationUtils;
	import org.osmf.player.media.StrobeMediaPlayer;


	/**
	 * ConfigurationFlashvarsDeserializer is currently responsible
	 * for deserializing FlashVars, validating the input values and storing the external configuration values.
	 * 
	 * We will probably split this class into specialized classes responsible for 
	 * Deserialization and Validation
	 *  
	 */ 
	public class ConfigurationFlashvarsDeserializer
	{
		public function ConfigurationFlashvarsDeserializer(configurationProxy:ConfigurationProxy)
		{
			this.configurationProxy = configurationProxy;
		}
		
		/**
		 * Constructs a <code>PlayerConfiguration</code> instance and initialize it's properties.
		 * 
		 * This method also validates all the properties and this code will probably be moved to a 
		 * specialized class as soon as this need arises.
		 */
		public function deserialize(parameters:Object):void
		{	
			// WORKARROUND: for FM-950 - to be removed once this is fixed.
			if (parameters.hasOwnProperty("src") && parameters.src != null)
			{
				// Handle the special case where the user is tring to connect to a dev server running on 
				//	the same machine as the client with a url like this: "rtmp:/sudoku/room1"
				var oneSlashRegExp:RegExp = /^(rtmp|rtmp[tse]|rtmpte|rtmfp)(:\/[^\/])/i;
				var oneSlashResult:Array = parameters.src.match(oneSlashRegExp);
				var tempUrl:String = parameters.src;
				
				if (oneSlashResult != null)
				{
					tempUrl = parameters.src.replace(/:\//, "://localhost/");	
				}
				parameters.src = tempUrl;
			}
			
			// Replace the default configuration with external configuration values.
	
			var fields:Dictionary = null;
			
			for (var paramName:String in parameters)
			{	
				var paramValue:String = parameters[paramName];			
				configurationProxy[paramName] = paramValue;
			} 	
			
			// Deserialize plugin configurations
			parameters["plugin_src"] = "http://osmf.org/metadata.swf";
			var plugins:Object = {};
			deserializePluginConfigurations(parameters, plugins);
			// Merge metadata
			for (var key:String in plugins.src.metadata)
			{
				configurationProxy.metadata[key] = plugins.src.metadata[key];
			}
			
			delete plugins.src;
			// Merge plugin metadata
			for (var pluginAlias:String in plugins)
			{
				configurationProxy.plugins[pluginAlias] = plugins[pluginAlias];				
			}	
		}
		
		/**
		 * Creates an array of PluginConfiguration objects out of a parameters array (flashvars).
		 * 
		 */ 
		public function deserializePluginConfigurations(parameters:Object, result:Object):void
		{
			var plugins:Object = new Object();
			var pluginNamespaces:Object = new Object();
			
			// First lets collect the names and src for all the plugins
			var paramName:String;
			var paramValue:String;
			var pluginName:String;
			
			var propertyName:String;
			var pos:int;
			var nssep:int;
			var nsalias:String;
			
			// The parameters array is being scanned twice because we need to create 
			// the list of valid plugins priors to deserializing their parameters.
			for (paramName in parameters)
			{	
				paramValue = parameters[paramName];
				if (paramName.indexOf(PLUGIN_PREFIX+PLUGIN_SEPARATOR) == 0)
				{						
					pluginName = paramName.substring(PLUGIN_PREFIX.length + PLUGIN_SEPARATOR.length);
					// Ignore the plugins with names that match the PLUGIN_PREFIX
					// Ingore the plugins that contains the separator in their name
					if (pluginName!=PLUGIN_PREFIX && validateAgainstPatterns(pluginName, VALIDATION_PATTERN) )
					{
						var pluginConfiguration:Object;
						
						// if the src starts with http or file or ends with .swf, we assume it's an absolute/relative url to a dynamic plugin
						if ( (paramValue.substr(0, 4) == "http" 
								|| paramValue.substr(0, 5) == "https" 
							  	|| paramValue.substr(0, 4) == "file" 
								|| paramValue.substr(paramValue.length-4, 4) == ".swf") 
							 && ConfigurationUtils.validateURLProperty(paramName, paramValue, true))
						{
							if (result.hasOwnProperty(pluginName))
							{
								pluginConfiguration = result[pluginName];
							}
							else
							{
								pluginConfiguration = {};
								result[pluginName] = pluginConfiguration;
								result[pluginName].metadata = {};
							}
							
							pluginConfiguration.src = paramValue;
						}
					
						if(pluginConfiguration)
						{
							plugins[pluginName] = pluginConfiguration;
							pluginNamespaces[pluginName] = new Object();
						}
					}
				}
			}
			
			// Now lets add the namespaces
			for (paramName in parameters)			
			{
				paramValue = parameters[paramName];
				pos = paramName.indexOf(PLUGIN_SEPARATOR); 
				if (pos>0)
				{
					pluginName = paramName.substring(0, pos);
					propertyName = paramName.substring(pos + 1);
					if (pluginNamespaces.hasOwnProperty(pluginName))
					{
						if (propertyName.indexOf(NAMESPACE_PREFIX) == 0)
						{
							nssep = propertyName.indexOf(NAMESPACE_SEPARATOR);
							nsalias = DEFAULT_NAMESPACE_NAME; 
							if (nssep > 0)
							{
								nsalias = propertyName.substring(nssep + 1);
							}
							if (nsalias!= NAMESPACE_PREFIX && validateAgainstPatterns(nsalias, VALIDATION_PATTERN))
							{
								pluginNamespaces[pluginName][nsalias] = new Object();
								pluginNamespaces[pluginName][nsalias][NAMESPACE_PREFIX] = paramValue;
							}
						}
					}
				}
			}
			
			// Now lets add additional parameters
			for (paramName in parameters)			
			{
				paramValue = parameters[paramName];
				pos = paramName.indexOf(PLUGIN_SEPARATOR); 
				if (pos>0)
				{
					pluginName = paramName.substring(0, pos);
					propertyName = paramName.substring(pos + 1);
					if (plugins.hasOwnProperty(pluginName) && propertyName != PLUGIN_PREFIX)
					{
						nssep = propertyName.indexOf(NAMESPACE_SEPARATOR);
						nsalias = DEFAULT_NAMESPACE_NAME; 
						if (nssep > 0)
						{
							var temp:String = propertyName.substring(0, nssep);
							if (pluginNamespaces[pluginName].hasOwnProperty(temp))
							{
								nsalias = temp;
								propertyName = propertyName.substring(nssep + 1);
							}
						}
						if (pluginNamespaces[pluginName].hasOwnProperty(nsalias))					
						{
							pluginNamespaces[pluginName][nsalias][propertyName] = paramValue;
						}
						else
						{
							if (!pluginNamespaces[pluginName].hasOwnProperty(ROOT))
							{
								pluginNamespaces[pluginName][ROOT] = new Object();
							}
							pluginNamespaces[pluginName][ROOT][propertyName] = paramValue;
						}
					}
				}
			}
			for (pluginName in pluginNamespaces)
			{
				for (nsalias in pluginNamespaces[pluginName])
				{					
					var namespace:String = pluginNamespaces[pluginName][nsalias][NAMESPACE_PREFIX];
					var metadata:Object = result[pluginName].metadata;
				
					
					for (propertyName in pluginNamespaces[pluginName][nsalias])
					{
						if (propertyName.indexOf(NAMESPACE_PREFIX) != 0)
						{
							if (nsalias == ROOT)
							{
								addMetadataValue(result[pluginName].metadata, propertyName, pluginNamespaces[pluginName][nsalias][propertyName]);
							}
							else
							{
								if (!result[pluginName].metadata.hasOwnProperty(namespace))
								{
									result[pluginName].metadata[namespace] = {};
								}
								addMetadataValue(result[pluginName].metadata[namespace], propertyName, pluginNamespaces[pluginName][nsalias][propertyName]);
							}
						}
					}
				}
			}
		}
		
		// Internals		
		private function validateAgainstPatterns(value:String, pattern:RegExp):Boolean
		{
			var matches:Array = value.match(pattern);
			return (matches!=null) && (matches[0] == value); 
		}
		
		private function addMetadataValue(metadata:Object, propertyName:String, stringValue:String):void
		{	
			var typedValue:Object = ConfigurationUtils.inferTypedValue(propertyName, stringValue);
			
			metadata[propertyName] = typedValue;			
		}

		/**
		 * The prefix which is used for identifying the plugins.
		 */ 
		private static const PLUGIN_PREFIX:String = "plugin";
		
		/**
		 * The prefix which is used for identifying the namespace parameter.
		 */ 
		private static const NAMESPACE_PREFIX:String = "namespace";
		
		/**
		 * The separator between the plugin prefix and their parameters.
		 */ 
		private static const PLUGIN_SEPARATOR:String = "_";
		private static const NAMESPACE_SEPARATOR:String = "_";
		private static const DEFAULT_NAMESPACE_NAME:String = "defaultNamespace";
		private static const ROOT:String = "roooooooooooot";
		
		private static const VALIDATION_PATTERN:RegExp = /[a-zA-Z][0-9a-zA-Z]*/;
		
		
		private var configurationProxy:ConfigurationProxy;
	}
}