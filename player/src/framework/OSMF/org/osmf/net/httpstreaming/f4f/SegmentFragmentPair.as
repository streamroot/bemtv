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
	 * Segment fragment pair that has first segment number and the number of fragments per segment.
	 * It also has the accrued number of fragments up to the point.
	 */
	internal class SegmentFragmentPair
	{
		/**
		 * Constructor
		 * 
		 * @param firstSegment The Id of the segment of a list of consecutive segments that have the same number of fragments
		 * @param fragmentsPerSegement The number of fragments that each segment contains
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function SegmentFragmentPair(firstSegment:uint, fragmentsPerSegment:uint)
		{
			_firstSegment = firstSegment;
			_fragmentsPerSegment = fragmentsPerSegment;
		}
		
		/**
		 * The Id of the segment of a list of consecutive segments that have the same number of fragments
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get firstSegment():uint
		{
			return _firstSegment;
		}
		
		/**
		 * The number of fragments that each segment contains
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get fragmentsPerSegment():uint
		{
			return _fragmentsPerSegment;
		}
		
		/**
		 * The number of fragments accrued up to the current segment
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set fragmentsAccrued(v:uint):void
		{
			_fragmentsAccrued = v;
		}
		
		public function get fragmentsAccrued():uint
		{
			return _fragmentsAccrued;
		}
		
		// Internal
		//
		
		private var _firstSegment:uint;
		private var _fragmentsPerSegment:uint;
		private var _fragmentsAccrued:uint;
	}
}