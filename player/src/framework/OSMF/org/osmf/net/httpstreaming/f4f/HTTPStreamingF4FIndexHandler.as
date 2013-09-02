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
	
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import org.osmf.elements.f4mClasses.BootstrapInfo;
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.events.HTTPStreamingFileHandlerEvent;
	import org.osmf.events.HTTPStreamingIndexHandlerEvent;
	import org.osmf.net.dvr.DVRUtils;
	import org.osmf.net.httpstreaming.HTTPStreamRequest;
	import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase;
	import org.osmf.net.httpstreaming.HTTPStreamingUtils;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataMode;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
	import org.osmf.utils.OSMFSettings;

	CONFIG::LOGGING 
	{	
		import org.osmf.logging.Logger;
	}

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The actual implementation of HTTPStreamingFileIndexHandlerBase.  It
	 * handles the indexing scheme of an F4V file.
	 */	
	public class HTTPStreamingF4FIndexHandler extends HTTPStreamingIndexHandlerBase
	{
		/**
		 * Default Constructor.
		 *
		 * @param fileHandler The associated file handler object which is responsable for processing the actual data.
		 * 					  We need this object as it may process bootstrap information found into the stream.
		 * @param fragmentsThreshold The default threshold for fragments.   
		 */
		public function HTTPStreamingF4FIndexHandler(fileHandler:HTTPStreamingFileHandlerBase, fragmentsThreshold:uint = DEFAULT_FRAGMENTS_THRESHOLD)
		{
			super();
			
			// listen for any bootstrap box information dispatched by file handler
			fileHandler.addEventListener(HTTPStreamingFileHandlerEvent.NOTIFY_BOOTSTRAP_BOX, onBootstrapBox);
		}
		
		/**
		 * @private
		 */
		override public function dvrGetStreamInfo(indexInfo:Object):void
		{
			_invokedFromDvrGetStreamInfo = true;
			playInProgress = false;
			initialize(indexInfo);
		} 
		
		/**
		 * Initializes the index handler.
		 * 
		 * @param indexInfor The index information.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		override public function initialize(indexInfo:Object):void
		{
			// Make sure we have an info object of the expected type.
			_f4fIndexInfo = indexInfo as HTTPStreamingF4FIndexInfo;
			if (_f4fIndexInfo == null || _f4fIndexInfo.streamInfos == null || _f4fIndexInfo.streamInfos.length <= 0)
			{
				CONFIG::LOGGING
				{			
					logger.error("indexInfo object wrong or contains insufficient information!");
				}
				
				dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
				return;					
			}
			
			_indexUpdating = false;
			_pendingIndexLoads = 0;
			_pendingIndexUpdates = 0;
			_pendingIndexUrls = new Object();
			
			playInProgress = false;
			_pureLiveOffset = NaN;

			_serverBaseURL = _f4fIndexInfo.serverBaseURL;			
			_streamInfos = _f4fIndexInfo.streamInfos;

			var bootstrapBox:AdobeBootstrapBox;
			var streamCount:int = _streamInfos.length;
			
			_streamQualityRates = [];
			_streamNames = [];
			
			_bootstrapBoxesURLs = new Vector.<String>(streamCount);
			_bootstrapBoxes = new Vector.<AdobeBootstrapBox>(streamCount);
			for (var quality:int = 0; quality < streamCount; quality++)
			{
				var streamInfo:HTTPStreamingF4FStreamInfo = _streamInfos[quality];
				if (streamInfo != null)
				{
					_streamQualityRates[quality]	= streamInfo.bitrate;
					_streamNames[quality] 			= streamInfo.streamName;
					
					var bootstrap:BootstrapInfo = streamInfo.bootstrapInfo;
					
					if (bootstrap == null || (bootstrap.url == null && bootstrap.data == null))
					{
						CONFIG::LOGGING
						{			
							logger.error("Bootstrap(" + quality + ")  null or contains inadequate information!");
						}
						
						dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
						return;					
					}
					
					if (bootstrap.data != null)
					{
						bootstrapBox = processBootstrapData(bootstrap.data, quality);
						if (bootstrapBox == null)
						{
							CONFIG::LOGGING
							{			
								logger.error("BootstrapBox(" + quality + ") is null, potentially from bad bootstrap data!");
							}
							
							dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
							return;					
						}
						_bootstrapBoxes[quality] = bootstrapBox;
					}
					else
					{
						_bootstrapBoxesURLs[quality] 	= HTTPStreamingUtils.normalizeURL(bootstrap.url);
						
						_pendingIndexLoads++;
						dispatchIndexLoadRequest(quality);
					}
				}
			}
			
			if (_pendingIndexLoads == 0)
			{
				notifyRatesReady();
				notifyIndexReady(0);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			//close the bootstrap update timer
			destroyBootstrapUpdateTimer();
		}
		
		/**
		 * Called when the index file has been loaded and is ready to be processed.
		 * 
		 * @param data The data from the loaded index file.
		 * @param indexContext An arbitrary context object which describes the loaded
		 * index file.  Useful for index handlers which load multiple index files
		 * (and thus need to know which one to process).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override public function processIndexData(data:*, indexContext:Object):void
		{
			var quality:int = indexContext as int;
			var bootstrapBox:AdobeBootstrapBox = processBootstrapData(data, quality);

			if (bootstrapBox == null)
			{
				CONFIG::LOGGING
				{			
					logger.error("BootstrapBox(" + quality + ") is null when attempting to process index data during a bootstrap update.");
				}
				
				dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
				return;					
			}

			if (!_indexUpdating) 
			{
				// we are processing an index initialization
				_pendingIndexLoads--;

				CONFIG::LOGGING
				{			
					logger.debug("Pending index loads: " + _pendingIndexLoads);
				}
			}
			else
			{
				// we are processing an index update
				_pendingIndexUpdates--;

				CONFIG::LOGGING
				{			
					logger.debug("Pending index updates: " + _pendingIndexUpdates);
				}

				var requestedUrl:String = _bootstrapBoxesURLs[quality];
				if (requestedUrl != null && _pendingIndexUrls.hasOwnProperty(requestedUrl))
				{
					_pendingIndexUrls[requestedUrl].active = false;
				}
				
				if (_pendingIndexUpdates == 0)
				{
					_indexUpdating = false;
					// FM-924, onMetadata is called twice on http streaming live/dvr content 
					// It is really unnecessary to call onMetadata multiple times. The change of
					// media length is fixed for VOD, and is informed by the call dispatchDVRStreamInfo
					// for DVR. For "pure live", it does not really matter. Whenever MBR switching
					// happens, onMetadata will be called by invoking checkMetadata method.
					// 
					//notifyTotalDuration(bootstrapBox.totalDuration / bootstrapBox.timeScale, indexContext as int);
				}
			}
			
			CONFIG::LOGGING
			{			
				logger.debug("BootstrapBox(" + quality + ") loaded successfully." + 
					"[version:" + bootstrapBox.bootstrapVersion + 
					", fragments from frt:" + bootstrapBox.totalFragments +
					", fragments from srt:" + bootstrapBox.segmentRunTables[0].totalFragments + "]"
				);
			}
			updateBootstrapBox(quality, bootstrapBox);
			
			if (_pendingIndexLoads == 0 && !_indexUpdating)
			{
				notifyRatesReady();
				notifyIndexReady(quality);
			}
		}	
		
		/**
		 * Returns the HTTPStreamRequest which encapsulates the file for the given
		 * playback time and quality.  If no such file exists for the specified time
		 * or quality, then this method should return null. 
		 * 
		 * @param time The time for which to retrieve a request object.
		 * @param quality The quality of the requested stream.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		override public function getFileForTime(time:Number, quality:int):HTTPStreamRequest
		{
			if (   quality < 0 
				|| quality >= _streamInfos.length 
				|| time < 0)
			{
				CONFIG::LOGGING
				{
					logger.warn("Invalid parameters for getFileForTime(time=" + time + ", quality=" + quality + ").");	
				}
				return null;
			}
				
			var bootstrapBox:AdobeBootstrapBox = _bootstrapBoxes[quality];
			if (bootstrapBox == null)
				return null;
			
			if (!playInProgress && isStopped(bootstrapBox))
			{
				destroyBootstrapUpdateTimer();
				return null;
			}
							
			updateMetadata(quality);
			
			var refreshNeeded:Boolean = false;
			var streamRequest:HTTPStreamRequest = null;
			
			var currentTime:Number = bootstrapBox.currentMediaTime;
			var desiredTime:Number = time * bootstrapBox.timeScale;
			if (desiredTime <= currentTime)
			{
				// we should know the segment and fragment containing the desired time
				var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
				if (frt != null)
				{
					_currentFAI = frt.findFragmentIdByTime(desiredTime, currentTime, bootstrapBox.contentComplete() ? false : bootstrapBox.live);
				}
				
				if (_currentFAI == null || fragmentOverflow(bootstrapBox, _currentFAI.fragId))
				{
					if (bootstrapBox.contentComplete())
					{
						if (bootstrapBox.live) // live/DVR playback stops
						{
							streamRequest = new HTTPStreamRequest(null, quality, -1, -1, true);
						}
					}
					else
					{
						refreshNeeded = true;
					}
				}
				else
				{
					playInProgress = true;
					
					streamRequest = new HTTPStreamRequest(getFragmentUrl(quality, _currentFAI));
					updateQuality(quality);
					notifyFragmentDuration(_currentFAI.fragDuration / bootstrapBox.timeScale);
				}
			}
			else
			{
				// we are trying to get pass the known "live" point
				// if we are in a live scenario we should refresh the bootstrap
				// and retry
				refreshNeeded = bootstrapBox.live;
			}

			if (refreshNeeded)
			{
				adjustDelay();
				refreshBootstrapBox(quality);
				streamRequest = new HTTPStreamRequest(null, quality, 0, _delay);
			}
			
			CONFIG::LOGGING
			{
				if (streamRequest == null)
				{
					logger.debug("The url for ( time=" + time + ", quality=" + quality + ") = none.");
				}
				else
				{
					logger.debug("The url for ( time=" + time + ", quality=" + quality + ") = " + streamRequest.toString());
				}
			}
			
			return streamRequest;
		}
		
		/**
		 * @private
		 */
		override public function getNextFile(quality:int):HTTPStreamRequest
		{
			if (quality < 0 || quality >= _streamInfos.length)
			{
				CONFIG::LOGGING
				{
					logger.warn("Invalid parameters for getNextFile(quality=" + quality + ").");	
				}
				return null;
			}
			
			var bootstrapBox:AdobeBootstrapBox = _bootstrapBoxes[quality];
			if (bootstrapBox == null)
				return null;
			
			if (!playInProgress && isStopped(bootstrapBox))
			{
				destroyBootstrapUpdateTimer();
				return null;
			}
			
			updateMetadata(quality);
			
			var refreshNeeded:Boolean = false;
			var streamRequest:HTTPStreamRequest = null;

			var currentTime:Number = bootstrapBox.currentMediaTime;
			var oldCurrentFAI:FragmentAccessInformation = _currentFAI;
			if (oldCurrentFAI == null)
			{
				_currentFAI = null;
			}
			else
			{
				var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
				if (frt != null)
				{
					_currentFAI = frt.validateFragment(oldCurrentFAI.fragId + 1, currentTime, bootstrapBox.contentComplete()? false : bootstrapBox.live);
				}
			}
			
			if (_currentFAI == null || fragmentOverflow(bootstrapBox, _currentFAI.fragId))
			{
				if (!bootstrapBox.live || bootstrapBox.contentComplete())
				{
					if (bootstrapBox.live) // live/DVR playback stops
					{
						return new HTTPStreamRequest(null, quality, -1, -1, true);
					}
					else
					{
						return null;
					}
				}
				else
				{
					_currentFAI = oldCurrentFAI;
					refreshNeeded = true;
				}
			}
			else
			{
				playInProgress = true;
				
				streamRequest = new HTTPStreamRequest(getFragmentUrl(quality, _currentFAI));
				updateQuality(quality);
				notifyFragmentDuration(_currentFAI.fragDuration / bootstrapBox.timeScale);
			}
			
			if (refreshNeeded)
			{
				adjustDelay();
				refreshBootstrapBox(quality);
				streamRequest = new HTTPStreamRequest(null, quality, 0, _delay);
			}
			
			CONFIG::LOGGING
			{
				if (streamRequest == null)
				{
					logger.debug("Next url for (quality=" + quality + ") = none.");
				}
				else
				{
					logger.debug("Next url for (quality=" + quality + ") = " + streamRequest.toString());
				}
			}
			
			return streamRequest;
		}
		
		/// Internals
		
		/**
		 * Checks if specified fragment identifier overflows the actual 
		 * fragments contained into the bootstrap.
		 * 
		 * @param  bootstrapBox The bootstrap which contains the fragment run table.
		 * @param fragId Specified fragment identifier which must be checked.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		private function fragmentOverflow(bootstrapBox:AdobeBootstrapBox, fragId:uint):Boolean
		{
			var fragmentRunTable:AdobeFragmentRunTable = bootstrapBox.fragmentRunTables[0];
			var fdp:FragmentDurationPair = fragmentRunTable.fragmentDurationPairs[0];
			var segmentRunTable:AdobeSegmentRunTable = bootstrapBox.segmentRunTables[0];
			return ((segmentRunTable == null) || ((segmentRunTable.totalFragments + fdp.firstFragment - 1) < fragId));
		}

		/**
		 * Checks if there is no more data available for a specified
		 * bootstrap and if we should stop playback.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		private function isStopped(bootstrapBox:AdobeBootstrapBox):Boolean
		{
			var result:Boolean = false;
			
			if (_f4fIndexInfo.dvrInfo != null)
			{
				// in DVR scenario, the content is considered stopped once the dvr 
				// data is taken offline
				result = _f4fIndexInfo.dvrInfo.offline;
			}
			else if (bootstrapBox != null && bootstrapBox.live)
			{
				// in pure live, the content is considered stopped once the 
				// fragment run table reports complete flag is set
				var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
				if (frt != null)
				{
					result = frt.tableComplete();
				}
			}
						
			return result;
		}
		
		/**
		 * Gets the url for specified fragment and quality.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		private function getFragmentUrl(quality:int, fragment:FragmentAccessInformation):String
		{
			var bootstrapBox:AdobeBootstrapBox = _bootstrapBoxes[quality];
			var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
			var fdp:FragmentDurationPair = frt.fragmentDurationPairs[0];
			var segId:uint = bootstrapBox.findSegmentId(fragment.fragId - fdp.firstFragment + 1);
			
			var requestUrl:String = "";
			if (_streamNames[quality].indexOf("http") != 0)
			{
				requestUrl = _serverBaseURL + "/" ;
			}
			requestUrl += _streamNames[quality] + "Seg" + segId + "-Frag" + fragment.fragId;

			return requestUrl;
		}
		
		/**
		 * Returns the fragment run table from the specified bootstrap box.
		 * It assumes that there is only one fragment run table.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		private function getFragmentRunTable(bootstrapBox:AdobeBootstrapBox):AdobeFragmentRunTable
		{
			if (bootstrapBox == null)
				return null;
			
			return bootstrapBox.fragmentRunTables[0];
		}

		/**
		 * Adjusts the delay for future inquires from clients.
		 * When the index handler needs more time to obtain data in order to
		 * respond to a request from its clients, it will return a response 
		 * requesting more time. This method varies the delay.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function adjustDelay():void
		{
			if (_delay < 1.0)
			{
				_delay = _delay * 2.0;
				if (_delay > 1.0)
				{
					_delay = 1.0;
				} 
			}
		}

		/**
		 * Issues a request for refreshing the specified quality bootstrap.
		 *
		 * @param quality Quality level for which a refresh should be requested.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		private function refreshBootstrapBox(quality:uint):void
		{
			var requestedUrl:String = _bootstrapBoxesURLs[quality];
			if (requestedUrl == null)
				return;
			
			var pendingIndexUrl:Object = null;
			if (_pendingIndexUrls.hasOwnProperty(requestedUrl))
			{
				pendingIndexUrl = _pendingIndexUrls[requestedUrl];
			}
			else
			{
				pendingIndexUrl = new Object();
				pendingIndexUrl["active"] = false;
				pendingIndexUrl["date"] = null;
				_pendingIndexUrls[requestedUrl] = pendingIndexUrl;
			}

			var ignoreRefreshRequest:Boolean = pendingIndexUrl.active;
			var newRequestDate:Date = new Date();
			var elapsedTime:Number = 0;
			
			if (!ignoreRefreshRequest && OSMFSettings.hdsMinimumBootstrapRefreshInterval > 0)
			{
				var previousRequestDate:Date = pendingIndexUrl["date"];
				elapsedTime = Number.MAX_VALUE;
				if (previousRequestDate != null)
				{
					elapsedTime = newRequestDate.valueOf() - previousRequestDate.valueOf();
				}
				
				ignoreRefreshRequest = elapsedTime < OSMFSettings.hdsMinimumBootstrapRefreshInterval;
			}
			
			if (!ignoreRefreshRequest)
			{
				_pendingIndexUrls[requestedUrl].date = newRequestDate;
				_pendingIndexUrls[requestedUrl].active = true;
				_pendingIndexUpdates++;
				_indexUpdating = true;
				
				CONFIG::LOGGING
				{
					logger.debug("Refresh (quality=" + quality + ") using " + requestedUrl + ". [active=" + pendingIndexUrl.active + ", elapsedTime=" + elapsedTime.toFixed(2) + "]");
				}
				
				dispatchIndexLoadRequest(quality);
			}
			else
			{
				CONFIG::LOGGING
				{
					logger.debug("Refresh (quality=" + quality + ") ignored. [active=" + pendingIndexUrl.active + ", elapsedTime=" + elapsedTime.toFixed(2) + "]");
				}
			}
		}

		/**
		 * Updates the specified bootstrap box if the specified information
		 * is newer than the current one. If the updated box if the current one, 
		 * it also refreshes the associated DVR information.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function updateBootstrapBox(quality:int, bootstrapBox:AdobeBootstrapBox):void
		{
			if (   _bootstrapBoxes[quality] == null 
				|| _bootstrapBoxes[quality].bootstrapVersion < bootstrapBox.bootstrapVersion 
				|| _bootstrapBoxes[quality].currentMediaTime < bootstrapBox.currentMediaTime
			)
			{
				CONFIG::LOGGING
				{
					logger.debug("Bootstrap information for quality[" + quality + "] updated. (version=" + bootstrapBox.bootstrapVersion + ", time=" + bootstrapBox.currentMediaTime + ")");
				}
				_bootstrapBoxes[quality] = bootstrapBox;
				_delay = 0.05;
				if (quality == _currentQuality)
				{
					dispatchDVRStreamInfo(bootstrapBox);
				}
			}
		}
		
		/**
		 * Processes bootstrap raw information and returns an AdobeBootstrapBox object.
		 * 
		 * @param data The raw representation of bootstrap.
		 * @param indexContext The index context used while processing bootstrap.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function processBootstrapData(data:*, indexContext:Object):AdobeBootstrapBox
		{
			var parser:BoxParser = new BoxParser();
			data.position = 0;
			parser.init(data);
			try
			{
				var boxes:Vector.<Box> = parser.getBoxes();
			}
			catch (e:Error)
			{
				boxes = null;
			}
			
			if (boxes == null || boxes.length < 1)
			{
				return null;
			}
			
			var bootstrapBox:AdobeBootstrapBox = boxes[0] as AdobeBootstrapBox;
			if (bootstrapBox == null)
			{
				return null;
			}
			
			if (_serverBaseURL == null || _serverBaseURL.length <= 0)
			{
				if (bootstrapBox.serverBaseURLs == null || bootstrapBox.serverBaseURLs.length <= 0)
				{
					// If serverBaseURL is not set from the external, we need to pick 
					// a server base URL from the bootstrap box. For now, we just
					// pick the first one. It is an error if the server base URL is null 
					// under this circumstance.
					return null;
				}
				
				_serverBaseURL = bootstrapBox.serverBaseURLs[0];
			}
			
			return bootstrapBox;
		}	

		/**
		 * Updates the current quality index. 
		 * 
		 * Also in MBR scenarios with protected content we need to append the additionalHeader 
		 * that contains the DRM metadata to the Flash Player for that fragment before any 
		 * additional TCMessage.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function updateQuality(quality:int):void
		{
			if (quality != _currentQuality)
			{
				// we preserve this for later comparison
				var prevAdditionalHeader:ByteArray = _currentAdditionalHeader;
				var newAdditionalHeader:ByteArray = _streamInfos[quality].additionalHeader;

				CONFIG::LOGGING
				{
					logger.debug("Quality changed from " + _currentQuality + " to " +  quality + ".");
				}
				_currentQuality = quality;
				_currentAdditionalHeader = newAdditionalHeader;
				
				// We compare the two DRM headers and if they are different we inject
				// the new one as script data into the underlying objects.
				// Strictly speaking, the != comparison of additional header is not enough. 
				// Ideally, we need to do bytewise comparison, however there might be a performance
				// hit considering the size of the additional header.
				if (newAdditionalHeader != null && newAdditionalHeader != prevAdditionalHeader)
				{
					CONFIG::LOGGING
					{
						logger.debug("Update of DRM header is required.");
					}
					dispatchAdditionalHeader(newAdditionalHeader);
				}
			}
		}

		/**
		 * Updates the metadata for the current quality.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function updateMetadata(quality:int):void
		{
			if (quality != _currentQuality)
			{
				var bootstrapBox:AdobeBootstrapBox = _bootstrapBoxes[quality];
				if (bootstrapBox != null)
				{
					notifyTotalDuration(bootstrapBox.totalDuration / bootstrapBox.timeScale, quality);
				}
			}
		}

		/**
		 * Dispatches the protected content header.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function dispatchAdditionalHeader(additionalHeader:ByteArray):void
		{
			var flvTag:FLVTagScriptDataObject = new FLVTagScriptDataObject();
			flvTag.data = additionalHeader;
			
			dispatchEvent(
				new HTTPStreamingEvent(
					HTTPStreamingEvent.SCRIPT_DATA
					, false
					, false
					, 0
					, flvTag
					, FLVTagScriptDataMode.FIRST
				)
			);
		}
		
		/**
		 * Dispatches the DVR information extracted from the specified bootstrap.
		 *  
		 * @param bootstrapBox The bootstrap box containing the DVR information.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function dispatchDVRStreamInfo(bootstrapBox:AdobeBootstrapBox):void
		{
			var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
			
			var dvrInfo:DVRInfo = _f4fIndexInfo.dvrInfo;
			if (dvrInfo != null)
			{
				// update recording status from fragment runt table
				dvrInfo.isRecording = !frt.tableComplete();
				
				// calculate current duration
				var currentDuration:Number = bootstrapBox.totalDuration/bootstrapBox.timeScale;
				
				// update start time for the first time
				if (isNaN(dvrInfo.startTime))
				{
					if (!dvrInfo.isRecording)
					{
						dvrInfo.startTime = 0;
					}
					else
					{
						var beginOffset:Number = ((dvrInfo.beginOffset < 0) || isNaN(dvrInfo.beginOffset)) ? 0 : dvrInfo.beginOffset;
						var endOffset:Number = ((dvrInfo.endOffset < 0) || isNaN(dvrInfo.endOffset))? 0 : dvrInfo.endOffset;
						
						dvrInfo.startTime = DVRUtils.calculateOffset(beginOffset, endOffset, currentDuration);  
					}
					
					dvrInfo.startTime += (frt.fragmentDurationPairs)[0].durationAccrued/bootstrapBox.timeScale;
					if (dvrInfo.startTime > currentDuration)
					{
						dvrInfo.startTime = currentDuration;
					}
				}
				
				// update current length of the DVR window 
				dvrInfo.curLength = currentDuration - dvrInfo.startTime;	
				
				// adjust the start time if we have a DVR rooling window active
				if ((dvrInfo.windowDuration != -1) && (dvrInfo.curLength > dvrInfo.windowDuration))
				{
					dvrInfo.startTime += dvrInfo.curLength - dvrInfo.windowDuration;
					dvrInfo.curLength = dvrInfo.windowDuration;
				}
				
				dispatchEvent(
					new DVRStreamInfoEvent(
						DVRStreamInfoEvent.DVRSTREAMINFO, 
						false, 
						false, 
						dvrInfo
					)
				); 								
			}	
		}

		
		/**
		 * Dispatches an event requesting loading/refreshing of the specified quality.
		 * 
		 * @param quality The quality level for which the request should be made.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function dispatchIndexLoadRequest(quality:int):void
		{
			dispatchEvent(
				new HTTPStreamingIndexHandlerEvent( 
					HTTPStreamingIndexHandlerEvent.REQUEST_LOAD_INDEX 
					, false
					, false
					, false
					, NaN
					, null
					, null
					, new URLRequest(_bootstrapBoxesURLs[quality])
					, quality
					, true
				)
			);
		}
		
		/**
		 * Notifies clients that rates are ready.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function notifyRatesReady():void
		{
			dispatchEvent( 
				new HTTPStreamingIndexHandlerEvent( 
					HTTPStreamingIndexHandlerEvent.RATES_READY
					, false
					, false
					, false
					, NaN
					, _streamNames
					, _streamQualityRates
				)
			);
		}
		
		/**
		 * Notifies clients that index is ready.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		private function notifyIndexReady(quality:int):void
		{
			var bootstrapBox:AdobeBootstrapBox = _bootstrapBoxes[quality];
			var frt:AdobeFragmentRunTable = getFragmentRunTable(bootstrapBox);
			
			dispatchDVRStreamInfo(bootstrapBox);
			
			if (!_invokedFromDvrGetStreamInfo)
			{
				// in pure live scenario, update the "closest" position to live we want
				if (bootstrapBox.live && _f4fIndexInfo.dvrInfo == null && isNaN(_pureLiveOffset))
				{
					_pureLiveOffset = bootstrapBox.currentMediaTime - OSMFSettings.hdsPureLiveOffset * bootstrapBox.timeScale;
					if (_pureLiveOffset < 0)
					{
						_pureLiveOffset = NaN;
					}
					else
					{
						_pureLiveOffset = _pureLiveOffset / bootstrapBox.timeScale;
					}
				}
				
				// If the stream is live, initialize the bootstrap update timer
				// if we are in a live stream with rolling window feature activated
				if (bootstrapBox.live && _f4fIndexInfo.dvrInfo != null && _f4fIndexInfo.dvrInfo.windowDuration != -1)
				{
					initializeBootstrapUpdateTimer();
				}
				
				// Destroy the timer if the stream is no longer recording
				if (frt.tableComplete())
				{
					destroyBootstrapUpdateTimer();
				}
				
				dispatchEvent(
					new HTTPStreamingIndexHandlerEvent(
						HTTPStreamingIndexHandlerEvent.INDEX_READY
						, false
						, false
						, bootstrapBox.live
						, _pureLiveOffset 
					)
				);
			}
			_invokedFromDvrGetStreamInfo = false;
		}

		/**
		 * Notifies clients that total duration is available through onMetadata message.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		private function notifyTotalDuration(duration:Number, quality:int):void
		{
			var metaInfo:Object = _streamInfos[quality].streamMetadata;
			if (metaInfo == null)
			{
				metaInfo = new Object();
			}
			metaInfo.duration = duration;
			
			var sdo:FLVTagScriptDataObject = new FLVTagScriptDataObject();
			sdo.objects = ["onMetaData", metaInfo];
			dispatchEvent(
				new HTTPStreamingEvent(
					HTTPStreamingEvent.SCRIPT_DATA
					, false
					, false
					, 0
					, sdo
					, FLVTagScriptDataMode.IMMEDIATE
				)
			);
		}

		/**
		 * Notifies clients that total duration is available through onMetadata message.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		private function notifyFragmentDuration(duration:Number):void
		{
			// Update the bootstrap update interval; we set its value to the fragment duration
			bootstrapUpdateInterval = duration * 1000;
			if (bootstrapUpdateInterval < OSMFSettings.hdsMinimumBootstrapRefreshInterval)
			{
				bootstrapUpdateInterval = OSMFSettings.hdsMinimumBootstrapRefreshInterval;
			}
			
			dispatchEvent(
				new HTTPStreamingEvent( 
					HTTPStreamingEvent.FRAGMENT_DURATION 
					, false
					, false
					, duration
					, null
					, null
				)
			);				
		}

		private function initializeBootstrapUpdateTimer():void
		{
			if (bootstrapUpdateTimer == null)
			{
				// This will regularly update the bootstrap information;
				// We just initialize the timer here; we'll start it in the first call of the getFileForTime method
				// or in the first call of getNextFile
				// The initial delay is 4000 (recommended fragment duration)
				bootstrapUpdateTimer = new Timer(bootstrapUpdateInterval);
				bootstrapUpdateTimer.addEventListener(TimerEvent.TIMER, onBootstrapUpdateTimer);
				bootstrapUpdateTimer.start();
			}
		}
		
		private function destroyBootstrapUpdateTimer():void
		{
			if (bootstrapUpdateTimer != null)
			{
				bootstrapUpdateTimer.removeEventListener(TimerEvent.TIMER, onBootstrapUpdateTimer);
				bootstrapUpdateTimer = null;
			}
		}

		/// Event handlers
		/**
		 * Handler called when bootstrap information is available from external objects
		 * (for exemple: the stream packager can insert bootstrap information into
		 * the stream itself, and this information is processed by file handler).
		 * 
		 * We will use it to update the bootstrap information for current quality.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */ 
		private function onBootstrapBox(event:HTTPStreamingFileHandlerEvent):void
		{
			updateBootstrapBox(_currentQuality, event.bootstrapBox);			
		}
		
		private function onBootstrapUpdateTimer(event:TimerEvent):void
		{ 
			if (_currentQuality != -1)
			{
				refreshBootstrapBox(_currentQuality);
				bootstrapUpdateTimer.delay = bootstrapUpdateInterval;
			}
		}
		
//		/**
//		 * @private
//		 * 
//		 * Given timeBias, calculates the corresponding segment duration.
//		 */
//		internal function calculateSegmentDuration(abst:AdobeBootstrapBox, timeBias:Number):Number
//		{
//			var fragmentDurationPairs:Vector.<FragmentDurationPair> = (abst.fragmentRunTables)[0].fragmentDurationPairs;
//			var fragmentId:uint = currentFAI.fragId;
//			
//			var index:int =  fragmentDurationPairs.length - 1;
//			while (index >= 0)
//			{
//				var fragmentDurationPair:FragmentDurationPair = fragmentDurationPairs[index];
//				if (fragmentDurationPair.firstFragment <= fragmentId)
//				{
//					var duration:Number = fragmentDurationPair.duration;
//					var durationAccrued:Number = fragmentDurationPair.durationAccrued;
//					durationAccrued += (fragmentId - fragmentDurationPair.firstFragment) * fragmentDurationPair.duration;
//					if (timeBias > 0)
//					{
//						duration -= (timeBias - durationAccrued);
//					}
//					
//					return duration;
//				}
//				else
//				{
//					index--;
//				}
//			}
//			
//			return 0;
//		}
//
//		override public function getFragmentDurationFromUrl(fragmentUrl:String):Number
//		{
//			// we assume that there is only one afrt in bootstrap
//			
//			var tempFragmentId:String = fragmentUrl.substr(fragmentUrl.indexOf("Frag")+4, fragmentUrl.length);
//			var fragId:uint = uint(tempFragmentId);
//			var abst:AdobeBootstrapBox = bootstrapBoxes[_currentQuality];
//			var afrt:AdobeFragmentRunTable = abst.fragmentRunTables[0];
//			return afrt.getFragmentDuration(fragId);
//		}

		
		/// Internals		
		private var _currentQuality:int = -1;
		private var _currentAdditionalHeader:ByteArray = null;
		private var _currentFAI:FragmentAccessInformation = null;
		
		private var _pureLiveOffset:Number = NaN;
		
		private var _f4fIndexInfo:HTTPStreamingF4FIndexInfo = null;
		private var _bootstrapBoxes:Vector.<AdobeBootstrapBox> = null;
		private var _bootstrapBoxesURLs:Vector.<String> = null;
		private var _streamInfos:Vector.<HTTPStreamingF4FStreamInfo> = null;
		private var _streamNames:Array = null;
		private var _streamQualityRates:Array = null;
		private var _serverBaseURL:String = null;
		
		private var _delay:Number = 0.05;
		
		private var _indexUpdating:Boolean = false;
		private var _pendingIndexLoads:int = 0;
		private var _pendingIndexUpdates:int = 0;
		private var _pendingIndexUrls:Object = new Object();

		private var _invokedFromDvrGetStreamInfo:Boolean = false;
		
		
		private var playInProgress:Boolean;
		
		private var bootstrapUpdateTimer:Timer;
		private var bootstrapUpdateInterval:Number = 4000;
		public static const DEFAULT_FRAGMENTS_THRESHOLD:uint = 5;
		
		CONFIG::LOGGING
		{
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.net.httpstreaming.f4f.HTTPStreamF4FIndexHandler");
		}
	}
}