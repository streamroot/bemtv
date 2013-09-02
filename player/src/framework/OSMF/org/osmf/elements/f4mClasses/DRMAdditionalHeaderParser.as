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
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import org.osmf.events.ParseEvent;
	import org.osmf.net.httpstreaming.HTTPStreamingUtils;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.utils.URL;

	[ExcludeClass]

	[Event(name="parseComplete", type="org.osmf.events.ParseEvent")]
	[Event(name="parseError", type="org.osmf.events.ParseEvent")]

	/**
	 * @private
	 *
	 * Parses DRM header XML.
	 */
	public class DRMAdditionalHeaderParser extends BaseParser
	{
		/**
		 * Constructor.
		 */
		public function DRMAdditionalHeaderParser()
		{

		}

		/**
		 * @private
		 */
		override public function parse(value:String, baseURL:String=null, idPrefix:String=""):void
		{
			var root:XML = new XML(value);

			if (!root)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_VALUE_MISSING));
			}

			var drmAdditionalHeader:DRMAdditionalHeader = new DRMAdditionalHeader();

			var url:String = null;

			if (root.attribute("id").length() > 0)
			{
				drmAdditionalHeader.id = idPrefix + root.@id;
			}

			if (root.attribute("url").length() > 0)
			{
				url = root.@url;
				if (!URL.isAbsoluteURL(url))
				{
					url = URL.normalizeRootURL(baseURL) + URL.normalizeRelativeURL(url);
				}
				drmAdditionalHeader.url = url;
			}
			else
			{
				var metadata:String = root.text();
				var decoder:Base64Decoder = new Base64Decoder();
				decoder.decode(metadata);
				drmAdditionalHeader.data = decoder.drain();
			}

			// DRM Metadata  - we may make this load on demand in the future.
			if (url != null)
			{
				if (!loadingInfo)
				{
					loadingInfo = new Dictionary(true);
				}

				var loader:URLLoader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.addEventListener(Event.COMPLETE, onLoadComplete);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);

				loadingInfo[loader] = drmAdditionalHeader;

				loader.load(new URLRequest(HTTPStreamingUtils.normalizeURL(url)));
			}
			else
			{
				finishLoad(drmAdditionalHeader);
			}
		}

		/**
		 * Finishes loading a parsed object.
		 *
		 * @param header The completed <code>DRMAdditionalHeader</code> object.
		 *
		 * @private
		 * In protected scope so that subclasses have an opportunity to do
		 * stuff before loading finishes.
		 */
		protected function finishLoad(header:DRMAdditionalHeader):void
		{
			if (!header)
			{
				return;
			}

			dispatchEvent(new ParseEvent(ParseEvent.PARSE_COMPLETE, false, false, header));
		}

		private function onLoadComplete(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;

			loader.removeEventListener(Event.COMPLETE, onLoadComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);

			var drmAdditionalHeader:DRMAdditionalHeader = loadingInfo[loader];
			drmAdditionalHeader.data = loader.data;

			delete loadingInfo[loader];

			finishLoad(drmAdditionalHeader);
		}

		private function onLoadError(event:Event):void
		{
			dispatchEvent(new ParseEvent(ParseEvent.PARSE_ERROR));
		}

		private var loadingInfo:Dictionary;
	}
}