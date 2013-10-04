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
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	
	CONFIG::LOGGING
	{
	import org.osmf.logging.Log;
	import org.osmf.player.debug.StrobeLogger;
	}
	/**
	 * BufferManager is responsible for updating the bufferTime based on the NetStream events and 
	 * bandwidth versus video bitrate ratio.
	 */ 
	public class NetStreamBufferManagerBase
	{
		/**
		 * Constructor. Starts listening on the NetStream events.
		 */ 
		public function NetStreamBufferManagerBase(netStream:NetStream, metrics:PlaybackOptimizationMetrics)
		{
			this.netStream = netStream;
			this.metrics = metrics;
			
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}
		
		public function get expandedBufferTime():Number
		{
			return _expandedBufferTime;
		}
		
		public function set expandedBufferTime(value:Number):void
		{
			_expandedBufferTime = value;
		}
		
		public function get initialBufferTime():Number
		{
			return _initialBufferTime;
		}
		
		public function set initialBufferTime(value:Number):void
		{
			_initialBufferTime = value;
		}
		
		public function get minContinuousTime():Number
		{
			return _minContinuousTime;
		}
		
		public function set minContinuousTime(value:Number):void
		{
			_minContinuousTime = value;
		}
		
		public function computeBufferTime():Number
		{
			if (isNaN(metrics.downloadRatio) || metrics.downloadRatio > 1)
			{
				return NaN;
			}
			
			if (isNaN(metrics.duration - netStream.time))
			{
				return NaN;
			}
			
			var result:Number;
			// The bandwidth rate is smaller then the video bit rate. Let's wait a little bit longer but provide 
			// continuous playback for a specified interval.
			var continuousTime:Number = minContinuousTime;
			
			if (metrics.duration - netStream.time > 0)
			{
				// If the remaining time is smaller then the remaining video 
				// duration we'll set a smaller buffer size, and thus reduce the wait time.							
				continuousTime = Math.min(metrics.duration - netStream.time, continuousTime);	
			}
			
			// The expandedBufferTime will be computed to allow a continous playback
			var bufferComputedTime:Number = continuousTime*(1-metrics.downloadRatio);
			
			// Prevent the new buffer size from being smaller then the previous value of the bufferExpandedTime		
			bufferComputedTime = Math.max(netStream.bufferLength, bufferComputedTime);
			
			return bufferComputedTime;
		}
		
		// Protected
		//
		
		protected var netStream:NetStream;
		protected var metrics:PlaybackOptimizationMetrics;
		
		protected function onNetStatus(event:NetStatusEvent):void
		{
			switch (event.info.code) 
			{
				case NetStreamCodes.NETSTREAM_PLAY_START:
					if (!started)
					{
						// On PAUSE/RESUME the buffer is not reset, so don't update it.	
						// Set the initialBufferTime only for the first play event.
						netStream.bufferTime = initialBufferTime;
						started = true;		
					}				
					break;	
				case NetStreamCodes.NETSTREAM_SEEK_NOTIFY:
					// When seeking set a small bufferTime in the beginning to allow the user to see some of the content
					// before providing a bigger buffer for continuous playback. This should prevent the user from having 
					// to wait too long if he seeked to an undesired position.
					netStream.bufferTime = initialBufferTime;					
					break;	
				case NetStreamCodes.NETSTREAM_BUFFER_FULL:
					if (isNaN(metrics.downloadRatio) || metrics.downloadRatio > 1)
					{
						// For high or unknown downloadRatio simply set the buffer to the expandedBufferTime config setting.
						CONFIG::LOGGING
						{
						logger.info("ExpandedBuffer:. previousBufferTime={0} currentBufferTime={1}", netStream.bufferTime, expandedBufferTime);
						logger.qos.buffer.time = expandedBufferTime;
						}
						netStream.bufferTime = expandedBufferTime;
						break;
					}
				case NetStreamCodes.NETSTREAM_BUFFER_EMPTY:					
					
					// On buffer empty we will compute a dynamic buffer time based on bandwidth measurement.
					var bufferComputedTime:Number = computeBufferTime();
					if (bufferComputedTime > 0 && bufferComputedTime != netStream.bufferTime)
					{
						CONFIG::LOGGING
						{
						logger.info("DynamicBuffer: previousBufferTime={0} currentBufferTime={1}", netStream.bufferTime, bufferComputedTime);
						logger.qos.buffer.time = bufferComputedTime;
						}
						netStream.bufferTime = bufferComputedTime;						
					}
					break;
			}			
		}
		
		// Internals
		//
		
		private var _initialBufferTime:Number = 1;		
		private var _expandedBufferTime:Number = 10;	
		private var _minContinuousTime:Number = 30;
		
		private var started:Boolean = false;
		
		CONFIG::LOGGING
		{
		private var logger:StrobeLogger = Log.getLogger("StrobeMediaPlayback") as StrobeLogger;
		}
	}
}