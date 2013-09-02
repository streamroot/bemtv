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
	import org.osmf.utils.URL;
	
	/**
	 * SWFLoader is a loader that is capable of loading and displaying SWF files.
	 * 
	 * <p>The SWF is loaded from the URL provided by the
	 * <code>resource</code> property of the LoadTrait that is passed
	 * to the SWFLoader's <code>load()</code> method.</p>
	 *
	 * @see org.osmf.elements.SWFElement
	 * @see org.osmf.traits.LoadTrait
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */ 
	public class SWFLoader extends LoaderBase
	{
		/**
		 * Constructor.
		 * 
		 * @param useCurrentSecurityDomain Indicates whether to load the SWF
		 * into the current security domain, or its natural security domain.
		 * If the loaded SWF does not live in the same security domain as the
		 * loading SWF, Flash Player will not merge the types defined in the two
		 * domains.  Even if it happens that there are two types with identical
		 * names, Flash Player will still consider them different by tagging them
		 * with different versions.  Therefore, it is mandatory to have the
		 * loaded SWF and loading SWF live in the same security domain if the
		 * types need to be merged.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function SWFLoader(useCurrentSecurityDomain:Boolean=false)
		{
			super();
			
			this.useCurrentSecurityDomain = useCurrentSecurityDomain;
		}
		
		/**
		 * @private
		 * 
		 * Indicates whether this SWFLoader is capable of handling the specified resource.
		 * Returns <code>true</code> for URLResources with SWF extensions.
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
				return (url.path.search(/\.swf$/i) != -1);
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
			// We never check the policy file for SWFs, since SWF permissions are based
			// on the Security.allowDomain method, not checkPolicyFile.
			LoaderUtils.loadLoadTrait(loadTrait, updateLoadTrait, useCurrentSecurityDomain, false, validateLoadedContentFunction);
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
		
		/**
		 * @private
		 **/
		public static var allowValidationOfLoadedContent:Boolean = true;  
		
		/**
		 * @private
		 **/
		public function get validateLoadedContentFunction():Function
		{
			return allowValidationOfLoadedContent ? _validateLoadedContentFunction : null;
		}
		
		/**
		 * @private
		 **/
		public function set validateLoadedContentFunction(value:Function):void
		{
			_validateLoadedContentFunction = value;
		}
		
		private var useCurrentSecurityDomain:Boolean = false;
		private var _validateLoadedContentFunction:Function = null;

		private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["application/x-shockwave-flash"]);
		private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.SWF]);
	}
}