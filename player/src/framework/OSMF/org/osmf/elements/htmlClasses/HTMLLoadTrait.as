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
package org.osmf.elements.htmlClasses
{
	import flash.errors.IllegalOperationError;
	import flash.external.ExternalInterface;
	
	import org.osmf.elements.HTMLElement;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.utils.OSMFStrings;

	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class HTMLLoadTrait extends LoadTrait
	{
		public function HTMLLoadTrait(owner:HTMLElement)
		{
			this.owner = owner;
			
			super(null, owner.resource);
		}
		
		public function set loadState(value:String):void
		{
			setLoadState(value);
		}
				
		override public function load():void
		{
			if (loadState == LoadState.READY)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_READY));
			}
			if (loadState == LoadState.LOADING)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_LOADING));
			}
			if (resource is URLResource == false)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.LOADER_CANT_HANDLE_RESOURCE));
			}
			
			loadState = LoadState.LOADING;
			
			var urlResource:URLResource = resource as URLResource
			var url:String
				= urlResource
					? urlResource.url
					: "";
			
			var result:* = owner.invokeJavaScriptMethod("load", url);
					
			if (result == false)
			{
				// No load method got executed. Assume that we're ready:
				loadState = LoadState.READY;
			}
		}
		
		override public function unload():void
		{
			if (loadState == LoadState.UNLOADING)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_UNLOADING));
			}
			if (loadState == LoadState.UNINITIALIZED)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_UNLOADED));
			}
			
			var result:* = owner.invokeJavaScriptMethod("unload", resource);
					
			if (result == false)
			{
				// No unload method got executed. Assume that we're unloaded:
				loadState = LoadState.UNINITIALIZED;
			}
		}
		
		// Internal
		//
		
		private var owner:HTMLElement;
	}
}