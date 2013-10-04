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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.osmf.player.chrome.configuration.ConfigurationUtils;
	
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * Loads a configuration model from flashvars and external configuration files.
	 */ 
	public class ConfigurationLoader extends EventDispatcher
	{			
		public function ConfigurationLoader(configurationDeserializer:ConfigurationFlashvarsDeserializer, xmlDeserializer:ConfigurationXMLDeserializer)
		{
			this.flashvarsDeserializer = configurationDeserializer;
			this.xmlDeserializer = xmlDeserializer;
		}
		
		public function load(parameters:Object, configuration:PlayerConfiguration):void
		{
			
			// Parse configuration from the parameters passed on embedding
			// StrobeMediaPlayback.swf:
			if (parameters.hasOwnProperty("configuration"))
			{					
				var configurationContent:String = parameters["configuration"];				
//				if ((configurationContent.toLowerCase().lastIndexOf(".xml") == (configurationContent.length - 4)))
				{					
					var loader:XMLFileLoader = new XMLFileLoader();					
					loader.addEventListener(Event.COMPLETE, loadConfiguration);
					loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadConfiguration);
					loader.addEventListener(IOErrorEvent.IO_ERROR, loadConfiguration);				
					function loadConfiguration(event:Event):void
					{
						loader.removeEventListener(Event.COMPLETE, loadConfiguration);
						loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadConfiguration);
						loader.removeEventListener(IOErrorEvent.IO_ERROR, loadConfiguration);
					
						if (loader.xml != null)
						{
							xmlDeserializer.deserialize(loader.xml);
						}
						flashvarsDeserializer.deserialize(parameters);
						
						dispatchEvent(new Event(Event.COMPLETE));	
					}					
					loader.load(configurationContent);
				}
//				else {load content directly}
			}
			else
			{			
				flashvarsDeserializer.deserialize(parameters);
				dispatchEvent(new Event(Event.COMPLETE));
			}	
		}	
		
		// Internals
		//
		
		private var xmlDeserializer:ConfigurationXMLDeserializer;
		private var flashvarsDeserializer:ConfigurationFlashvarsDeserializer;
	}
}