/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.elements
{
	import __AS3__.vec.Vector;
	
	import org.osmf.elements.loaderClasses.LoaderUtils;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.MediaType;
	import org.osmf.media.MediaTypeUtil;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.*;

	/**
	 * ImageLoader is a loader that is capable of loading and displaying
	 * image files.
	 * 
	 * <p>The image is loaded from the URL provided by the
	 * <code>resource</code> property of the LoadTrait that is passed
	 * to the ImageLoader's <code>load()</code> method.</p>
	 *
	 * @see org.osmf.elements.ImageElement
	 * @see org.osmf.traits.LoadTrait
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */ 
	public class ImageLoader extends LoaderBase
	{
		/**
		 * Constructor.
		 * 
		 * @param checkPolicyFile Indicates whether the ImageLoader should try to download
		 * a URL policy file from the loaded image's server before beginning to load the
		 * image.  The default is true.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function ImageLoader(checkPolicyFile:Boolean=true)
		{
			super();
			
			this.checkPolicyFile = checkPolicyFile;
		}
		
		/**
		 * @private
		 * 
		 * Indicates whether this ImageLoader is capable of handling the specified resource.
		 * Returns <code>true</code> for URLResources with GIF, JPG, or PNG extensions.
		 * @param resource Resource proposed to be loaded.
		 */ 
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			var rt:int = MediaTypeUtil.checkMetadataMatchWithResource(resource, MEDIA_TYPES_SUPPORTED, MIME_TYPES_SUPPORTED);
			if (rt != MediaTypeUtil.METADATA_MATCH_UNKNOWN)
			{
				return rt == MediaTypeUtil.METADATA_MATCH_FOUND;
			}			
			
			var urlResource:URLResource = resource as URLResource;
			if (urlResource != null &&
				urlResource.url != null)
			{
				var url:URL = new URL(urlResource.url);
				return (url.path.search(/\.gif$|\.jpg$|\.png$/i) != -1);
			}	
			return false;
		}
		
		/**
		 * @private
		 * 
		 * Loads content using a flash.display.Loader object. 
		 * <p>Updates the LoadTrait's <code>loadState</code> property to LOADING
		 * while loading and to READY upon completing a successful load.</p> 
		 * 
		 * @see org.osmf.traits.LoadState
		 * @see flash.display.Loader#load()
		 * @param loadTrait LoadTrait to be loaded.
		 */ 
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			// No need to import into the current security domain, this is an
			// image file.  The client should check for a policy file if they need
			// pixel-level access to the image.
			LoaderUtils.loadLoadTrait(loadTrait, updateLoadTrait, false, checkPolicyFile);
		}

		/**
		 * @private
		 * 
		 * Unloads content using a flash.display.Loader object.  
		 * 
		 * <p>Updates the LoadTrait's <code>loadState</code> property to UNLOADING
		 * while unloading and to UNINITIALIZED upon completing a successful unload.</p>
		 *
		 * @param loadTrait LoadTrait to be unloaded.
		 * @see org.osmf.traits.LoadState
		 * @see flash.display.Loader#unload()
		 */ 
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			LoaderUtils.unloadLoadTrait(loadTrait, updateLoadTrait);
		}
		
		// Internals
		//
		
		private var checkPolicyFile:Boolean;

		private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["image/png", "image/gif", "image/jpeg"]);	
		private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.IMAGE]);
	}
}