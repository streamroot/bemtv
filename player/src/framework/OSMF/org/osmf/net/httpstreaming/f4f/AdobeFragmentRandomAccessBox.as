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
	 * This is the fragment random access box data structure.
	 */	
	internal class AdobeFragmentRandomAccessBox extends FullBox
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function AdobeFragmentRandomAccessBox()
		{
			super();
		}
		
		/**
		 * It is the number of time units in one second which the currentMediaTime and smpteTimeCodeOffset
		 * use to represent time. By default, 1000 is for milliseconds.
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
		 * The list of local access entries for this fragment.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get localRandomAccessEntries():Vector.<LocalRandomAccessEntry>
		{
			return _localRandomAccessEntries;
		}

		public function set localRandomAccessEntries(value:Vector.<LocalRandomAccessEntry>):void
		{
			_localRandomAccessEntries = value;
		}

		/**
		 * The list of global access entries for this fragment.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get globalRandomAccessEntries():Vector.<GlobalRandomAccessEntry>
		{
			return _globalRandomAccessEntries;
		}
		
		public function set globalRandomAccessEntries(value:Vector.<GlobalRandomAccessEntry>):void
		{
			_globalRandomAccessEntries = value;
		}

		/**
		 * Given a seekTime, return the offset of the key frame that is nearest from the 
		 * left. This is done among localRandomAccessEntries only. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function findNearestKeyFrameOffset(seekToTime:Number):LocalRandomAccessEntry
		{
			var i:int = _localRandomAccessEntries.length - 1;
			while (i >= 0)
			{
				var entry:LocalRandomAccessEntry = _localRandomAccessEntries[i];
				if (entry.time <= seekToTime)
				{
					return entry
				}
				
				i--;
			}
			
			return null;
		}

		// Internal
		//
				
		private var _timeScale:uint;
		private var _localRandomAccessEntries:Vector.<LocalRandomAccessEntry>;
		private var _globalRandomAccessEntries:Vector.<GlobalRandomAccessEntry>;
	}
}