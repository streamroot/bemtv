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
	import flash.net.SharedObject;
	import flash.system.System;
	
	import org.osmf.player.utils.StrobeUtils;
	
	CONFIG::LOGGING
	{
	import org.osmf.logging.Log;
	import org.osmf.player.debug.StrobeLogger;
	}
	
	public class PlaybackOptimizationMetrics extends NetStreamMetricsBase
	{
		public static const ID:String = "PlaybackOptimizationMetrics";
		
		/**
		 * Constructor.
		 * 
		 * @param netStream The NetStream to provide metrics for.
		 **/
		public function PlaybackOptimizationMetrics(netStream:NetStream)
		{
			super(netStream);
			// Retrieve the metadata from the NetStream
			NetClient(netStream.client).addHandler(NetStreamCodes.ON_META_DATA, onMetaData);
			function onMetaData(value:Object):void
			{
				NetClient(netStream.client).removeHandler(NetStreamCodes.ON_META_DATA, onMetaData);
				// We assume that the asset metadata has the most accurate value,
				// that's why we overwrite any existing value.
				
				// audiodatarate and videodatarate are set in kilobits. We need to transform it to bytes. 
				averagePlaybackBytesPerSecond = StrobeUtils.kbitsPerSecond2BytesPerSecond(value.audiodatarate + value.videodatarate);			
				duration = value.duration;
			}
			
			try
			{
				var sharedObject:SharedObject = SharedObject.getLocal(STROBE_LSO_NAMESPACE);
				averageDownloadBytesPerSecond = StrobeUtils.kbitsPerSecond2BytesPerSecond(sharedObject.data.downloadKbitsPerSecond);
				CONFIG::LOGGING
				{
					logger.qos.lsoDownloadKbps = sharedObject.data.downloadKbitsPerSecond;
				}
			}
			catch(ignore: Error)
			{
				// Ignore this error
				CONFIG::LOGGING
				{
					logger.info("LSO access is disabled.");
				}
			}
			
			// Register a NET_STATUS handler, so that we update the local SharedObject with the new bandwidth measurement.
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			function onNetStatus(event:NetStatusEvent):void
			{	
				if (event.info.code == NetStreamCodes.NETSTREAM_PLAY_STOP || event.info.code == NetStreamCodes.NETSTREAM_PAUSE_NOTIFY) 
				{
					if (averageDownloadBytesPerSecond > 0)
					{
						try 
						{							
							// Update the Local SharedObject with the latest bandwidth measurement.
							var sharedObject:SharedObject = SharedObject.getLocal(STROBE_LSO_NAMESPACE);
							sharedObject.data.downloadKbitsPerSecond = Math.round(StrobeUtils.bytesPerSecond2kbitsPerSecond(averageDownloadBytesPerSecond));
							sharedObject.flush(10000);
							CONFIG::LOGGING
							{
								logger.qos.lsoDownloadKbps = sharedObject.data.downloadKbitsPerSecond;
							}
						} 
						catch (ingore:Error) 
						{
							// Ignore this error
							CONFIG::LOGGING
							{
								logger.info("lsoDownloadKbps value is not updated since LSO access is disabled.");
							}
						}
					}
				}
			}
		}
		
		public function get duration():Number
		{
			return _duration;
		}

		public function set duration(value:Number):void
		{
			_duration = value;
		}

		/**
		 * The average download ration per second value, calculated based on a
		 * recent set of samples.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get downloadRatio():Number
		{
			return averageDownloadBytesPerSecond / averagePlaybackBytesPerSecond;
		}
		
		/**
		 * The average playback bytes per second value, calculated based on a
		 * recent set of samples.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get averagePlaybackBytesPerSecond():Number
		{
			return avgPlaybackBytesPerSecond.average;
		}
		
		public function set averagePlaybackBytesPerSecond(value:Number):void
		{
			avgPlaybackBytesPerSecond.clearSamples();
			avgPlaybackBytesPerSecond.addSample(value);
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
		public function get averageDownloadBytesPerSecond():Number
		{
			return avgMaxBytesPerSecond.average;
		}
		
		public function set averageDownloadBytesPerSecond(value:Number):void
		{
			avgPlaybackBytesPerSecond.clearSamples();
			return avgMaxBytesPerSecond.addSample(value);
		}
		
		public function get averageDownloadKbps():Number
		{
			return averageDownloadBytesPerSecond  / 128;
		}
		
		public function get averagePlaybackKbps():Number
		{
			return averagePlaybackBytesPerSecond / 128;
		}

		/**
		 * @private
		 **/
		override protected function calculateMetrics():void 
		{
			super.calculateMetrics();	
			// XXX cdobre - this needs to be refactored in order 
			// to eliminate the dynamic dependency on property name
			if (netStream.hasOwnProperty("qosInfo") && netStream["qosInfo"] != null)
			{				
				// HTTPStreaming content. 
				if (netStream.info.videoBufferLength > 0)
				{
					avgPlaybackBytesPerSecond.addSample(netStream.info.videoBufferByteLength / netStream.info.videoBufferLength);
				}
				maxBytesPerSecond = netStream["qosInfo"]["downloadRatio"] * netStream.info.videoBufferByteLength / netStream.info.videoBufferLength;
				if (maxBytesPerSecond > 0)
				{
					avgMaxBytesPerSecond.addSample(maxBytesPerSecond);
				}
			}
			else
			{			
				if (netStream.bytesLoaded > 0 ) 
				{				
					// Progressive content
					if (netStream.bytesLoaded < netStream.bytesTotal)
					{
						if (netStream.info.videoBufferLength > 0)
						{
							avgPlaybackBytesPerSecond.addSample(netStream.info.videoBufferByteLength / netStream.info.videoBufferLength);
						}
						avgMaxBytesPerSecond.addDeltaTimeRatioSample(netStream.bytesLoaded, new Date().time / 1000);
					}
				}
				else
				{ 
					// RTMP Content
					var playbackBytesPerSecond:Number = netStream.info.playbackBytesPerSecond;
					var maxBytesPerSecond:Number = netStream.info.maxBytesPerSecond;
					if (playbackBytesPerSecond > 0)
					{
						avgPlaybackBytesPerSecond.addSample(playbackBytesPerSecond);
					}
				
					if (maxBytesPerSecond > 0)
					{
						avgMaxBytesPerSecond.addSample(maxBytesPerSecond);
					}
				}				
			}
			
			CONFIG::LOGGING
			{
			logger.qos.duration = _duration;
			
			logger.qos.downloadRatio = this.downloadRatio;
			logger.qos.playbackKbps  = this.averagePlaybackBytesPerSecond / 128;
			logger.qos.downloadKbps  = this.averageDownloadBytesPerSecond / 128;
			logger.qos.avgDroppedFPS = averageDroppedFPS;

			logger.trackObject("PlaybackOptimizationMetrics", this);
			}
		}
		
		// Internals
		//		
		private var _duration:Number;

		private var avgPlaybackBytesPerSecond:RunningAverage = new RunningAverage(DEFAULT_AVG_MAX_BYTES_SAMPLE_SIZE);
		private var avgMaxBytesPerSecond:RunningAverage = new RunningAverage(DEFAULT_AVG_MAX_BYTES_SAMPLE_SIZE);

		private var previousMeasurementTimestamp:Number = NaN;
		private static const DEFAULT_AVG_MAX_BYTES_SAMPLE_SIZE:Number = 50;	
		
		private const STROBE_LSO_NAMESPACE:String = "org.osmf.strobemediaplayback.lso";
	
		CONFIG::LOGGING		
		private var logger:StrobeLogger = Log.getLogger("StrobeMediaPlayback") as StrobeLogger;
		
	}
}