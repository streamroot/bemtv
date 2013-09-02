/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
package org.osmf.net.rtmpstreaming
{
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	
	import org.osmf.net.NetStreamMetricsBase;
	import org.osmf.net.StreamType;
	
	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}
	
	/**
	 * RTMPNetStreamMetrics is a metrics provider for RTMP-based NetStreams.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class RTMPNetStreamMetrics extends NetStreamMetricsBase
	{
		/**
		 * Constructor.
		 * 
		 * @param netStream The NetStream to provide metrics for.
		 **/
		public function RTMPNetStreamMetrics(netStream:NetStream)
		{
			super(netStream);
			
			_averageMaxBytesPerSecondArray = new Array();
		}
		
		/**
		 * The average max bytes per second value, calculated based on a
		 * recent set of samples.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get averageMaxBytesPerSecond():Number
		{
			return _averageMaxBytesPerSecond;
		}

		/**
		 * @private
		 **/
		override protected function calculateMetrics():void 
		{
			super.calculateMetrics();
			
			try 
			{
				// Average maxBytesPerSecond
				var maxBytesPerSecond:Number = netStream.info.maxBytesPerSecond;
				_averageMaxBytesPerSecondArray.unshift(maxBytesPerSecond);
				if (_averageMaxBytesPerSecondArray.length > DEFAULT_AVG_MAX_BYTES_SAMPLE_SIZE) 
				{
					_averageMaxBytesPerSecondArray.pop();
				}
				var totalMaxBytesPerSecond:Number = 0;
				var peakMaxBytesPerSecond:Number = 0;
				
				for (var b:uint = 0; b < _averageMaxBytesPerSecondArray.length; b++) 
				{
					totalMaxBytesPerSecond += _averageMaxBytesPerSecondArray[b];
					peakMaxBytesPerSecond = _averageMaxBytesPerSecondArray[b] > peakMaxBytesPerSecond ? _averageMaxBytesPerSecondArray[b]: peakMaxBytesPerSecond;
				}
				
		 		// Flash player can have problems attempting to accurately estimate 
		 		// max bytes available with live streams. The server will buffer the 
		 		// content and then dump it quickly to the client. The client sees
		 		// this as an oscillating series of maxBytesPerSecond measurements,
		 		// where the peak roughly corresponds to the true estimate of max
		 		// bandwidth available.  When isLive is true, we optimize the estimated
		 		// averageMaxBytesPerSecond. 
				_averageMaxBytesPerSecond = _averageMaxBytesPerSecondArray.length < DEFAULT_AVG_MAX_BYTES_SAMPLE_SIZE ? 0 : isLive ? peakMaxBytesPerSecond : totalMaxBytesPerSecond / _averageMaxBytesPerSecondArray.length;
			}
			catch (error:Error) 
			{
				CONFIG::LOGGING
				{
					logger.debug(".calculateMetrics() - " + error);
				}
				throw(error);
			}
		}
		
		// Internals
		//
		
		private function get isLive():Boolean
		{
			return resource && resource.streamType == StreamType.LIVE;
		}
		
		private var _averageMaxBytesPerSecondArray:Array;
		private var _averageMaxBytesPerSecond:Number;

		private static const DEFAULT_AVG_MAX_BYTES_SAMPLE_SIZE:Number = 50;

		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics");
		}
	}
}