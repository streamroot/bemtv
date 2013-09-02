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
package org.osmf.events
{
	import flash.events.Event;

	import org.osmf.elements.f4mClasses.Manifest;

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * An event used by parsers to indicate completion or errors.
	 */
	public class ParseEvent extends Event
	{
		/**
		 * Constructor.
		 *
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * @param data The parsed object.
		 */
		public function ParseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object=null)
		{
			this.data = data;

			super(type, bubbles, cancelable);
		}

		/**
		 * Dispatched when a parser has finished its operation.
		 */
		public static const PARSE_COMPLETE:String = "parseComplete";

		/**
		 * Dispatched when an error is encountered while parsing.
		 */
		public static const PARSE_ERROR:String = "parseError";

		/**
		 * The object parsed.
		 */
		public var data:Object;

		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new ParseEvent(this.type, this.bubbles, this.cancelable, this.data);
		}
	}
}