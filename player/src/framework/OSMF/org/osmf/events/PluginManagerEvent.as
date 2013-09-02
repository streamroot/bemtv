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
package org.osmf.events
{
	import flash.events.Event;
	
	import org.osmf.media.MediaResourceBase;
	
	[ExcludeClass]

	/**
	 * @private
	 * 
	 * Event class for event dispatched by a PluginManager.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class PluginManagerEvent extends Event
	{
		/**
		 * The PluginManagerEvent.PLUGIN_LOAD constant defines the value of the
		 * type property of the event object for a pluginLoad event.
		 * 
		 * @eventType pluginLoad
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const PLUGIN_LOAD:String		= "pluginLoad";
		
		/**
		 * The PluginManagerEvent.PLUGIN_LOAD_ERROR constant defines the value of the
		 * type property of the event object for a pluginLoadError event.
		 * 
		 * @eventType pluginLoadError
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const PLUGIN_LOAD_ERROR:String	= "pluginLoadError";

		/**
		 * Constructor.
		 * 
		 * @param type The type of the event.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
 		 * @param resource The resource representing the plugin.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function PluginManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, resource:MediaResourceBase=null)
		{
			super(type, bubbles, cancelable);
			
			_resource = resource;
		}
		
		/**
		 * The resource representing the plugin.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function get resource():MediaResourceBase
		{
			return _resource;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new PluginManagerEvent(type, bubbles, cancelable, _resource);
		}
		
		// Internals
		//

		private var _resource:MediaResourceBase;
	}
}