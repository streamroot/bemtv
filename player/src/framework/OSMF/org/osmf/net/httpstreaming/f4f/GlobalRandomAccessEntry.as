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
	 * frame in another fragment, therefore name GlobalRandomAccessEntry.
	 */
	internal class GlobalRandomAccessEntry
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function GlobalRandomAccessEntry()
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
		 * The Segment Id corresponding to this random access point
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get segment():uint
		{
			return _segment;
		}

		public function set segment(value:uint):void
		{
			_segment = value;
		}
		
		/**
		 * The Fragment Id corresponding to this random access point
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get fragment():uint
		{
			return _fragment;
		}
		
		public function set fragment(value:uint):void
		{
			_fragment = value;
		}

		/**
		 * The byte offset from the beginning of the corresponding Segment of the afra of the Fragment associated 
		 * with this random access point
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get afraOffset():Number
		{
			return _afraOffset;
		}
		
		public function set afraOffset(value:Number):void
		{
			_afraOffset = value;
		}

		/**
		 * The byte offset of this random access point from the associated afra
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get offsetFromAfra():Number
		{
			return _offsetFromAfra;
		}

		public function set offsetFromAfra(value:Number):void
		{
			_offsetFromAfra = value;
		}

		// Internals
		//
		
		private var _time:Number;
		private var _segment:uint;
		private var _fragment:uint;
		private var _afraOffset:Number;
		private var _offsetFromAfra:Number;
	}
}