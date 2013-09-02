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
	 * Entry in the fragment run table, the first fragment number and the duration. It
	 * provides the accrued duration up to the point.
	 */
	internal class FragmentDurationPair
	{
		/**
		 * Constructor
		 * 
		 * @param firstFragment The Id of the first of the list of consecutive fragments that have the same duration 
		 * @param duration The duration of each fragment
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function FragmentDurationPair()
		{
		}
		
		/**
		 * The Id of the first fragment of a list of consecutive fragments that have the same duration.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get firstFragment():uint
		{
			return _firstFragment;
		}

		public function set firstFragment(value:uint):void
		{
			_firstFragment = value;
		}
		
		/**
		 * The duration of each fragment
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get duration():uint
		{
			return _duration;
		}

		public function set duration(value:uint):void
		{
			_duration = value;
		}
		
		/**
		 * Accrued duration up to the point of the fragment.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get durationAccrued():Number
		{
			return _durationAccrued;
		}

		public function set durationAccrued(value:Number):void
		{
			_durationAccrued = value;
		}
		
		/**
		 * Signal discontinuities in timestamps and/or Fragment numbers. This is also implicitly
		 * used to identify the end of a (live) presentation.
		 * Currently, the following values are defined and the rest is reserved:
		 *    0x00 indicates end of presentation implicitly by signaling no discontinuities.
		 *    0x01 indicates a discontinuity in Fragment numbering.
		 *    0x02 indicates a discontinuity in timestamps.
		 *    0x03 indicates a discontinuity in both timestamps and Fragment numbering.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get discontinuityIndicator():uint
		{
			return _discontinuityIndicator;
		}

		public function set discontinuityIndicator(value:uint):void
		{
			_discontinuityIndicator = value;
		}
		 
		// Internals
		//

		private var _firstFragment:uint;
		private var _duration:uint;
		private var _durationAccrued:Number;
		private var _discontinuityIndicator:uint = 0;
	}
}