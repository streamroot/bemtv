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
package org.osmf.elements.loaderClasses
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.Timer;
	
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.URLResource;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.utils.*;
	
	CONFIG::LOGGING
	{
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;
	}

	[ExcludeClass]
	
	/**
	 * @private
	 **/
	public class LoaderUtils
	{
		/**
		 * Creates a DisplayObjectTrait for the content in the given
		 * flash.display.Loader.
		 **/
		public static function createDisplayObjectTrait(loader:Loader, mediaElement:MediaElement):DisplayObjectTrait
		{
			var displayObject:DisplayObject = null;
			var mediaWidth:Number = 0;
			var mediaHeight:Number = 0;
						
			var info:LoaderInfo = loader.contentLoaderInfo;  
			
			// The display object must be a loader in order to support crossdomain
			// SWF loading.
			
			// The content of a loaded SWF can be accessed (at the developer's discrection) 
			// by casting the display object back to a loader and accessing its content property.
			displayObject = loader;
			
			// Add a scroll rect, to allow the loaded content to
			// overdraw its bounds, while maintaining scale, and size
			// with the layout system.
			//
			displayObject.scrollRect = new Rectangle(0, 0, info.width, info.height);
			
			mediaWidth = info.width;
			mediaHeight = info.height;

			return new DisplayObjectTrait(displayObject, mediaWidth, mediaHeight);
		}
		
		/**
		 * Loads the given LoadTrait.
		 * 
		 * @param loadTrait The LoadTrait whose URL represents the image or SWF to load.
		 * @param updateLoadTraitFunction Function to invoke when the LoadTrait's state changes.
		 * @param useCurrentSecurityDomain Indicates whether the content should be loaded into
		 * the current security domain, or the default.  The former should be used for SWFs whose
		 * content needs to be accessed (and which needs to access player content).  The latter
		 * should be used for images, or for SWFs that can be isolated.
		 * @param checkPolicyFile Indicates whether the load operation should check for the
		 * presence of a policy file on the server.  Should be true for images (if pixel-level
		 * access is required, false for SWFs (since SWF security is handled in a different way).
		 * @param validateLoadedContentFunction Function to invoke in order to validate loaded
		 * content.  When this param is non-null, the content will be loaded into a separate
		 * ApplicationDomain so that class types are not merged.  This allows the loading
		 * application to inspect player and SWF classes separately.  If the function returns
		 * true, then the content will be loaded into the current security domain.  If false,
		 * then this will be treated as a load error.
		 **/
		public static function loadLoadTrait(loadTrait:LoadTrait, updateLoadTraitFunction:Function, useCurrentSecurityDomain:Boolean, checkPolicyFile:Boolean, validateLoadedContentFunction:Function=null):void
		{
			var loaderLoadTrait:LoaderLoadTrait = loadTrait as LoaderLoadTrait;

			var loader:Loader = new Loader();
			loaderLoadTrait.loader = loader;
			
			updateLoadTraitFunction(loadTrait, LoadState.LOADING);
			
			var context:LoaderContext = new LoaderContext();
			var urlReq:URLRequest = new URLRequest((loadTrait.resource as URLResource).url.toString());
			
			context.checkPolicyFile = checkPolicyFile;

			// Local files should never be loaded into the current security domain.
			if (	useCurrentSecurityDomain
				&&	urlReq.url.search(/^file:\//i) == -1
			   )
			{
				context.securityDomain = SecurityDomain.currentDomain;
			}
			
			if (validateLoadedContentFunction != null)
			{
				// Don't load into the default ApplicationDomain.  Instead,
				// we'll load into a child of the system ApplicationDomain
				// (so that class types) don't get merged.  If the validation
				// function returns true, then we'll execute a second load,
				// this time into the default ApplicationDomain (so that class
				// types are merged).
				context.applicationDomain = new ApplicationDomain();
			}
			
			CONFIG::LOGGING
			{
				if (context.securityDomain != null)
				{
					logger.debug("Loading SWF into current security domain: " + urlReq.url);
				}
				if (context.applicationDomain != null)
				{
					logger.debug("Loading SWF into separate application domain: " + urlReq.url);
				}
			}
			
			toggleLoaderListeners(loader, true);
			try
			{
				loader.load(urlReq, context);
			}
			catch (ioError:IOError)
			{
				onIOError(null, ioError.message);
			}
			catch (securityError:SecurityError)
			{
				onSecurityError(null, securityError.message);
			}

			function toggleLoaderListeners(loader:Loader, on:Boolean):void
			{
				if (on)
				{
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
					loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				}
				else
				{
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
					loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				}
			}
		
			function onLoadComplete(event:Event):void
			{
				toggleLoaderListeners(loader, false);
				
				// If we're not still in the LOADING state, then ignore this event.
				// (This can happen when a load is immediately followed by an unload.)
				if (loadTrait.loadState == LoadState.LOADING)
				{
					if (validateLoadedContentFunction != null)
					{
						var validated:Boolean = validateLoadedContentFunction(loader.content);
						if (validated)
						{
							// Unload the loaded SWF, we don't need it anymore.
							
							// Fix for FM-1104: adding a delay seems to fix a race condition that causes an
							// RTE in the debug version of the Flash Player. We'll only execute
							// this code for the debug version since the release version does not
							// show RTE messages. In both cases, the plugin loads fine despite
							// the RTE.
							if (Capabilities.isDebugger)
							{
								CONFIG::LOGGING
								{
									logger.debug("Capabilities.isDebugger is true");
								}
								
								var timer:Timer = new Timer(250, 1);
								timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimer);
								timer.start();
								
								function onTimer(event:TimerEvent):void 
								{
									timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimer);
									timer = null;
									loader.unloadAndStop();
									loader = null;
									loadLoadTrait(loadTrait, updateLoadTraitFunction, useCurrentSecurityDomain, false, null);
								}
							}
							else
							{
								loader.unloadAndStop();
								loader = null;
								loadLoadTrait(loadTrait, updateLoadTraitFunction, useCurrentSecurityDomain, false, null);
							}							
							
						}
						else
						{
							// Unload the loaded SWF, we don't need it anymore.
							loader.unloadAndStop();
							loader = null;
							
							updateLoadTraitFunction(loadTrait, LoadState.LOAD_ERROR);
							loadTrait.dispatchEvent
								( new MediaErrorEvent
									( MediaErrorEvent.MEDIA_ERROR
									, false
									, false
									, new MediaError
										( MediaErrorCodes.IO_ERROR
										)
									)
								);
						}
					}
					else
					{
						updateLoadTraitFunction(loadTrait, LoadState.READY);
					}
				}
			}

			function onIOError(ioEvent:IOErrorEvent, ioEventDetail:String=null):void
			{	
				toggleLoaderListeners(loader, false);
				loader = null;
				
				updateLoadTraitFunction(loadTrait, LoadState.LOAD_ERROR);
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
				CONFIG::LOGGING
				{
					logger.debug("Security error when loading image/SWF: " + (securityEvent ? securityEvent.text : securityEventDetail));
				}

				toggleLoaderListeners(loader, false);
				loader = null;
				
				updateLoadTraitFunction(loadTrait, LoadState.LOAD_ERROR);
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
		 * Unloads the given LoadTrait.
		 **/
		public static function unloadLoadTrait(loadTrait:LoadTrait, updateLoadTraitFunction:Function):void
		{
			var loaderLoadTrait:LoaderLoadTrait = loadTrait as LoaderLoadTrait;
			updateLoadTraitFunction(loadTrait, LoadState.UNLOADING);			
			loaderLoadTrait.loader.unloadAndStop();
			updateLoadTraitFunction(loadTrait, LoadState.UNINITIALIZED);
		}
		
		private static const SWF_MIME_TYPE:String = "application/x-shockwave-flash";
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.elements.loaderClasses.LoaderUtils");
		}
	}
}
