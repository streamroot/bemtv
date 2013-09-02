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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.getDefinitionByName;
	
	[Event(name="complete", type="flash.events.Event")]
	public class AssetLoader extends EventDispatcher
	{
		public function load(resource:AssetResource):void
		{
			this.resource = resource;
			
			if (resource.local == false)
			{
				if	(	resource is BitmapResource
					||	resource is FontResource
					||	resource is SymbolResource
					)
				{
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
					
					loader.load(new URLRequest(resource.url), new LoaderContext(true));
				}
			}
			else
			{
				_asset = constructLocalAsset();
				
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function get asset():Asset
		{
			return _asset; 
		}
		
		protected var resource:AssetResource;
		private var _asset:Asset;
		
		protected function onLoaderError(event:IOErrorEvent):void
		{
			trace("WARNING: failed loading asset:", resource.id, "from", resource.url);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function onLoaderComplete(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			
			_asset = constructLoadedAsset(loaderInfo);
				
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function constructLoadedAsset(loaderInfo:LoaderInfo):Asset
		{
			var asset:Asset;
			var type:Class;
			
			if (resource is FontResource)
			{
				type = loaderInfo.applicationDomain.getDefinition(FontResource(resource).symbol) as Class; 
				asset = new FontAsset(type, resource as FontResource);
			}
			else if (resource is BitmapResource)
			{
				if (loaderInfo.contentType == "application/x-shockwave-flash")
				{
					asset = new SWFAsset(loaderInfo.content);
				}
				else if (loaderInfo.contentType != "")
				{
					asset 
						= new BitmapAsset
							( loaderInfo.content as Bitmap
							, resource is BitmapResource
								? BitmapResource(resource).scale9
								: null
							);
				}
			}
			else if (resource is SymbolResource)
			{
				type = loaderInfo.applicationDomain.getDefinition(SymbolResource(resource).symbol) as Class; 
				asset = new SymbolAsset(type);
			}
			
			return asset;
		}
		
		protected function constructLocalAsset():Asset
		{
			var asset:Asset;
			var type:Class;
		
			try
			{
				type = getDefinitionByName(resource.url) as Class;
			}
			catch(error:Error)
			{
				trace("WARNING: failure instantiating local asset:",error.message);	
			}
			
			if (type != null)
			{
				if (resource is BitmapResource)
				{	
					// A local symbol might be pointing to a BitmapData class instead
					// of a Bitmap instance. If this is the case, convert the bitmap
					// data into a bitmap:
					var bitmap:* = new type();
					if (bitmap is BitmapData)
					{
						bitmap = new Bitmap(bitmap);
					}
					asset = new BitmapAsset(bitmap, BitmapResource(resource).scale9);
				}
				else if (resource is FontResource)
				{
					asset = new FontAsset(type, resource as FontResource);
				}
				else if (resource is SymbolResource)
				{
					asset = new SymbolAsset(type);
				}
				else
				{
					trace("WARNING: no suitable asset type found for "+resource.id);
				}
			}
			else
			{
				trace("WARNING: failed loading "+resource.id);
			}
			
			return asset;
		}
	}
}