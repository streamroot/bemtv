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
	import org.osmf.elements.f4mClasses.utils.F4MUtils;
	import org.osmf.events.ParseEvent;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.utils.URL;

	[ExcludeClass]

	[Event(name="parseComplete", type="org.osmf.events.ParseEvent")]
	[Event(name="parseError", type="org.osmf.events.ParseEvent")]

	/**
	 * @private
	 *
	 * Parses DVR info XML.
	 */
	public class DVRInfoParser extends BaseParser
	{
		/**
		 * Constructor.
		 */
		public function DVRInfoParser()
		{

		}

		/**
		 * @private
		 */
		override public function parse(value:String, baseURL:String=null, idPrefix:String = ""):void
		{
			var root:XML = new XML(value);

			if (!root)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_VALUE_MISSING));
			}

			var majorVersion:Number = F4MUtils.getVersion(value).major as Number;
			
			var dvrInfo:DVRInfo = new DVRInfo();
			
			if (root.attribute("id").length() > 0)
			{
				dvrInfo.id = root.@id;
			}
			if (root.attribute("url").length() > 0)
			{
				var url:String = root.@url;
				if (!URL.isAbsoluteURL(url))
				{
					url = URL.normalizeRootURL(baseURL) + URL.normalizeRelativeURL(url);
				}
				dvrInfo.url = url;
			}
			
			// If the manifest is version 1 or less, look for beginOffset and endOffset
			// Otherwise, look for windowDuration
			
			var v:Number; 
			
			if (majorVersion <= 1)
			{
				if (root.attribute("beginOffset").length() > 0)
				{
					dvrInfo.beginOffset = Math.max(0, parseInt(root.@beginOffset));
				}
				if (root.attribute("endOffset").length() > 0)
				{
					v = new Number(root.@endOffset);
					if (v > 0 && v < 1.0)
					{
						dvrInfo.endOffset = 1;
					}
					else
					{
						dvrInfo.endOffset = Math.max(0, v);
					}
				}
				dvrInfo.windowDuration = -1;
			}
			else // F4M 2.0
			{
				if (root.attribute("windowDuration").length() > 0)
				{
					v = parseInt(root.@windowDuration);
					if (isNaN(v) || v < 0)
					{
						dvrInfo.windowDuration = -1;
					}
					else
					{
						dvrInfo.windowDuration = v;
					}
				}
				else
				{
					dvrInfo.windowDuration = -1;
				}
			}
			
			if (root.attribute("offline").length() > 0)
			{
				var s:String = root.@offline;
				dvrInfo.offline = (s.toLowerCase() == "true");
			}

			finishLoad(dvrInfo);
		}

		/**
		 * Finishes loading a parsed object.
		 *
		 * @param info The completed <code>DVRInfo</code> object.
		 *
		 * @private
		 * In protected scope so that subclasses have an opportunity to do
		 * stuff before loading finishes.
		 */
		protected function finishLoad(info:DVRInfo):void
		{
			if (!info)
			{
				return;
			}

			dispatchEvent(new ParseEvent(ParseEvent.PARSE_COMPLETE, false, false, info));
		}
	}
}