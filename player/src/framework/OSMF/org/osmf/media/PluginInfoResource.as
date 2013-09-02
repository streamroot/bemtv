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
package org.osmf.media
{
	/**
	 * PluginInfoResource is a media resource that represents a static plugin. 
	 * 
	 * <p>A static plugin is a plugin that is compiled within the application
	 * that uses it, in contrast to a dynamic plugin, which is loaded at
	 * runtime.</p>
	 * 
	 * @see PluginInfo
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class PluginInfoResource extends MediaResourceBase
	{
		
		/**
		 * Constructor.
		 * 
		 * @param pluginInfo Reference to an instance of PluginInfo.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function PluginInfoResource(pluginInfo:PluginInfo)
		{
			_pluginInfo = pluginInfo;		
		}
			
		/**
		 * Reference to the <code>PluginInfo</code> for this static plugin.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get pluginInfo():PluginInfo
		{
			return _pluginInfo;	
		}
	
		private var _pluginInfo:PluginInfo;
		
	}
}