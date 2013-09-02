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
 **********************************************************/

package org.osmf.player.chrome.configuration
{	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.player.metadata.StrobeDynamicMetadata;
	import org.osmf.utils.URL;
	
	/**
	 * Configuration utility functions
	 */ 
	public class ConfigurationUtils
	{

		/**
		 * Return a dictionary describing every settable field on this object or class.
		 *
		 * Fields are indexed by name, and the type is contained as a string.
		 */
		public static function retrieveFields(c:*, ignoreReadOnly:Boolean = true):Dictionary
		{		
			var typeDict:Dictionary = new Dictionary();
			try
			{
				if (!(c is Class))
				{
					// Convert to its class.
					c = getDefinitionByName(getQualifiedClassName(c));
				}
				
				// Otherwise describe the type...
				var typeXml:XML = describeType(c);				
			
				// Walk all the variables...
				for each (var variable:XML in typeXml.factory.variable)
				typeDict[variable.@name.toString()] = variable.@type.toString();
				
				// And all the accessors...
				for each (var accessor:XML in typeXml.factory.accessor)
				{
					// Ignore ones we can't write to.
					if (ignoreReadOnly && accessor.@access == "readonly")
						continue;
					
					typeDict[accessor.@name.toString()] = accessor.@type.toString();
				}
			}
			catch(ignore:Error)
			{
				
			}			
			
			return typeDict;
		}
	
		/**
		 * Adds the properties from a dynamic object as metadata of a MediaResourceBase instance.
		 */ 
		public static function addMetadataToResource(metadata:Object, resource:MediaResourceBase):void
		{			
			for (var ns:String in metadata)
			{
				var isNamespace:Boolean = true;
				var pluginMetadata:StrobeDynamicMetadata = new StrobeDynamicMetadata();
				for (var ns2:String in metadata[ns])
				{
					pluginMetadata.addValue(ns2, metadata[ns][ns2]);
					isNamespace = false;
				}
				if (isNamespace)
				{
					resource.addMetadataValue(ns, metadata[ns]);
				}
				else
				{
					resource.addMetadataValue(ns, pluginMetadata);
				}
			}
		}
		
		/**
		 * Transforms a dynamic object containing resource metadata into
		 * a collection of immutable MediaResourceBase instances.
		 */ 
		public static function transformDynamicObjectToMediaResourceBases(plugins:Object):Vector.<MediaResourceBase>
		{
			var resources:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			for (var key:String in plugins)
			{
				var pluginConfiguration:Object = plugins[key];	
				var pluginResource:URLResource = new URLResource(pluginConfiguration.src);
				addMetadataToResource(pluginConfiguration.metadata, pluginResource);
				resources.push(pluginResource);
			}
			return resources;
		}
		
		public static function inferTypedValue(name:String, value:*):*
		{
			if (value is String)
			{
				var result:Object;
				var stringValue:String = value as String;
				if (name.indexOf("Color") > 0) 
				{
					stringValue = stripColorCode(stringValue);							
					var tmp:Number = parseInt("0x" + stringValue);
					// Ignore invalid values. keep the default.
					if (!isNaN(tmp) && tmp <= 0xFFFFFF)
					{
						result = tmp;
					}
				}			
				else if (stringValue.toLocaleLowerCase() == TRUE)
				{
					result = true;
				}
				else if (stringValue.toLocaleLowerCase() == FALSE)
				{
					result = false;
				}
				else
				{				
					var numberTmp:Number = parseFloat(stringValue);
					if (!isNaN(numberTmp) && numberTmp.toString() == stringValue)
					{	
						result = numberTmp;
					}
					else
					{
						result = stringValue;
					}
				}	
				
				return result;
			}
			else
			{
				return value;
			}
		}	
		
		/**
		 * Removes the "#" and "0x" prefixes on strings representing colors
		 *  
		 * @param color
		 * @return string without the prepending "#" on "0x"
		 * 
		 */
		private static function stripColorCode(color:String):String
		{
			var strippedColor:String = color;
			
			if (color.substring(0,1) == '#')
			{
				strippedColor = color.substring(1);
			}
			else if (color.substring(0,2) == '0x')
			{
				strippedColor = color.substring(2);
			}
			return strippedColor;
		}
		
		/**
		 * Validates an URL
		 */ 
		public static function validateURLProperty(paramName:String, paramValue:String, isPluginUrl:Boolean = false):Boolean
		{
			if (paramValue.indexOf("javascript:") == 0) return false;
			// Validate the URL using the OSMF private api. We don't know if it's the best approach,
			// but we choose to do so because we want this validation to be consistent with the OSMF framework.			
			var url:URL = new URL(paramValue);
			// Checking the host name is enough for absolute paths.
			// For relative paths we only check that it's actually a swf file name if we are reffering to a plugin.
			if ( (url.absolute && url.host.length>0) 
				|| ( isPluginUrl 
					? paramValue.match(/^[^:]+swf$/) 
					: (url.path == url.rawUrl)
				) )
			{
				return true;
			}
			return false;
		}
		
		/**
		 * Validates an URL
		 */ 
		public static function validatePluginURLProperty(paramName:String, paramValue:String, isPluginUrl:Boolean = false):Boolean
		{
			// Validate the URL using the OSMF private api. We don't know if it's the best approach,
			// but we choose to do so because we want this validation to be consistent with the OSMF framework.			
			var url:URL = new URL(paramValue);
			// Checking the host name is enough for absolute paths.
			// For relative paths we only check that it's actually a swf file name if we are reffering to a plugin.
			if ( (url.absolute && url.host.length>0) 
				|| ( isPluginUrl 
					? paramValue.match(/^[^:]+swf$/) 
					: (url.path == url.rawUrl && paramValue.search("javascript") != 0)
				) )
			{
				return true;
			}
			return false;
		}
		
		
		private static const TRUE:String = "true";
		private static const FALSE:String = "false";
	}
}