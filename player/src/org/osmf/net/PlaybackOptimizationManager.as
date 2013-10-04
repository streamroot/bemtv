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
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.events.UpdateCompleteEvent;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.player.chrome.utils.MediaElementUtils;
	import org.osmf.player.configuration.PlayerConfiguration;
	import org.osmf.player.media.VideoElementRegistry;
	import org.osmf.player.metadata.MediaMetadata;
	import org.osmf.player.utils.StrobeUtils;

	CONFIG::LOGGING
	{
		import org.osmf.player.debug.StrobeLogger;
		import org.osmf.logging.Log;
	}
	
	/**
	 * PlaybackOptimizationManager is responsible for optimizing the playback experience
	 * based on a set of metrics.
	 * Both BufferManagement and the DynamicStreaming management should be handled in a holistic way 
	 * since both these aspects should aim at providing the best possible playback experience.
	 */ 
	public class PlaybackOptimizationManager
	{
		/**
		 * Constructor
		 */ 
		public function PlaybackOptimizationManager(configuration:PlayerConfiguration)		{
			this.configuration = configuration;
		}
		
		public function get downloadBytesPerSecond():Number
		{
			return _downloadBytesPerSecond;
		}
			
		public function set downloadBytesPerSecond(value:Number):void
		{
			_downloadBytesPerSecond = value;
		}

		/**
		 * Optimizes the playback experience by adjusting the buffer times or initial index of a DynamicStreamingResource.
		 */ 
		public function optimizePlayback(connection:NetConnection, netStream:NetStream, dsResource:DynamicStreamingResource):void
		{
			// Don't optimize anything for LIVE or DVR content.
			var videoElement:VideoElement = VideoElementRegistry.getInstance().retriveMediaElementByNetStream(netStream);
			
			
			
			if (videoElement != null)
			{
				var streamType:String = MediaElementUtils.getStreamType(videoElement);
				
				var mediaMetadata:MediaMetadata = videoElement.metadata.getValue(MediaMetadata.ID);
				if (mediaMetadata == null)
				{
					mediaMetadata = new MediaMetadata();
					videoElement.metadata.addValue(MediaMetadata.ID, mediaMetadata)
				}
				
				CONFIG::LOGGING
				{
					logger.qos.streamType = streamType;
				} 
				if (dsResource == null && (streamType == StreamType.LIVE || streamType == StreamType.DVR))
				{
					CONFIG::LOGGING
					{
						logger.info("The buffer is not optimized for the streamType={0}.", streamType);
					} 
					return;
				}
				else if (dsResource != null)
				{
					dsResource.addMetadataValue("streamType", streamType);
				}
			}
			
			// For recorded media we optimize the buffer size or 
			// the initial index for Dynamic Streaming based on the 
			// measured bandwidth.
			var metrics:PlaybackOptimizationMetrics = createPlaybackOptimizationMetrics(netStream);
			if (!isNaN(downloadBytesPerSecond))
			{
				metrics.averageDownloadBytesPerSecond = downloadBytesPerSecond;
			}
			else
			{
				downloadBytesPerSecond = metrics.averageDownloadBytesPerSecond;
			}
			
			if (dsResource == null)
			{
				if (configuration.optimizeBuffering)
				{
					// Don't use DynamicBuffering on DynamicStreaming content.				
					createBufferManager(netStream, metrics);	
				}
			}
			else
			{
				if (configuration.optimizeInitialIndex)
				{
					// We are able to start from the best stream for the current network conditions based on previous measurements.
					if (!isNaN(downloadBytesPerSecond))
					{
						updateInitialIndex(dsResource, downloadBytesPerSecond);
					}
				}
			}
		}
		
		// Protected
		//
		
		/**
		 *  The factory function for creating a PlaybackOptimizationMetrics.
		 */ 
		protected function createPlaybackOptimizationMetrics(netStream:NetStream):PlaybackOptimizationMetrics
		{
			return new PlaybackOptimizationMetrics(netStream);
		}
		
		/**
		 *  The factory function for creating a NetStreamBufferManagerBase.
		 */
		protected function createBufferManager(netStream:NetStream, metrics:PlaybackOptimizationMetrics):NetStreamBufferManagerBase
		{
			var netStreamBufferManager:NetStreamBufferManagerBase;
			netStreamBufferManager = new NetStreamBufferManagerBase(netStream, metrics);
			netStreamBufferManager.initialBufferTime = configuration.initialBufferTime;
			netStreamBufferManager.expandedBufferTime = configuration.expandedBufferTime;
			netStreamBufferManager.minContinuousTime = configuration.minContinuousPlaybackTime;
			return netStreamBufferManager;
		}
		
		/**
		 * Updates the initial index of a DynamicStreamingResource based on a previous set of metrics.
		 */ 
		protected function updateInitialIndex(dsResource:DynamicStreamingResource, averageDownloadBytesPerSecond:Number):void
		{
			var initialIndex:int = -1;
			var downloadBitrate:Number =  StrobeUtils.bytesPerSecond2kbitsPerSecond(averageDownloadBytesPerSecond);
			for each(var streamItem:DynamicStreamingItem in dsResource.streamItems)
			{
				if (streamItem.bitrate <= downloadBitrate)
				{
					initialIndex++;
				}
			}
			
			// The lowest quality is lower then the bandwidth, start with the lowest bitrate anyway.
			if (initialIndex < 0)
			{
				initialIndex = 0;
			}
			CONFIG::LOGGING
			{
				logger.info("Setting the initial index to: " + initialIndex);
			} 
			dsResource.initialIndex = initialIndex;
		}
		
		// Internals
		//
		
		private const bitrateMultiplier:Number = 1.15;
		private var configuration:PlayerConfiguration;
		private var _downloadBytesPerSecond:Number = NaN;
		private var _connection:NetConnection;
		
		CONFIG::LOGGING
		{
		protected var logger:StrobeLogger = Log.getLogger("StrobeMediaPlayback") as StrobeLogger;
		}
	}
}