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
package org.osmf.net.httpstreaming.f4f
{
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * An entry in the fragment random access table. This entry points to a key
	 * frame with the current fragment, therefore name LocalRandomAccessEntry.
	 */
	internal class LocalRandomAccessEntry
	{
		/**
		 * Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function LocalRandomAccessEntry()
		{
			super();
		}
		
		/**
		 * A 64 bit integer that indicates the presentation time of the random access sample 
		 * in units defined in the timescale field 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get time():Number
		{
			return _time;
		}

		public function set time(value:Number):void
		{
			_time = value;
		}

		/**
		 * The byte-offset between the beginning of the this afra and the beginning of the random access sample
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get offset():Number
		{
			return _offset;
		}

		public function set offset(value:Number):void
		{
			_offset = value;
		}

		// Internal
		//
		
		private var _time:Number;
		private var _offset:Number;
	}
}