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
package org.osmf.media.pluginClasses
{
	import flash.display.DisplayObject;
	
	import org.osmf.elements.SWFLoader;
	import org.osmf.elements.loaderClasses.LoaderLoadTrait;
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	
	internal class DynamicPluginLoader extends PluginLoader
	{
		/**
		 * Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function DynamicPluginLoader(mediaFactory:MediaFactory, minimumSupportedFrameworkVersion:String)
		{
			super(mediaFactory, minimumSupportedFrameworkVersion);
		}

		/**
		 * @private
		 */
	    override public function canHandleResource(resource:MediaResourceBase):Boolean
	    {
	    	return new SWFLoader().canHandleResource(resource);
	    }

		/**
		 * @private
		 */
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			updateLoadTrait(loadTrait, LoadState.LOADING);
			
			// We'll use a SWFLoader to do the loading.  Make sure we load the
			// SWF into the same security domain so that the class types are
			// merged.
			var swfLoader:SWFLoader = new SWFLoader(true);
			swfLoader.validateLoadedContentFunction = validateLoadedContent;
			swfLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onSWFLoaderStateChange);
			
			// Create a temporary LoadTrait for this purpose, so that our main
			// LoadTrait doesn't reflect any of the state changes from the
			// loading of the SWF, and so that we can catch any errors.
			var loaderLoadTrait:LoaderLoadTrait = new LoaderLoadTrait(swfLoader, loadTrait.resource);
			loaderLoadTrait.addEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);
			
			swfLoader.load(loaderLoadTrait);
			
			function onSWFLoaderStateChange(event:LoaderEvent):void
			{
				if (event.newState == LoadState.READY)
				{
					// This is a terminal state, so remove all listeners.
					swfLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onSWFLoaderStateChange);
					loaderLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);
	
					var root:DisplayObject = loaderLoadTrait.loader.content;
					var pluginInfo:PluginInfo = root[PLUGININFO_PROPERTY_NAME] as PluginInfo;
					
					loadFromPluginInfo(loadTrait, pluginInfo, loaderLoadTrait.loader);
				}
				else if (event.newState == LoadState.LOAD_ERROR)
				{
					// This is a terminal state, so remove the listener.  But
					// don't remove the error event listener, as that will be
					// removed when the error event for this failure is
					// dispatched.
					swfLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onSWFLoaderStateChange);
					
					updateLoadTrait(loadTrait, event.newState);
				}
			}
			
			function onLoadError(event:MediaErrorEvent):void
			{
				// Only remove this listener, as there will be a corresponding
				// event for the load failure.
				loaderLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);
				
				loadTrait.dispatchEvent(event.clone());
			}
		}
		
		// Internals
		//

		/**
		 * @private
		 */
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			updateLoadTrait(loadTrait, LoadState.UNLOADING);
			
			// First unload the PluginInfo.
			//
			
			var pluginLoadTrait:PluginLoadTrait = loadTrait as PluginLoadTrait;
			
			unloadFromPluginInfo(pluginLoadTrait.pluginInfo);

			// Then unload the SWF.
			//
			
			pluginLoadTrait.loader.unloadAndStop();

			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
		}
		
		private function validateLoadedContent(displayObject:DisplayObject):Boolean
		{
			var pluginInfo:Object = 	displayObject.hasOwnProperty(PLUGININFO_PROPERTY_NAME)
									?	displayObject[PLUGININFO_PROPERTY_NAME]
									:	null;
			return pluginInfo != null ? isPluginCompatible(pluginInfo) : false;
		}
		
		private static const PLUGININFO_PROPERTY_NAME:String = "pluginInfo";
	}
}