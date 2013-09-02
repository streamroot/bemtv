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

	import org.osmf.events.ParseEvent;
	import org.osmf.net.httpstreaming.HTTPStreamingUtils;
	import org.osmf.utils.OSMFStrings;

	[ExcludeClass]

	/**
	 * @private
	 *
	 * Handles the parsing of multi-level media XML nodes.  Multi-level media XML nodes are introduced in the
	 * 2.0 version of the F4M manifest.  These objects contain an <code>href</code> attribute which
	 * points to another F4M file that contains the actual data for the media object.
	 *
	 * The 2.0 F4M manifest does not require media to be externalized.  If no <code>href</code> attribute
	 * is available, the media XML node is parsed as usual.
	 *
	 * If the F4M file specified in the <code>href</code> attribute has more than one media node
	 * only the *first* will be parsed.  It is assumed that each external F4M file represents *one* media
	 * node.
	 */
	public class ExternalMediaParser extends MediaParser
	{
		/**
		 * Constructor.
		 */
		public function ExternalMediaParser()
		{
			super();
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

			// If there's an external f4m file to load that will have been done by the ManifestParser.
			// We don't need to do anything in this case.
			// Note: If we *tried* to parse what we got here we'd probably just fail with some error.
			if (root.attribute('href').length() > 0)
			{
				dispatchEvent(new ParseEvent(ParseEvent.PARSE_COMPLETE, false, false, null));
			}
			// Otherwise we're a regular media node, so parse.
			else
			{
				super.parse(value, baseURL, idPrefix);
			}
		}
	}
}