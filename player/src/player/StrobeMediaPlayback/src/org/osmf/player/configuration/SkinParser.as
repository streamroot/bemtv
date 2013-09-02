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
	import flash.display.Bitmap;
	
	import org.osmf.player.chrome.assets.AssetLoader;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.assets.BitmapResource;

	/**
	 * Defines a parser for XML based player skin files.
	 */	
	public class SkinParser
	{
		public function parse(value:XML, assetManager:AssetsManager):void
		{
			if (value != null)
			{
				var result:Vector.<String> = new Vector.<String>();
				
				for each (var element:XML in value.element)
				{
					parseElement(element, "", assetManager);
				}
				
				for each (var elements:XML in value.elements)
				{
					parseElements(elements, assetManager);
				}
			}
		}
		
		public function parseElements(value:XML, assetManager:AssetsManager):void
		{
			var basePath:String = value.@basePath || "";
			for each (var element:XML in value.element)
			{
				parseElement(element, basePath, assetManager);
			}
		}
		
		public function parseElement(value:XML, basePath:String, assetManager:AssetsManager):void
		{
			var id:String = value.@id;
			if (id && id != "")
			{
				assetManager.addAsset
					( new BitmapResource
						( id
						, basePath + value.@src
						, false
						, null
						)
					, new AssetLoader()	
					);
			}
			else
			{
				trace("WARNING: missing skin element id (for the asset at", basePath + value.@src,")");
			}
		}
	}
}