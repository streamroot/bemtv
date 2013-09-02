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
	import org.osmf.media.MediaElement;
	
	internal class PluginEntry
	{
		public function PluginEntry(pluginElement:MediaElement, state:PluginLoadingState)
		{
			_pluginElement = pluginElement;
			_state = state;
		}
		
		public function get pluginElement():MediaElement
		{
			return _pluginElement;
		}
		
		public function get state():PluginLoadingState
		{
			return _state;
		}
		
		public function set state(value:PluginLoadingState):void
		{
			_state = value;
		}

		// Internals
		//
		
		private var _pluginElement:MediaElement;
		private var _state:PluginLoadingState;
	}
}