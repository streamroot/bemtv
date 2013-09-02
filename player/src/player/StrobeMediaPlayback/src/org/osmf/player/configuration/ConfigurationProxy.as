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
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.utils.getDefinitionByName;
	
	import org.osmf.layout.ScaleMode;
	import org.osmf.player.chrome.configuration.ConfigurationUtils;
	import org.osmf.utils.URL;
	
	dynamic public class ConfigurationProxy extends Proxy
	{		
		/**
		 * Registers new fields that need to be deserialized from the input data. 
		 * The input values will be written back to the target isntance.
		 */ 
		public function registerConfigurableProperties(fields:Dictionary, target:*, mapping:Object = null):void
		{
			configOrder.push(target);
			configClasses[target] = fields;
			configMapping[target] = mapping;
		}
		
		override flash_proxy function hasProperty(name:*):Boolean 
		{
			var paramName:String = name;
			var present:Boolean = false;
			var target:Object;
			for each(target in configOrder)
			{
				if (configMapping[target] && configMapping[target].hasOwnProperty(paramName))
				{
					paramName = configMapping[target][paramName];
				}
				if (configClasses[target].hasOwnProperty(paramName))
				{
					present = true;
					break;
				}
			}
			return present;
		}
	
		override flash_proxy function getProperty(name:*):*
		{
			var paramName:String = name;
			var present:Boolean = false;
			var target:Object;
			for each(target in configOrder)
			{
				if (configMapping[target] && configMapping[target].hasOwnProperty(paramName))
				{
					paramName = configMapping[target][paramName];
				}
				if (configClasses[target].hasOwnProperty(paramName))
				{
					present = true;
					break;
				}
			}
			return target[paramName];
		}
		
		override flash_proxy function setProperty(name:*, paramValue:*):void 
		{
			var paramName:String = name;
			var fields:Dictionary = null;
			var present:Boolean = false;
			var target:Object;
			for each(target in configOrder)
			{
				if (configMapping[target] && configMapping[target].hasOwnProperty(paramName))
				{
					paramName = configMapping[target][paramName];
				}
				if (configClasses[target].hasOwnProperty(paramName))
				{
					present = true;
					fields = configClasses[target];
					break;
				}
			}
			
			if (present)
			{		
				if (paramValue != null)
				{	
					if (paramValue is String &&  paramValue.length == 0)
					{
						return;
					}
					var kind:Class = getDefinitionByName(fields[paramName]) as Class;
					if (paramValue is String)
					{
						
						paramValue = ConfigurationUtils.inferTypedValue(paramName, paramValue);
					}
					
					
					if (validators.hasOwnProperty(paramName))																
					{
						if (validators[paramName](paramName, paramValue))
						{
							if (paramValue is kind)
							{
								target[paramName] = paramValue;
							}
						}
					}
					else
					{					
						if (paramValue is kind)
						{
							target[paramName] = paramValue;
						}
					}
				}
			}
		}		
	
		/**
		 * Checks that an option is a valid value of an enumeration.
		 */ 
		private function validateEnumProperty(paramName:String, paramValue:Object):Boolean
		{
			var options:Array = enumerationValues[paramName];
			if (options.indexOf(paramValue)>=0)
			{
				return true;
			}	
			return false;
		}
		
		
		/**
		 * The list of accepted options for enumration properties.
		 * 
		 * This is used as a workarround for the lask of enumeration types in actionscript.
		 */ 
		private const enumerationValues:Object = 
			{
				scaleMode: [ScaleMode.LETTERBOX, ScaleMode.NONE, ScaleMode.STRETCH, ScaleMode.ZOOM],
				controlBarMode: ControlBarMode.values,
					videoRenderingMode:  VideoRenderingMode.values
			}
		
		/**
		 * Custom validators list
		 */ 
		private const validators:Object =
			{
				src: ConfigurationUtils.validateURLProperty,
				scaleMode: validateEnumProperty,
				controlBarMode: validateEnumProperty,
				videoRenderingMode: validateEnumProperty
			}
			
			
		private var configOrder:Array = [];
		private var configClasses:Dictionary = new Dictionary();
		private var configMapping:Dictionary = new Dictionary();
	}
}