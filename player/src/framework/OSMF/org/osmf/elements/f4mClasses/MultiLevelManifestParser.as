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
package org.osmf.elements.f4mClasses
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	import mx.messaging.channels.StreamingAMFChannel;
	
	import org.osmf.events.ParseEvent;
	import org.osmf.net.httpstreaming.HTTPStreamingUtils;
	import org.osmf.utils.URL;

	[ExcludeClass]

	/**
	 * @private
	 *
	 * Handles the parsing of manifest XML that could contain multi-level media nodes.
	 */
	public class MultiLevelManifestParser extends ManifestParser
	{
		/**
		 * Constructor.
		 */
		public function MultiLevelManifestParser()
		{
			super();
		}

		/**
		 * @private
		 * 
		 * //XXX idPrefix is not propagated to the stream-level manifests. It should not be passed to this function. 
		 * 
		 */
		override public function parse(value:String, rootURL:String = null, manifest:Manifest = null, idPrefix:String = ""):void
		{
			parsing = true;

			this.manifest = new Manifest();

			var root:XML = new XML(value);
			var nmsp:Namespace = root.namespace();

			// The first thing we'll need to parse is the top level XML we just received.
			queue = [];
			queue.push(root);
			
			// Save off any information we need.
			if (!baseURLs)
			{
				baseURLs = new Dictionary(true);
			}
			
			var baseURL:String = rootURL;
			if (root.nmsp::baseURL.length() > 0)
			{
				baseURL = root.nmsp::baseURL.text();
			}
			baseURL = URL.normalizeRootURL(baseURL);
			
			baseURLs[root] = baseURL;

			// Check to see if we need to load any other manifests.
			// The url will be in the <media> nodes.
			for each (var media:XML in root.nmsp::media)
			{
				if (media.attribute('href').length() > 0)
				{
					unfinishedLoads++;

					// Get the link.
					var href:String = media.@href;
					if (!URL.isAbsoluteURL(href))
					{
						href = URL.normalizeRootURL(baseURL) + URL.normalizeRelativeURL(href);
					}

					// Get ready to load.
					var loader:URLLoader = new URLLoader();
					loader.addEventListener(Event.COMPLETE, onLoadComplete);
					loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
					loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);

					// Save off any information we need.
					if (!loadingInfo)
					{
						loadingInfo = new Dictionary(true);
					}

					var info:Info = new Info();

					info.baseURL = URL.normalizeRootURL(URL.getRootUrl(href));

					if (media.attribute('bitrate').length() > 0)
					{
						info.attributes.bitrate = media.@bitrate;
					}
					
					if (media.attribute('width').length() > 0)
					{
						info.attributes.width = media.@width;
					}
					
					if (media.attribute('height').length() > 0)
					{
						info.attributes.height = media.@height;
					}
					
					if (media.attribute('type').length() > 0)
					{
						info.attributes.type = media.@type;
					}
					
					if (media.hasOwnProperty("@alternate") || media.attribute('alternate').length() > 0)
					{
						info.attributes.alternate = "true";
					}
					
					if (media.attribute('label').length() > 0)
					{
						info.attributes.label = media.@label;
					}
					
					if (media.attribute('lang').length() > 0)
					{
						info.attributes.lang = media.@lang;
					}

					loadingInfo[loader] = info;

					loader.load(new URLRequest(HTTPStreamingUtils.normalizeURL(href)));
				}
			}

			parsing = false;

			if (unfinishedLoads == 0)
			{
				processQueue();
			}
		}

		/**
		 * @private
		 */
		override protected function finishLoad(manifest:Manifest):void
		{
			if (!processQueue())
			{
				// The baseURL means nothing here because each source came from someplace different.
				// The urls have already been made absolute, so just null it out.
				manifest.baseURL = null;

				// Let the parsing finish as usual.
				super.finishLoad(manifest);
			}
		}

		/**
		 * @private
		 */
		override protected function buildMediaParser():BaseParser
		{
			return new ExternalMediaParser();
		}

		/**
		 * @private
		 * @return Whether or not an item from the queue is being processed.
		 */
		private function processQueue():Boolean
		{
			// We're still parsing so just assume we're not done.
			if (parsing)
			{
				return true;
			}

			// If there's anything left to parse, process it.
			if (queue.length > 0)
			{
				var xml:XML = queue.pop() as XML;
				var baseURL:String = baseURLs[xml];
				externalMediaCount += 1;
				var idPrefix:String = "external" + externalMediaCount + "_";
				super.parse(xml.toXMLString(), baseURL, manifest, idPrefix);
				return true;
			}
			else
			{
				return false;
			}
		}

		private function onLoadComplete(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;

			loader.removeEventListener(Event.COMPLETE, onLoadComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);

			// Pull out the media node from the manifest.
			var root:XML = XML(URLLoader(event.target).data);
			var nmsp:Namespace = root.namespace();

			// Get the saved information.
			var info:Info = loadingInfo[loader];
			delete loadingInfo[loader];

			for each (var media:XML in root.nmsp::media)
			{
				
				// Put the properties into the media node(s).
				// Note: There *should* only be one media node, but we'll
				// dump the bitrate in a for...each just in case.
				
				var infoList:XMLList = flash.utils.describeType(info.attributes)..variable;
				
				var key:String;
				for (var i:int; i < infoList.length(); i++)
				{
					key = infoList[i].@name;
					if (info.attributes[key] != null && info.attributes[key].length > 0)
					{
						media.@[key] = info.attributes[key];
					}
					else
					{
						delete media.@[key];
					}
				}
			}

			// Save off any information we need.
			if (!baseURLs)
			{
				baseURLs = new Dictionary(true);
			}

			baseURLs[root] = URL.normalizeRootURL(info.baseURL);

			queue.push(root);

			// Once we've finished loading we can process everything.
			unfinishedLoads--;
			
			if (unfinishedLoads == 0)
			{
				processQueue();
			}
		}

		private function onLoadError(event:Event):void
		{
			unfinishedLoads--;
			dispatchEvent(new ParseEvent(ParseEvent.PARSE_ERROR));
		}

		private var parsing:Boolean = false;

		private var unfinishedLoads:Number = 0;

		private var manifest:Manifest;

		private var queue:Array;

		private var baseURLs:Dictionary;

		private var loadingInfo:Dictionary;
		
		private var externalMediaCount:Number = 0;
	}
}

class Info
{
	public var baseURL:String;
	public var attributes:Attributes;
	
	
	public function Info()
	{
		attributes = new Attributes();
	}
}

class Attributes
{
	public var bitrate:String;
	
	public var width:String;
	
	public var height:String;
	
	public var type:String;
	
	public var alternate:String;
	
	public var label:String;
	
	public var lang:String;
}