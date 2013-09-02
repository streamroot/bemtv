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
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * MediaFactoryItem is the encapsulation of all information needed to dynamically
	 * create and initialize a MediaElement from a MediaFactory.
	 * 
	 * <p>MediaFactoryItem objects are exposed by plugins (on the PluginInfo class),
	 * and used by the framework to create the MediaElement(s) specified by the
	 * plugin.</p>
	 * 
	 * @see PluginInfo 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class MediaFactoryItem
	{
		// Public interface
		//
		
		/**
		 * Constructor.
		 * 
		 * @param id An identifier that represents this MediaFactoryItem.  Identifiers should reflect
		 * the plugin makers name, and the specific name of the element it generates.  The convention
		 * is to use the package namespace scheme. Two examples:
		 * com.example.MyAdPlugin
		 * com.example.MyAnalyticsPlugin
		 * 
		 * Note: org.osmf should be avoided since the MediaFactory gives precedence to 
		 * non-osmf plugins.
		 * @param canHandleResourceFunction Function which is used to determine
		 * whether this MediaFactoryItem can handle a particular resource.  The
		 * function must take a single parameter of type MediaResourceBase, and
		 * return a Boolean.
		 * @param mediaElementCreationFunction Function which creates a new instance
		 * of the desired MediaElement.  The function must take no params, and
		 * return a MediaElement.
		 * @param type The type of this MediaFactoryItem.  If null, the default is
		 * <code>MediaFactoryItemType.STANDARD</code>.
		 * 
		 * @throws ArgumentError If any argument (except type) is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function MediaFactoryItem
							( id:String
							, canHandleResourceFunction:Function
							, mediaElementCreationFunction:Function
							, type:String=null
							)
		{
			if (	id == null
			     || canHandleResourceFunction == null
			     || mediaElementCreationFunction == null
			   )
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			// Make sure our type field has a valid value. 
			type ||= MediaFactoryItemType.STANDARD;
			
			_id = id;
			_canHandleResourceFunction = canHandleResourceFunction;
			_mediaElementCreationFunction = mediaElementCreationFunction;
			_type = type;
		}
		
		/**
		 *  An identifier that represents this MediaFactoryItem.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get id():String
		{
			return _id;
		}
		
		/**
		 * Function which is used to determine whether this MediaFactoryItem can handle
		 * a particular resource.  The function must take a single parameter of
		 * type MediaResourceBase, and return a Boolean.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get canHandleResourceFunction():Function
		{
			return _canHandleResourceFunction;
		}

		/**
		 * Function which creates a new instance of the desired MediaElement.
		 * The function must take no params, and return a MediaElement.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get mediaElementCreationFunction():Function
		{
			return _mediaElementCreationFunction;
		}
		
		/**
		 * The MediaFactoryItemType for this MediaFactoryItem.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get type():String
		{
			return _type;
		}
		
		// Internals
		//
		
		private var _id:String;
		private var _canHandleResourceFunction:Function;
		private var _mediaElementCreationFunction:Function;
		private var _type:String;
	}
}