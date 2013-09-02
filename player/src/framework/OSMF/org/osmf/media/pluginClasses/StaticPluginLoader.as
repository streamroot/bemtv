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
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	
	internal class StaticPluginLoader extends PluginLoader
	{
		/**
		 * Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function StaticPluginLoader(mediaFactory:MediaFactory, minimumSupportedFrameworkVersion:String)
		{
			super(mediaFactory, minimumSupportedFrameworkVersion);
		}

		/**
		 * Indicates if this loader can handle the given resource.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
	    override public function canHandleResource(resource:MediaResourceBase):Boolean
	    {
	    	return (resource is PluginInfoResource);
	    }
	    
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			updateLoadTrait(loadTrait, LoadState.LOADING);

			var classResource:PluginInfoResource = loadTrait.resource as PluginInfoResource; 	
			var pluginInfo:PluginInfo = classResource.pluginInfo;
			
			loadFromPluginInfo(loadTrait, pluginInfo);
		}
		
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			var pluginLoadTrait:PluginLoadTrait = loadTrait as PluginLoadTrait;
			var pluginInfo:PluginInfo = pluginLoadTrait.pluginInfo;

			updateLoadTrait(loadTrait, LoadState.UNLOADING);
						
			unloadFromPluginInfo(pluginInfo);
			
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
		}
	}
}