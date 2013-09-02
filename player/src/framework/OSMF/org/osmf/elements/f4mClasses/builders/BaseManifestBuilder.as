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

	[ExcludeClass]

	/**
	 * @private
	 *
	 * The base class that should be extended by any object that builds a parser to handle a manifest.
	 */
	public class BaseManifestBuilder
	{
		/**
		 * Constructor.
		 */
		public function BaseManifestBuilder()
		{

		}

		/**
		 * Whether or not this builder is able to handle the given resource.
		 *
		 * @param resource
		 * @return
		 */
		public function canParse(resource:String):Boolean
		{
			// To be overridden.
			return false;
		}

		/**
		 * Builds a <code>ManifestParser</code> for a given resource.
		 *
		 * @param resource
		 * @return
		 */
		public function build(resource:String):ManifestParser
		{
			// To be overridden.
			return null;
		}
	}
}