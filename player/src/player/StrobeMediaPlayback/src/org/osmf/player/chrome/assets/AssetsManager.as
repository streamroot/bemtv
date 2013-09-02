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

package org.osmf.player.chrome.assets
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;
	
	import org.osmf.player.chrome.configuration.AssetsParser;
	
	[Event(name="complete", type="flash.events.Event")]
	
	public class AssetsManager extends EventDispatcher
	{
		// Public API
		//
		
		public function AssetsManager()
		{
			loaders = new Dictionary();
			resourceByLoader = new Dictionary();
		}
		
		public function addConfigurationAssets(xml:XML):void
		{
			var parser:AssetsParser = new AssetsParser();
			parser.parse(xml.assets, this);
		}
		
		public function addAsset(resource:AssetResource, loader:AssetLoader):void
		{
			var currentLoader:AssetLoader = getLoader(resource.id);
			if (currentLoader != null)
			{
				// Skip the addition: there's an asset present for the ID already.
			}
			else
			{
				assetCount++;
				
				loaders[resource] = loader;
				resourceByLoader[loader] = resource;
			}
		}
		
		public function getResource(loader:AssetLoader):AssetResource
		{
			return resourceByLoader[loader];
		}
		
		public function getLoader(id:String):AssetLoader
		{
			var result:AssetLoader;
			
			for each (var resource:AssetResource in resourceByLoader)
			{
				if (resource.id == id)
				{
					result = loaders[resource]
					break;
				}
			}
			
			return result;
		}
		
		public function getAsset(id:String):Asset
		{
			var loader:AssetLoader = getLoader(id);
			return loader ? loader.asset : null;
		}
		
		public function getDisplayObject(id:String):DisplayObject
		{
			var result:DisplayObject;
			var asset:DisplayObjectAsset = getAsset(id) as DisplayObjectAsset;
			if (asset)
			{
				result = asset.displayObject;
			}
			return result;
		}
		
		public function load():void
		{
			completionCount = assetCount;
			for each (var loader:AssetLoader in loaders)
			{
				loader.addEventListener(Event.COMPLETE, onAssetLoaderComplete);
				loader.load(resourceByLoader[loader]);
			}
		}
		
		// Internals
		//
		
		private var loaders:Dictionary;
		private var resourceByLoader:Dictionary;
		
		private var assetCount:int = 0;
		private var _completionCount:int = -1;

		private function set completionCount(value:int):void
		{
			if (_completionCount != value)
			{
				_completionCount = value;
				if (_completionCount == 0)
				{
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}
		}
		private function get completionCount():int
		{
			return _completionCount;
		}
		
		private function onAssetLoaderComplete(event:Event):void
		{
			var loader:AssetLoader = event.target as AssetLoader;
			var resource:AssetResource = resourceByLoader[event.target];
			
			completionCount--;
		}
		
		private function onAssetLoaderError(event:IOErrorEvent):void
		{
			var resource:AssetResource = resourceByLoader[event.target];
			
			completionCount--;
		}
	}
}