/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/

package org.osmf.net
{
	import flash.net.NetStream;

	/**
	 * @private
	 */
	internal class RunningAverage
	{
		public function RunningAverage(sampleCount:int)
		{
			this.sampleCount = sampleCount;
		}
		
		public function get average():Number
		{
			return _average;
		}
		
		public function addSample(value:Number):void
		{
			if (isNaN(value))
			{
				return;
			}
			
			samples.unshift(value);
			if (samples.length > sampleCount) 
			{
				samples.pop();
			}
			
			var total:Number = 0;				
			for (var b:uint = 0; b < samples.length; b++) 
			{
				total += samples[b];
			}				
			_average = total / samples.length;	
		}
		
		public function addDeltaTimeRatioSample(value:Number, time:Number):void
		{
			var timeDelta:Number = time - previousTimestamp;	
			if (timeDelta > 0)
			{
				addSample((value - previousValue) / timeDelta);
			}
			previousTimestamp = time;
			previousValue = value;
		}
		
		public function clearSamples():void
		{
			samples = new Array();
		}
		
		private var previousTimestamp:Number = NaN;
		private var previousValue:Number = NaN;
		private var samples:Array = new Array();
		private var sampleCount:int;
		private var _average:Number;
	}
}