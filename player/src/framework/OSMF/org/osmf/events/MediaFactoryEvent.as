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
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;

	/**
	 * A MediaFactoryEvent is dispatched when the MediaFactory creates a MediaElement or
	 * succeeds or fails at loading a plugin.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class MediaFactoryEvent extends Event
	{
		/**
		 * The MediaFactoryEvent.PLUGIN_LOAD constant defines the value of the
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
		 * The MediaFactoryEvent.PLUGIN_LOAD_ERROR constant defines the value of the
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
		 * The MediaFactoryEvent.MEDIA_ELEMENT_CREATE constant defines the value of the
		 * type property of the event object for a mediaElementCreate event.
		 * 
		 * @eventType pluginLoad
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const MEDIA_ELEMENT_CREATE:String		= "mediaElementCreate";

		/**
		 * Constructor.
		 * 
		 * @param type The type of the event.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
 		 * @param resource The resource representing the plugin.  Null if type is neither
 		 * PLUGIN_LOAD nor PLUGIN_LOAD_ERROR.
 		 * @param mediaElement The created MediaElement.  Null if type is not MEDIA_ELEMENT_CREATE.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function MediaFactoryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, resource:MediaResourceBase=null, mediaElement:MediaElement=null)
		{
			super(type, bubbles, cancelable);
			
			_resource = resource;
			_mediaElement = mediaElement;
		}
		
		/**
		 * The resource representing the plugin.  Null if type is neither
 		 * PLUGIN_LOAD nor PLUGIN_LOAD_ERROR.
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
		 * The created MediaElement.  Null if type is not MEDIA_ELEMENT_CREATE.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function get mediaElement():MediaElement
		{
			return _mediaElement;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new MediaFactoryEvent(type, bubbles, cancelable, _resource, _mediaElement);
		}
		
		// Internals
		//

		private var _resource:MediaResourceBase;
		private var _mediaElement:MediaElement;
	}
}