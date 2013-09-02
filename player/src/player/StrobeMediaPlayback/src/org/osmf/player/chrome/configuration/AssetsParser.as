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
	import flash.errors.IllegalOperationError;
	import flash.geom.Rectangle;
	
	import org.osmf.player.chrome.assets.AssetLoader;
	import org.osmf.player.chrome.assets.AssetResource;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.assets.BitmapResource;
	import org.osmf.player.chrome.assets.FontResource;
	import org.osmf.player.chrome.assets.SymbolResource;
	
	public class AssetsParser
	{
		public function parse(assetsList:XMLList, assetsManager:AssetsManager):void
		{
			for each (var assets:XML in assetsList)
			{
				var baseURL:String = assets.@baseURL || "";
				var loader:AssetLoader;
				var resource:AssetResource;
				for each (var asset:XML in assets.asset)
				{
					loader = new AssetLoader();
					resource = assetToResource(asset, baseURL);
					if (loader && resource)
					{
						assetsManager.addAsset(resource, loader);
					}
					else
					{
						throw new IllegalOperationError("Unknown resource type", asset.@type);
					}
				}
			}
		}
		
		// Internals
		//
		
		private function assetToResource(asset:XML, baseURL:String = ""):AssetResource
		{
			var type:String = String(asset.@type || "").toLowerCase();
			var resource:AssetResource;
			
			switch (type)
			{
				case "bitmapfile":
				case "embeddedbitmap":
					resource = new BitmapResource
						( asset.@id
						, baseURL + asset.@url
						, type == "embeddedbitmap"
						, parseRect(asset.@scale9)
						);
					break;
					
				case "fontsymbol":
				case "embeddedfont":	
					resource = new FontResource
						( asset.@id
						, baseURL + asset.@url
						, type == "embeddedfont"
						, asset.@symbol
						, parseInt(asset.@fontSize || "11")
						, parseInt(asset.@color || "0xFFFFFF")
						);
					break;
				case "symbol":
					resource = new SymbolResource
					(asset.@id
						,null
						,true
						,asset.@symbol
					);
			}
			
			return resource;
		}
		
		private function parseRect(value:String):Rectangle
		{
			var result:Rectangle;
			
			var values:Array = value.split(",");
			if (values.length == 4)
			{
				result
					= new Rectangle
						( parseInt(values[0])
						, parseInt(values[1])
						, parseInt(values[2])
						, parseInt(values[3])
						);
			}
			
			return result;
		} 
	}
}