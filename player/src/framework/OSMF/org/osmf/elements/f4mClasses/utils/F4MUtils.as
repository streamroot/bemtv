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
package org.osmf.elements.f4mClasses.utils
{
	import org.osmf.media.pluginClasses.VersionUtils;

	[ExcludeClass]

	/**
	 * @private
	 **/
	public class F4MUtils
	{
		/**
		 * Returns the version based on the default namespace of the F4M example.
		 * <p>An example of a version 1.0 namespace: "http://ns.adobe.com/f4m/1.0"</p>
		 *
		 * @param resource
		 * @return An object containing <code>major</code> and <code>minor</code> properties.
		 */
		public static function getVersion(resource:String):Object
		{
			var resourceXML:XML = new XML(resource);
			var namespace:String = resourceXML.namespace().toString();

			// Example: "http://ns.adobe.com/f4m/1.0"
			var versionString:String;
			var slashIdx:int = namespace.lastIndexOf("/");
			// Everything after the last slash should be the version.
			if (slashIdx != -1)
			{
				versionString = namespace.substr(slashIdx + 1);
			}
			// If there's no slash just use everything.
			else
			{
				versionString = namespace;
			}

			return VersionUtils.parseVersionString(versionString);
		}
	}
}