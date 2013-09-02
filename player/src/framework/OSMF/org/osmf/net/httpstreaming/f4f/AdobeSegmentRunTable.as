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
	import __AS3__.vec.Vector;
	
	CONFIG::LOGGING 
	{	
		import org.osmf.logging.Logger;
	}

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Segment run table. Each entry in the table is the first segment of a sequence of 
	 * segments that have the same number of fragments.
	 */
	internal class AdobeSegmentRunTable extends FullBox
	{
		/**
		 * Constructor
		 * 
		 * @param bi The box info that contains the size and type of the box
		 * @param parser The box parser to be used to assist constructing the box
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function AdobeSegmentRunTable()
		{
			super();
			
			_segmentFragmentPairs = new Vector.<SegmentFragmentPair>();
		}

		/**
		 * The quality segment URL modifiers.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get qualitySegmentURLModifiers():Vector.<String>
		{
			return _qualitySegmentURLModifiers;
		}

		public function set qualitySegmentURLModifiers(value:Vector.<String>):void
		{
			_qualitySegmentURLModifiers = value;
		}

		/**
		 * A list of <first segment, number of fragments> pairs.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get segmentFragmentPairs():Vector.<SegmentFragmentPair>
		{
			return _segmentFragmentPairs;
		}

		/**
		 * Adds the given SegmentFragmentPair to this run table.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function addSegmentFragmentPair(sfp:SegmentFragmentPair):void
		{
			var prevSfp:SegmentFragmentPair 
				= _segmentFragmentPairs.length <= 0 
				? null
				: _segmentFragmentPairs[_segmentFragmentPairs.length - 1];
				
			var fragmentsAccrued:uint = 0;
			if (prevSfp != null)
			{
				fragmentsAccrued = prevSfp.fragmentsAccrued + (sfp.firstSegment - prevSfp.firstSegment) * prevSfp.fragmentsPerSegment;
			}
			sfp.fragmentsAccrued = fragmentsAccrued;
			_segmentFragmentPairs.push(sfp);
		}
		
		/**
		 * Given a fragment Id, returns the corresponding Id of the segment that contains
		 * the fragment.
		 * 
		 * @param fragmentId The Id of the fragment whose segment Id is to be returned.
		 * 
		 * @return the Id of the segment that contains the fragment. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function findSegmentIdByFragmentId(fragmentId:uint):uint
		{
			var curSfp:SegmentFragmentPair;
			if (fragmentId < 1)
			{
				// fragmentId should never be smaller than 1, same for segmentId. So 
				// return 0 to signal an error condition.
				return 0;
			}
			
			for (var i:uint = 1; i < _segmentFragmentPairs.length; i++)
			{
				curSfp = _segmentFragmentPairs[i];
				if (curSfp.fragmentsAccrued >= fragmentId)
				{
					return calculateSegmentId(_segmentFragmentPairs[i-1], fragmentId);
				}
			}

			return calculateSegmentId(_segmentFragmentPairs[_segmentFragmentPairs.length - 1], fragmentId);
		}
		
		public function get totalFragments():uint
		{
			return _segmentFragmentPairs[_segmentFragmentPairs.length - 1].fragmentsPerSegment + _segmentFragmentPairs[_segmentFragmentPairs.length - 1].fragmentsAccrued;
		}

		// Internals
		//
		
		private function calculateSegmentId(sfp:SegmentFragmentPair, fragmentId:uint):uint
		{
//			CONFIG::LOGGING
//			{
//				logger.debug("first segment: " + sfp.firstSegment);
//				logger.debug("fragId: " + fragmentId);
//				logger.debug("fragmentsAccrued: " + sfp.fragmentsAccrued);
//				logger.debug("fragmentsPerSegment: " + sfp.fragmentsPerSegment);
//				logger.debug("segId: " + (sfp.firstSegment +  int((fragmentId-1 - sfp.fragmentsAccrued) / sfp.fragmentsPerSegment)));
//			}
			
			return sfp.firstSegment +  int((fragmentId - sfp.fragmentsAccrued - 1) / sfp.fragmentsPerSegment);
		}	
		
		private var _qualitySegmentURLModifiers:Vector.<String>;
		private var _segmentFragmentPairs:Vector.<SegmentFragmentPair>;

		CONFIG::LOGGING
		{
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.net.httpstreaming.f4f.AdobeSegmentRunTable");
		}
	}
}
