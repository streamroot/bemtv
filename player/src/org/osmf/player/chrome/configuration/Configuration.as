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
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.osmf.player.chrome.assets.AssetsManager;
	
	[Event(name="complete", type="flash.events.Event")]
	
	public class Configuration extends EventDispatcher
	{
		public function Configuration()
		{
			super();
		}
		
		public function loadFromFile(url:String, loadAssets:Boolean):void
		{
			_configuration = null;
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener
				( IOErrorEvent.IO_ERROR
				, function(event:IOErrorEvent):void
					{
						trace("WARNING: configuration loading error:", event.text);
						dispatchEvent(new Event(Event.COMPLETE));
					}
				);
			loader.addEventListener
				( Event.COMPLETE
				, function(event:Event):void
					{
						loadFromXML(new XML(loader.data), loadAssets);
					}
				);
			loader.load(new URLRequest(url));
		}
		
		public function loadFromXML(value:XML, loadAssets:Boolean):void
		{
			_configuration = value;	
			if (loadAssets)
			{
				_assetsManager = new AssetsManager();
				_assetsManager.addEventListener
					( Event.COMPLETE
					, function (event:Event):void
						{
							var assetsManager:AssetsManager
							dispatchEvent(new Event(Event.COMPLETE));
						}
					);
				
				_assetsManager.addConfigurationAssets(_configuration);
				_assetsManager.load();
			}
			else
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function get configuration():XML
		{
			return _configuration;
		}
		
		public function get assetsManager():AssetsManager
		{
			return _assetsManager;
		}
		
		private var _configuration:XML;
		private var _assetsManager:AssetsManager;
	}
}