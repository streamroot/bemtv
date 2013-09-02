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
package org.osmf.utils
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Implementation of LoaderBase that can retrieve an URLResource using HTTP.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class HTTPLoader extends LoaderBase
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function HTTPLoader()
		{
			super();
		}
				
		/**
		 * Returns true for any resource using the HTTP(S) protocol.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			// Rule out protocols other than http(s).
			//
			
			var urlResource:URLResource = resource as URLResource;
			
			if (	urlResource == null
				|| 	urlResource.url == null
				||  urlResource.url.length <= 0
			   )
			{
				return false;
			}
			
			var url:URL = new URL(urlResource.url);		
			if (	url.protocol.search(/http$|https$/i) == -1
				&&  url.protocol != ""
			   )
			{
				return false;
			}
					
			return true;
		}
		
		/**
		 * Loads an URL over HTTP.
		 * 
		 * <p>Updates the LoadTrait's <code>loadState</code> property to LOADING
		 * while loading and to READY upon completing a successful load of the 
		 * URL.</p> 
		 * 
		 * @see org.osmf.traits.LoadState
		 * @see flash.display.Loader#load()
		 * @param loadTrait LoadTrait to be loaded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			updateLoadTrait(loadTrait, LoadState.LOADING);
			
			var urlResource:URLResource = loadTrait.resource as URLResource;

			var urlReq:URLRequest = new URLRequest(urlResource.url.toString());
			var loader:URLLoader = createURLLoader();

			toggleLoaderListeners(loader, true);
			
			try
			{
				loader.load(urlReq);
			}
			catch (ioError:IOError)
			{
				onIOError(null, ioError.message);
			}
			catch (securityError:SecurityError)
			{
				onSecurityError(null, securityError.message);
			}

			function toggleLoaderListeners(loader:URLLoader, on:Boolean):void
			{
				if (on)
				{
					loader.addEventListener(Event.COMPLETE, onLoadComplete);
					loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
					loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				}
				else
				{
					loader.removeEventListener(Event.COMPLETE, onLoadComplete);
					loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
					loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				}
			}

			function onLoadComplete(event:Event):void
			{
				toggleLoaderListeners(loader, false);
				
				var httpLoadTrait:HTTPLoadTrait = loadTrait as HTTPLoadTrait;
				httpLoadTrait.urlLoader = loader;
				updateLoadTrait(loadTrait, LoadState.READY);
			}

			function onIOError(ioEvent:IOErrorEvent, ioEventDetail:String=null):void
			{	
				toggleLoaderListeners(loader, false);
				
				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
				loadTrait.dispatchEvent
					( new MediaErrorEvent
						( MediaErrorEvent.MEDIA_ERROR
						, false
						, false
						, new MediaError
							( MediaErrorCodes.IO_ERROR
							, ioEvent ? ioEvent.text : ioEventDetail
							)
						)
					);
			}

			function onSecurityError(securityEvent:SecurityErrorEvent, securityEventDetail:String=null):void
			{	
				toggleLoaderListeners(loader, false);
				
				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
				loadTrait.dispatchEvent
					( new MediaErrorEvent
						( MediaErrorEvent.MEDIA_ERROR
						, false
						, false
						, new MediaError
							( MediaErrorCodes.SECURITY_ERROR
							, securityEvent ? securityEvent.text : securityEventDetail
							)
						)
					);
			}
		}
		
		/**
		 * Unloads the resource.  
		 * 
		 * <p>Updates the LoadTrait's <code>loadState</code> property to UNLOADING
		 * while unloading and to UNINITIALIZED upon completing a successful unload.</p>
		 *
		 * @param loadTrait LoadTrait to be unloaded.
		 * @see org.osmf.traits.LoadState
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			// Nothing to do.
			updateLoadTrait(loadTrait, LoadState.UNLOADING);			
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
		}
		
		/**
		 * Creates the URLLoader to make the request.  Called by load().
		 * 
		 * Subclasses can override this method to set specific properties on
		 * the URLLoader.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function createURLLoader():URLLoader
		{
			return new URLLoader();
		}
	}
}