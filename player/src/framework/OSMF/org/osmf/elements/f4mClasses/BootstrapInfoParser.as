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
	import org.osmf.events.ParseEvent;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.utils.URL;

	[ExcludeClass]

	[Event(name="parseComplete", type="org.osmf.events.ParseEvent")]
	[Event(name="parseError", type="org.osmf.events.ParseEvent")]

	/**
	 * @private
	 *
	 * Parses bootstrap info XML.
	 */
	public class BootstrapInfoParser extends BaseParser
	{
		/**
		 * Constructor.
		 */
		public function BootstrapInfoParser()
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

			var bootstrapInfo:BootstrapInfo = new BootstrapInfo();

			var url:String = null;

			if (root.attribute('profile').length() > 0)
			{
				bootstrapInfo.profile = root.@profile;
			}
			// Raise parse error
			else
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_PROFILE_MISSING));
			}

			if (root.attribute("id").length() > 0)
			{
				bootstrapInfo.id = idPrefix + root.@id;
			}

			if (root.attribute("url").length() > 0)
			{
				url = root.@url;
				if (!URL.isAbsoluteURL(url))
				{
					url = URL.normalizeRootURL(baseURL) + URL.normalizeRelativeURL(url);
				}
				bootstrapInfo.url = url;
			}
			else
			{
				var metadata:String = root.text();
				var decoder:Base64Decoder = new Base64Decoder();
				decoder.decode(metadata);
				bootstrapInfo.data = decoder.drain();
			}

			finishLoad(bootstrapInfo);
		}

		/**
		 * Finishes loading a parsed object.
		 *
		 * @param info The completed <code>BootstrapInfo</code> object.
		 *
		 * @private
		 * In protected scope so that subclasses have an opportunity to do
		 * stuff before loading finishes.
		 */
		protected function finishLoad(info:BootstrapInfo):void
		{
			if (!info)
			{
				return;
			}

			dispatchEvent(new ParseEvent(ParseEvent.PARSE_COMPLETE, false, false, info));
		}
	}
}