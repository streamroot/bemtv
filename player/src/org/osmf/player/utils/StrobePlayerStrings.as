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

package org.osmf.player.utils
{
	import flash.utils.Dictionary;
	
	import org.osmf.utils.OSMFStrings;

	public class StrobePlayerStrings
	{		
		/**
		 * Returns the user-facing string for the given key.  All possible keys
		 * are defined as static constants on this class.  The parameters are
		 * optional substitution variables, formatted as {0}, {1}, etc.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function getString(key:String, params:Array=null):String
		{
			return resourceStringFunction(key, params);
		}
		
		/**
		 * Function that the getString methods uses to retrieve a user-facing string.
		 * This function takes a String parameter (which is expected to be one of
		 * the static consts on this class) and an optional Array of parameters
		 * which can be substituted into the String (formatted as {0}, {1}, etc.).
		 * 
		 * Clients can supply their own getString function to localize the strings.
		 * By default, the getString function returns an English-language String.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function get resourceStringFunction():Function
		{
			return _resourceStringFunction;
		}
		
		public static function set resourceStringFunction(value:Function):void
		{
			_resourceStringFunction = value;
		}
		
		/** Use single quotes, to facilitate build system updates **/
		public static const title:String = 'Strobe Media Playback';
		
		/** Use single quotes, to facilitate build system updates **/
		public static const version:String = '1.6.328';
		
		public static const ILLEGAL_INPUT_VARIABLE:String 			= "illegalInputVariable";
		
		public static const DYNAMIC_STREAMING_RESOURCE_EXPECTED:String = "dynamicStreamingResourceExpected";
		
		public static const CONFIGURATION_LOAD_ERROR:String = "configurationFileLoadError";
		
		public static const UNKNOWN_ERROR:String = "unknownError";
		
		public static const PLUGIN_NOT_IN_WHITELIST:String = "pluginNotInWhitelist";
		
		public function StrobePlayerStrings()
		{
		}
		
		private static const resourceDict:Dictionary = new Dictionary();
		{
			resourceDict[ILLEGAL_INPUT_VARIABLE]	 				= "Illegal input variables",
			resourceDict[DYNAMIC_STREAMING_RESOURCE_EXPECTED]		= "A DynamicStreamingResource was expected along the proxy chain."
			resourceDict[UNKNOWN_ERROR]								= "Unknown Error."
			resourceDict[PLUGIN_NOT_IN_WHITELIST]					= "A plugin was not loaded because it wasn't hosted on a whitelisted server. url = {0}";			
		}
		
		private static function defaultResourceStringFunction(resourceName:String, params:Array=null):String
		{
			var value:String = resourceDict.hasOwnProperty(resourceName) ? String(resourceDict[resourceName]) : null;
			
			if (value == null)
			{
				value = String(resourceDict["missingStringResource"]);
				params = [resourceName];
			}
			
			if (params)
			{
				value = substitute(value, params);
			}
			
			return value;
		}
		
		private static function substitute(value:String, ... rest):String
		{
			var result:String = "";
			
			if (value != null)
			{
				result = value;
				
				// Replace all of the parameters in the value string.
				var len:int = rest.length;
				var args:Array;
				if (len == 1 && rest[0] is Array)
				{
					args = rest[0] as Array;
					len = args.length;
				}
				else
				{
					args = rest;
				}
				
				for (var i:int = 0; i < len; i++)
				{
					result = result.replace(new RegExp("\\{"+i+"\\}", "g"), args[i]);
				}
			}
			
			return result;
		}
		
		private static var _resourceStringFunction:Function = defaultResourceStringFunction;
	}
}