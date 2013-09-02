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
package org.osmf.elements.f4mClasses.builders
{
	import org.osmf.elements.f4mClasses.ManifestParser;
	import org.osmf.elements.f4mClasses.utils.F4MUtils;
	import org.osmf.media.pluginClasses.VersionUtils;

	[ExcludeClass]

	/**
	 * @private
	 *
	 * Creates a parser for a 'base' manifest implementation.  This is defined as any f4m that is not multi-level.
	 * <p>This includes all f4m files that are 1.0 or earlier.</p>
	 */
	public class ManifestBuilder extends BaseManifestBuilder
	{
		/**
		 * Constructor.
		 */
		public function ManifestBuilder()
		{

		}

		/**
		 * @private
		 */
		override public function canParse(resource:String):Boolean
		{
			var resourceVersion:Object = getVersion(resource);

			return (resourceVersion.major >= MINIMUM_VERSION.major && resourceVersion.major <= MAXIMUM_VERSION.major && resourceVersion.minor >= MINIMUM_VERSION.minor && resourceVersion.minor <= MAXIMUM_VERSION.minor);
		}

		/**
		 * @private
		 */
		override public function build(resource:String):ManifestParser
		{
			var parser:ManifestParser = createParser();
			return parser;
		}

		/**
		 * Returns the version of a resource.
		 *
		 * @param resource
		 * @return An object containing <code>major</code> and <code>minor</code> properties.
		 *
		 * @private
		 * In protected scope so that the method to obtain the version can be changed.
		 */
		protected function getVersion(resource:String):Object
		{
			return F4MUtils.getVersion(resource);
		}

		/**
		 * Creates a parser for this builder.
		 *
		 * @return
		 *
		 * @private
		 * In protected scope so that the parser can be changed.
		 */
		protected function createParser():ManifestParser
		{
			return new ManifestParser();
		}

		private static const MINIMUM_VERSION:Object = VersionUtils.parseVersionString("0.0");

		private static const MAXIMUM_VERSION:Object = VersionUtils.parseVersionString("1.9");
	}
}