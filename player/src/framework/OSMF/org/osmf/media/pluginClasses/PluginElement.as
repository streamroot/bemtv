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
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.LoadableElementBase;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.LoadTrait;
	
	/**
	 * PluginElement is a MediaElement used for integrating
	 * external modules (plugins) into a Open Source Media Framework application to provide enhanced functionality.
	 * <p>A PluginElement can represent a dynamic plugin, which is loaded at runtime from a SWF or SWC,
	 * or a static plugin, which is compiled as part of the application.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	internal class PluginElement extends LoadableElementBase
	{
		/**
		 * Constructor.
		 * 
		 * @param resource Resource for the plugin code. For static plugins, 
		 * this is a PluginInfoResource. 
		 * For dynamic plugins it is a URLResource.
		 * @see PluginInfoResource
		 * @see org.osmf.media.URLResource
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function PluginElement(loader:PluginLoader, resource:MediaResourceBase=null)
		{
			super(resource, loader);			
		}
		
		/**
		 * @private
		 */
		override protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase):LoadTrait
		{
			return new PluginLoadTrait(loader, resource);
		}
	}
}