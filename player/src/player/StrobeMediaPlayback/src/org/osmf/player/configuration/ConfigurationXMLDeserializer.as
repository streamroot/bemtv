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
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.xml.XMLNode;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.player.chrome.configuration.ConfigurationUtils;

	/**
	 * Deserializes an XML file into a PlayerConfiguration object.
	 */ 
	public class ConfigurationXMLDeserializer
	{
		public function ConfigurationXMLDeserializer(flatDeserializer:ConfigurationProxy)
		{
			this.configurationProxy = flatDeserializer;			
		}
		
		/**
		 * Constructs a <code>ConfigurationXMLDeserializer</code> instance and initialize it's properties.
		 * 
		 */
		public function deserialize(config:XML):void
		{
			addChildKeyValuePairs(config, configurationProxy);
			
			// Retrieve children		
			var children:XMLList = config.children(); 
			for(var ci:uint = 0; ci < children.length(); ci++) 
			{
				var child:XML = children[ci];
				var childName:String = child.name();
				if (childName == PLUGIN)
				{
					deserializePluginConfiguration(configurationProxy.plugins, child);
				}	
				else if (childName == METADATA)
				{					
					addMetadataValues(child, configurationProxy.metadata);
				}					
			}
		}
		
		/**
		 * Updates the provided plugin structure with the data from the XML node.
		 */
		public function deserializePluginConfiguration(plugins:Object, pluginNode:XML):void
		{
			// Generate a plugin alias
			var idx:uint = 0;
			var pluginName:String = "p" + idx;
			while (plugins.hasOwnProperty(pluginName))
			{
				idx ++;
				pluginName = "p" + idx;
			}			
			var src:String = pluginNode.src || pluginNode.@src;
			if (!plugins.hasOwnProperty(pluginName))
			{
				plugins[pluginName] = {};
			}
			plugins[pluginName].src = src.toString();
		
			var children:XMLList = pluginNode.children(); 
			for(var ci:uint = 0; ci < children.length(); ci++) 
			{
				var child:XML = children[ci];
				var childName:String = child.name();
				if (childName == METADATA)
				{
					plugins[pluginName].metadata = {};
					addMetadataValues(child, plugins[pluginName].metadata);						
				}				
			}
		}
		
		// Internals
		//
		private const METADATA:String = "metadata";
		private const PLUGIN:String = "plugin";
		private const PARAM:String = "param";
		private const NAMESPACE:String = "namespace";
		private const ARRAY:String = "array";
		private const INFER:String = "infer";

		private const ID:String = "id";
		private const TYPE:String = "type";
		private const ASSET_METADATA_PREFIX:String = "src_";
		
		private var configurationProxy:ConfigurationProxy;
		
		private function addMetadataValues(node:XML, params:Object):void
		{
			var namespace:String = node.@id;			
			if (namespace.length > 0)
			{			
				if (!params.hasOwnProperty(namespace))
				{
					params[namespace] = {};
				}
				delete node.@id[0];
				addChildKeyValuePairs(node, params[namespace]);
			}		
			else
			{
				addChildKeyValuePairs(node, params);
			}
		}
		
		private function addChildKeyValuePairs(node:XML, target:*, targetType:String = "infer"):void
		{	
			var attributes:XMLList = node.attributes();			
			for(var ai:uint = 0; ai < attributes.length(); ai++) {
				var attributeName:String = attributes[ai].name();
				if (attributeName != ID && attributeName != TYPE)
				{
					addValue(target, targetType, attributeName, node.attribute(attributeName).toString());				
				}
			}
			
			// Retrieve children		
			var children:XMLList = node.children(); 
			for(var ci:uint = 0; ci < children.length(); ci++) 
			{
				var child:XML = children[ci];		
				
				if (child.nodeKind() != "element")
				{
					continue;
				}
				
				var childName:String = child.name().toString() as String;	
				
				if (childName != METADATA && childName != PLUGIN)
				{	
					if (childName == PARAM)
					{
						// TODO: deprecate PARAM
						addValue(target, targetType, child.@name.toString(), child.@value.toString());
					}
					else
					{
						if (child.hasComplexContent())
						{
							var type:String = child.@type.toString() || INFER;
							type = type.toLowerCase();	
							var targetValue:*;
							if (type == ARRAY)
							{
								targetValue = [];
								delete node.@type[0];
							}
							else
							{
								if (targetType != ARRAY)
								{
									if (!target.hasOwnProperty(childName))
									{
										target[childName] = {};
									}
									targetValue = target[childName];
								}
								else
								{
									targetValue = {};
								}
							}
							addValue(target, targetType, childName, targetValue);
							addChildKeyValuePairs(child, targetValue, type);
						}
						else
						{
							addValue(target, targetType, childName, child.toString());
						}
					}
				}
			}
		}

		private function addValue(target:*, targetType:String, propertyName:String, stringValue:*):void
		{
			if (targetType == ARRAY)
			{			
				target.push(ConfigurationUtils.inferTypedValue(propertyName, stringValue));
			}
			else
			{
				target[propertyName] = ConfigurationUtils.inferTypedValue(propertyName, stringValue);
			}
		}
	}
}