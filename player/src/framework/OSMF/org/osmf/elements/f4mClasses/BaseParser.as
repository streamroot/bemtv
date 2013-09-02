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
	import flash.events.EventDispatcher;

	[ExcludeClass]

	/**
	 * @private
	 *
	 * The base class that should be extended by any class that can parse and build
	 * nodes from a F4M file.
	 */
	public class BaseParser extends EventDispatcher
	{
		public function BaseParser()
		{

		}

		/**
		 * Parses a value object from an XML string.
		 * <p>A <code>ParseEvent.PARSE_COMPLETE</code> will be dispatched upon completion.</p>
		 * <p>A <code>ParseEvent.PARSE_ERROR</code> will be dispatched if an error is encountered.</p>
		 *
		 * @throws Error if the parse fails.
		 */
		public function parse(value:String, rootURL:String = null, idPrefix:String = ""):void
		{

		}
	}
}