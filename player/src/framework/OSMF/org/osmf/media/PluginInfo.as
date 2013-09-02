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
	import __AS3__.vec.Vector;
	
	import org.osmf.media.pluginClasses.VersionUtils;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.utils.Version;
	
	/**
	 * PluginInfo is the encapsulation of the set of MediaFactoryItem objects
	 * that will be available to the application after the plugin has been
	 * successfully loaded.
	 * Every Open Source Media Framework plugin must define an instance or subclass
	 * of PluginInfo to provide the application with the information it needs
	 * to create and load the plugin's MediaElement.
	 * <p>
	 * From the point of view of the Open Source Media Framework,
	 * the plugin's purpose is to expose the MediaFactoryItem
	 * objects that represent the media that the plugin handles.
	 * These MediaFactoryItem objects could describe standard media types such as
	 * video, audio, or image that can be represented by the built-in Open Source Media Framework
	 * MediaElements: VideoElement, AudioElement, or ImageElement.
	 * More likely, a plugin provides some type of specialized processing,
	 * such as a custom loader or special-purpose media element with
	 * custom implementations of the traits. 
	 * For example, a plugin that provides tracking might implement
	 * a TrackingCompositeElement that includes a customized loader and a customized
	 * PlayTrait implementation that start and stop tracking
	 * as well as the video.
	 * </p>
	 * <p>A PluginInfo also gives the plugin an opportunity to accept or reject a specific
	 * Open Source Media Framework version through its <code>isFrameworkVersionSupported()</code> method.</p>
	 * <p>A dynamic plugin is loaded at runtime from a SWF.
	 * A static plugin is compiled as part of the Open Source Media Framework application.
	 * An application attempting to load a dynamic plugin accesses the class
	 * that extends PluginInfo through
	 * the <code>pluginInfo</code> property on the root of the plugin SWF.
	 * If this class is not found,
	 * the plugin is not loaded.
	 * An application attempting to load a static plugin accesses the PluginInfo
	 * exposed by the PluginInfoResource object.</p>
	 * 
	 * @see PluginInfoResource
	 * @see MediaFactoryItem
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class PluginInfo
	{
		/**
		 * Metadata namespace URL for a MediaFactory that is passed from player
		 * to plugin.
		 * 
		 * <p>Client code can set this on the MediaResourceBase that is passed
		 * to <code>MediaFactory.loadPlugin</code>, and it will be exposed to
		 * the plugin on the MediaResourceBase that is passed to
		 * <code>PluginInfo.initializePlugin</code>.</p>
		 **/
		public static const PLUGIN_MEDIAFACTORY_NAMESPACE:String = "http://www.osmf.org/plugin/mediaFactory/1.0";

		/**
		 * Constructor.
		 * 
		 * @param mediaFactoryItems Vector of MediaFactoryItem objects that this plugin
		 * exposes.
		 * @param mediaElementCreationNotificationFunction Optional function which,
		 * if specified, is invoked for each MediaElement that is created from the
		 * MediaFactory to which this MediaFactoryItem is added.  If specified,
		 * the function must take one param of type MediaElement, and return void.
		 * This callback function is useful for MediaFactoryItems which need to be
		 * notified when other MediaElements are created (e.g. so as to listen to
		 * or control them).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function PluginInfo(mediaFactoryItems:Vector.<MediaFactoryItem>=null, mediaElementCreationNotificationFunction:Function=null)
		{
			super();
			
			_mediaFactoryItems = mediaFactoryItems != null ? mediaFactoryItems : new Vector.<MediaFactoryItem>();
			_mediaElementCreationNotificationFunction = mediaElementCreationNotificationFunction;
		}
		
		/**
		 * The number of MediaFactoryItem objects that the plugin
		 * exposes to the loading application.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get numMediaFactoryItems():int
		{
			return _mediaFactoryItems.length;
		}
		
		/**
		 * The version of the framework that this plugin was compiled against.  The
		 * current version can be obtained from org.osmf.utils.Version.version.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get frameworkVersion():String
		{
			return Version.version;
		}

		/**
		 * Returns the MediaFactoryItem object at the specified index.
		 * <p>If the index is out of range, throws a
		 * RangeError.</p>
		 * @param index Zero-based index position of the requested MediaFactoryItem.
		 * @return A MediaFactoryItem object representing media to be loaded.
		 * @see RangeError
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getMediaFactoryItemAt(index:int):MediaFactoryItem
		{
			if (index < 0 || index >= _mediaFactoryItems.length)
			{
				throw new RangeError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return _mediaFactoryItems[index] as MediaFactoryItem;
		}
		
		/**
		 * Returns <code>true</code> if the plugin supports the specified version
		 * of the framework, in which case the loading application loads the plugin.
		 * Returns <code>false</code> if the plugin does not support the specified version
		 * of the framework, in which case the loading application does not load the plugin.
		 * @param version Version string of the Open Source Media Framework version.
		 * @return Returns <code>true</code> if the version is supported.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function isFrameworkVersionSupported(version:String):Boolean
		{
			if (version == null || version.length == 0)
			{
				return false;
			}

			var playerFrameworkVersion:Object = VersionUtils.parseVersionString(version);
			var pluginFrameworkVersion:Object = VersionUtils.parseVersionString(frameworkVersion);
			
			// A plugin supports the specified version if it's higher than or
			// the same as the plugin's version.
			return 		playerFrameworkVersion.major > pluginFrameworkVersion.major
					||	(	playerFrameworkVersion.major == pluginFrameworkVersion.major
						&&	( 	playerFrameworkVersion.minor >= pluginFrameworkVersion.minor
							)
						);
		}
		
		/**
		 * Initialization method invoked by the media framework when this plugin
		 * is being initialized, and which provides the plugin the resource which
		 * was used to request the plugin.  By default does nothing, but plugins
		 * can override this method to specify their own initialization logic.
		 * 
		 * <p>Note that an instance of PluginInfo may be instantiated before the
		 * framework has determined that that plugin is truly going to be used, so
		 * it is strongly recommended that any initialization logic be placed
		 * within an override of this method to avoid duplicate initialization.</p>
		 * 
		 * <p>This method is called before getMediaFactoryItemAt or get
		 * numMediaFactoryItems.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function initializePlugin(resource:MediaResourceBase):void
		{
		}
		
		/**
		 * Optional function which is invoked for every MediaElement that is
		 * created from the MediaFactory to which this plugin's MediaFactoryItem
		 * objects are added.  The function must take one param of type
		 * MediaElement, and return void. This callback function is useful for
		 * plugins who want to be notified when other MediaElement are created
		 * (e.g. so as to listen to or control them).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get mediaElementCreationNotificationFunction():Function
		{
			return _mediaElementCreationNotificationFunction;
		}
		
		// Protected
		//
		
		/**
		 * The MediaFactoryItem objects that this PluginInfo exposes.
		 **/
		protected final function get mediaFactoryItems():Vector.<MediaFactoryItem>
		{
			return _mediaFactoryItems;
		}
		
		protected final function set mediaFactoryItems(value:Vector.<MediaFactoryItem>):void
		{
			_mediaFactoryItems = value;
		}

		// Internals
		//
		
		private var _mediaFactoryItems:Vector.<MediaFactoryItem>;
		private var _mediaElementCreationNotificationFunction:Function;
	}
}