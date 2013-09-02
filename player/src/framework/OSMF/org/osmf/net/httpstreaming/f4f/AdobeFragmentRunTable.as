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

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Fragment run table. Each entry in the table is the first fragment of a sequence of 
	 * fragments that have the same duration.
	 */
	internal class AdobeFragmentRunTable extends FullBox
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
		public function AdobeFragmentRunTable()
		{
			super();
			
			_fragmentDurationPairs = new Vector.<FragmentDurationPair>();
		}
		
		/**
		 * The time scale for this run table.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get timeScale():uint
		{
			return _timeScale;
		}
		
		public function set timeScale(value:uint):void
		{
			_timeScale = value;
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
		 * A list of <first fragment, duration> pairs.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get fragmentDurationPairs():Vector.<FragmentDurationPair>
		{
			return _fragmentDurationPairs;
		}
		
		/**
		 * Append a fragment duration pair to the list. The accrued duration for the newly appended
		 * fragment duration needed to be calculated. This is basically the total duration till the
		 * time spot that the newly appended fragment duration pair represents.
		 * 
		 * @param fdp The <first fragment, duration> pair to be appended to the list.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function addFragmentDurationPair(fdp:FragmentDurationPair):void
		{
			_fragmentDurationPairs.push(fdp);
		}
		
		/**
		 * Given a time spot in terms of the time scale used by the fragment table, returns the corresponding
		 * Id of the fragment that contains the time spot.
		 * 
		 * @return the Id of the fragment that contains the time spot.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function findFragmentIdByTime(time:Number, totalDuration:Number, live:Boolean=false):FragmentAccessInformation
		{
			if (_fragmentDurationPairs.length <= 0)
			{
				return null;
			}
			
			var fdp:FragmentDurationPair = null;
			
			for (var i:uint = 1; i < _fragmentDurationPairs.length; i++)
			{
				fdp = _fragmentDurationPairs[i];
				if (fdp.durationAccrued >= time)
				{
					return validateFragment(calculateFragmentId(_fragmentDurationPairs[i - 1], time), totalDuration, live);
				}
			}
			
			return validateFragment(calculateFragmentId(_fragmentDurationPairs[_fragmentDurationPairs.length - 1], time), totalDuration, live);
		}
		
		/**
		 * Given a fragment id, check whether the current fragment is valid or a discontinuity.
		 * If the latter, skip to the nearest fragment and return the new fragment id.
		 * 
		 * @return the Id of the fragment that is valid.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function validateFragment(fragId:uint, totalDuration:Number, live:Boolean=false):FragmentAccessInformation
		{
			var size:uint = _fragmentDurationPairs.length - 1;
			var fai:FragmentAccessInformation = null;

			for (var i:uint = 0; i < size; i++)
			{
				var curFdp:FragmentDurationPair = _fragmentDurationPairs[i];
				var nextFdp:FragmentDurationPair = _fragmentDurationPairs[i+1];
				if ((curFdp.firstFragment <= fragId) && (fragId < nextFdp.firstFragment))
				{
					if (curFdp.duration <= 0)
					{
						fai = getNextValidFragment(i+1, totalDuration);
					}
					else
					{
						fai = new FragmentAccessInformation();
						fai.fragId = fragId;
						fai.fragDuration = curFdp.duration;
						fai.fragmentEndTime = curFdp.durationAccrued + curFdp.duration * (fragId - curFdp.firstFragment + 1);
					}
					
					break;
				}
				else if ((curFdp.firstFragment <= fragId) && endOfStreamEntry(nextFdp))
				{
					if (curFdp.duration > 0)
					{
						var timeResidue:Number = totalDuration - curFdp.durationAccrued;
						var timeDistance:Number = (fragId - curFdp.firstFragment + 1) * curFdp.duration;
						var fragStartTime:Number = (fragId - curFdp.firstFragment) * curFdp.duration;
						if (timeResidue > fragStartTime)
						{
							if (!live || ((fragStartTime + curFdp.duration + curFdp.durationAccrued) <= totalDuration))
							{
								fai = new FragmentAccessInformation();
								fai.fragId = fragId;
								fai.fragDuration = curFdp.duration;
								if (timeResidue >= timeDistance)
								{
									fai.fragmentEndTime = curFdp.durationAccrued + timeDistance;
								}
								else
								{
									fai.fragmentEndTime = curFdp.durationAccrued + timeResidue;
								}
								break;				
							}
						}						
					}
					
				}
			}
			if (fai == null)
			{
				var lastFdp:FragmentDurationPair = _fragmentDurationPairs[size];
				if (lastFdp.duration > 0 && fragId >= lastFdp.firstFragment)
				{
					timeResidue = totalDuration - lastFdp.durationAccrued;
					timeDistance = (fragId - lastFdp.firstFragment + 1) * lastFdp.duration;
					fragStartTime = (fragId - lastFdp.firstFragment) * lastFdp.duration;
					if (timeResidue > fragStartTime)
					{
						if (!live || ((fragStartTime + lastFdp.duration + lastFdp.durationAccrued) <= totalDuration))
						{
							fai = new FragmentAccessInformation();
							fai.fragId = fragId;
							fai.fragDuration = lastFdp.duration;
							if (timeResidue >= timeDistance)
							{
								fai.fragmentEndTime = lastFdp.durationAccrued + timeDistance;
							}
							else
							{
								fai.fragmentEndTime = lastFdp.durationAccrued + timeResidue;
							}
						}
					}						
				}
			}

			return fai;
		}
		
		private function getNextValidFragment(startIdx:uint, totalDuration:Number):FragmentAccessInformation
		{
			var fai:FragmentAccessInformation = null;
			for (var i:uint = startIdx; i < _fragmentDurationPairs.length; i++)
			{
				var fdp:FragmentDurationPair = _fragmentDurationPairs[i];
				if (fdp.duration > 0)
				{
					fai = new FragmentAccessInformation();
					fai.fragId = fdp.firstFragment;
					fai.fragDuration = fdp.duration;
					fai.fragmentEndTime = fdp.durationAccrued + fdp.duration;
					
					break;
				}
			}
			
			return fai;
		}
		
		private function endOfStreamEntry(fdp:FragmentDurationPair):Boolean
		{
			return (fdp.duration == 0 && fdp.discontinuityIndicator == 0);
		}
		
		/**
		 * Given a fragment id, return the number of fragments after the 
		 * fragment with the id given.
		 * 
		 * @return the number of fragments after the fragment with the id given.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function fragmentsLeft(fragId:uint, currentMediaTime:Number):uint
		{
			if (_fragmentDurationPairs == null || _fragmentDurationPairs.length == 0)
			{
				return 0;
			}
			
			var fdp:FragmentDurationPair = _fragmentDurationPairs[fragmentDurationPairs.length - 1] as FragmentDurationPair;
			var fragments:uint = (currentMediaTime - fdp.durationAccrued) / fdp.duration + fdp.firstFragment - fragId -1;
			
			return fragments;
		}		
		
		/**
		 * @return whether the fragment table is complete.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function tableComplete():Boolean
		{
			if (_fragmentDurationPairs == null || _fragmentDurationPairs.length <= 0)
			{
				return false;
			}
			
			var fdp:FragmentDurationPair = _fragmentDurationPairs[fragmentDurationPairs.length - 1] as FragmentDurationPair;
			return (fdp.duration == 0 && fdp.discontinuityIndicator == 0);
		}
		
		public function adjustEndEntryDurationAccrued(value:Number):void
		{
			var fdp:FragmentDurationPair = _fragmentDurationPairs[_fragmentDurationPairs.length - 1];
			if (fdp.duration == 0)
			{
				fdp.durationAccrued = value;
			}
		}
		
		public function getFragmentDuration(fragId:uint):Number
		{
			var fdp:FragmentDurationPair = null;
			var i:uint = 0;			
			while ((i<_fragmentDurationPairs.length) && (_fragmentDurationPairs[i].firstFragment <= fragId))
			{
				i++;
			}
			if (i)
				return _fragmentDurationPairs[i-1].duration;
			else
				return 0;
		}


		// Internal
		//
		
		private function findValidFragmentDurationPair(index:uint):FragmentDurationPair
		{
			for (var i:uint = index; index < _fragmentDurationPairs.length; i++)
			{
				var fdp:FragmentDurationPair = _fragmentDurationPairs[i];
				if (fdp.duration > 0)
				{
					return fdp;
				}
			}
			
			return null;
		}
		
		private function calculateFragmentId(fdp:FragmentDurationPair, time:Number):uint
		{
			if (fdp.duration <= 0)
			{
				return fdp.firstFragment;
			}
			
			var deltaTime:Number = time - fdp.durationAccrued;
			var count:uint = (deltaTime > 0)? deltaTime / fdp.duration : 1;
			if ((deltaTime % fdp.duration) > 0)
			{
				count++;
			}
			return fdp.firstFragment + count - 1;
		}

		private var _timeScale:uint;
		private var _qualitySegmentURLModifiers:Vector.<String>;
		private var _fragmentDurationPairs:Vector.<FragmentDurationPair>;
	}
}
