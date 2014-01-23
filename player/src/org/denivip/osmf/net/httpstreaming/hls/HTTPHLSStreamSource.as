/*****************************************************
 *  
 *  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package org.denivip.osmf.net.httpstreaming.hls
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	import org.denivip.osmf.events.HTTPHLSStreamingEvent;
       import org.denivip.osmf.net.httpstreaming.hls.BemTVDownloader;
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.events.HTTPStreamingIndexHandlerEvent;
	import org.osmf.media.MediaResourceBase;
       import org.osmf.net.httpstreaming.HTTPStreamDownloader;
	import org.osmf.net.httpstreaming.HTTPStreamHandlerQoSInfo;
	import org.osmf.net.httpstreaming.HTTPStreamRequest;
	import org.osmf.net.httpstreaming.HTTPStreamRequestKind;
	import org.osmf.net.httpstreaming.HTTPStreamingFactory;
	import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexInfoBase;
	import org.osmf.net.httpstreaming.IHTTPStreamHandler;
	import org.osmf.net.httpstreaming.IHTTPStreamSource;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.net.qos.FragmentDetails;
	import org.osmf.net.qos.QualityLevel;
	import org.osmf.utils.OSMFSettings;
	import org.osmf.utils.OSMFStrings;

	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Log;
		import org.osmf.logging.Logger;
	}
	
	/**
	 * @private
	 * 
	 * HTTPStreamProvider class is responsible for providing HDS properly 
	 * formatted bytes to the NetStream objects.
	 *  
	 * @langversion 3.0
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @productversion OSMF 1.6
	 */ 
	public class HTTPHLSStreamSource implements IHTTPStreamSource, IHTTPStreamHandler
	{
		/**
		 * Default constructor.
		 */
		public function HTTPHLSStreamSource(factory:HTTPStreamingFactory, resource:MediaResourceBase, dispatcher:IEventDispatcher)
		{
			if (dispatcher == null || factory == null || resource == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM) + " - HTTPHLSStreamSource");
			}
			
			_dispatcher = dispatcher;
			_resource = resource;	
			
			_fileHandler = factory.createFileHandler(resource);
			if (_fileHandler == null)
			{
				throw new ArgumentError("Null file handler in HTTPStreamSourceHandler constructor. Probably invalid factory object or resource."); 
			}
			_indexHandler = factory.createIndexHandler(resource, _fileHandler);
			if (_indexHandler == null)
			{
				throw new ArgumentError("Null index handler in HTTPStreamSourceHandler constructor. Probably invalid factory object or resource."); 
			}
			_indexInfo = factory.createIndexInfo(resource);
			
			CONFIG::LOGGING
			{
				if (_indexInfo == null)
				{
					logger.warn("Null index info in HTTPStreamSourceHandler constructor. Probably invalid factory object or resource."); 
				}
			}
			
			_fileHandler.addEventListener(HTTPStreamingEvent.FRAGMENT_DURATION, onFragmentDuration);
			_fileHandler.addEventListener(HTTPStreamingEvent.SCRIPT_DATA, onScriptData);
			_fileHandler.addEventListener(HTTPStreamingEvent.FILE_ERROR, onError);
			
			_indexHandler.addEventListener(HTTPStreamingIndexHandlerEvent.INDEX_READY, onIndexReady);
			_indexHandler.addEventListener(HTTPStreamingIndexHandlerEvent.RATES_READY, onRatesReady);
			_indexHandler.addEventListener(HTTPStreamingIndexHandlerEvent.REQUEST_LOAD_INDEX, onRequestLoadIndex);
			_indexHandler.addEventListener(DVRStreamInfoEvent.DVRSTREAMINFO, onDVRStreamInfo);
			_indexHandler.addEventListener(HTTPStreamingEvent.FRAGMENT_DURATION, onFragmentDuration);
			_indexHandler.addEventListener(HTTPHLSStreamingEvent.DISCONTINUITY, onDiscontinuity);
			_indexHandler.addEventListener(HTTPStreamingEvent.SCRIPT_DATA, onScriptData);
			_indexHandler.addEventListener(HTTPStreamingEvent.INDEX_ERROR, onError);
			
			// when best effort fetch is enabled, the index handler will handle fragment download events
			// itself and fire DOWNLOAD_CONTINUE, DOWNLOAD_SKIP, DOWNLOAD_COMPLETE, DOWNLOAD_ERROR
			_indexHandler.addEventListener(HTTPStreamingEvent.DOWNLOAD_CONTINUE, onBestEffortDownloadEvent);
			_indexHandler.addEventListener(HTTPStreamingEvent.DOWNLOAD_SKIP, onBestEffortDownloadEvent);
			_indexHandler.addEventListener(HTTPStreamingEvent.DOWNLOAD_COMPLETE, onBestEffortDownloadEvent);
			_indexHandler.addEventListener(HTTPStreamingEvent.DOWNLOAD_ERROR, onBestEffortDownloadEvent);
			
			_indexDownloaderMonitor.addEventListener(HTTPStreamingEvent.DOWNLOAD_COMPLETE, 	onIndexComplete);
			_indexDownloaderMonitor.addEventListener(HTTPStreamingEvent.DOWNLOAD_ERROR, 	onIndexError);
				
			setState(HTTPStreamingState.INIT);
			
			CONFIG::LOGGING
			{			
				logger.debug("Provider initialized.");
			}
		}
		
		private function onDiscontinuity(event:HTTPHLSStreamingEvent):void{
			_discontinuityOnNextSegment = true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get source():IHTTPStreamSource
		{
			return this;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get isReady():Boolean
		{
			return _isReady;
		}

		/**
		 * @inheritDoc
		 */
		public function get endOfStream():Boolean
		{
			return _endOfStream;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get hasErrors():Boolean
		{
			return _hasErrors;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get isLiveStalled():Boolean
		{
			return _isLiveStalled;
		}
		
		/**
		 * The current stream name opened by this stream provider.
		 */ 
		public function get streamName():String
		{
			return _streamName;
		}
		
		public function get qosInfo():HTTPStreamHandlerQoSInfo
		{
			return _qosInfo;
		}
		
		/**
		 * Returns true if the current source is open.
		 **/
		public function get isOpen():Boolean
		{
			return (_streamName != null);
		}
		
		/**
		 * Opens and initializes a stream provider to handle a specific stream.
		 */
		public function open(streamName:String):void
		{
			if (_streamName != null)
			{
				close();
			}
			
			_streamName = streamName;
			_qualityAndStreamNameInSync = false;
			
			CONFIG::LOGGING
			{			
				if (_streamName == null)
				{
					loggedStreamName = _streamName;
				}
				else
				{
					loggedStreamName = _streamName.substr(_streamName.lastIndexOf("/"));
				}
				logger.debug("Opening stream [ " + loggedStreamName + " ]. ");
			}
			
			// Hack alert: the API in OSMF here is....dumb.  There's a single argument to a base class, when really we need two.  We'll hack around this by 
			// bundling stuff into an object.
			var args:Object = {};
			args.indexInfo = _indexInfo;
			args.streamName = _streamName;
			_indexHandler.initialize(args);
		}
		
		/**
		 * Closes an existing stream provider.
		 */
		public function close():void
		{
			CONFIG::LOGGING
			{			
				logger.debug("Closing stream [ " + loggedStreamName + " ]. ");
			}
			
			if (_downloader != null)
			{
				_downloader.close();
			}
			
			_indexDownloaderMonitor.removeEventListener(HTTPStreamingEvent.DOWNLOAD_COMPLETE, onIndexComplete);
			_indexDownloaderMonitor.removeEventListener(HTTPStreamingEvent.DOWNLOAD_ERROR, onIndexError);
			
			_indexHandler.dispose();
			
			_discontinuityOnNextSegment = false;
			_endFragment = true;
			_endOfStream = true;
			_streamName = null;
		}
		
		/**
		 * Seeks to the specified offset in stream.
		 */
		public function seek(offset:Number):void
		{
			_endOfStream = false;
			_hasErrors = false;
			_isLiveStalled = false;
			
			_seekTarget = offset;
			_didBeginSeek = false;
			_didCompleteSeek = false;
			if (_seekTarget < 0 )
			{
				if (_dvrInfo != null)
				{
					_seekTarget = Math.floor(_dvrInfo.startTime + _dvrInfo.curLength - 3 * OSMFSettings.hdsDVRLiveOffset);
				}
				else
				{
					if (_isLive)
					{
						_seekTarget = Math.floor(_offset);
					}
					else
					{
						_seekTarget = 0;
					}
				}
			}

			CONFIG::LOGGING
			{			
				logger.debug("Seeking to " + _seekTarget + " in stream [ " + loggedStreamName + " ]. ");
			}
			setState(HTTPStreamingState.SEEK);
		}
		
		/**
		 * Returns a chunk of bytes from the underlying stream or null
		 * if the stream provider needs to do some additional processing
		 * in order to obtain the bytes.
		 */
		public function getBytes():ByteArray
		{
			return doSomeProcessingAndGetBytes();
		}
		
		/**
		 * Gets stream information from the underlying objects.
		 */
		public function getDVRInfo(streamName:Object):void
		{
			CONFIG::LOGGING
			{			
				logger.debug("Loading dvr information.");
			}	
			
			_indexHandler.dvrGetStreamInfo(_indexInfo != null ? _indexInfo : streamName);
		}
		
		/**
		 * Changes the quality of the stream to the specified level.
		 */
		public function changeQualityLevel(streamName:String):void
		{
			CONFIG::LOGGING
			{
				logger.debug("Prepare to switch the quality level to " + streamName);
			}

			var level:int = -1;
			if (_streamNames != null)
			{
				for (var i:int = 0; i < _streamNames.length; i++)
				{
					if (streamName == _streamNames[i])
					{
						level = i;
						break;
					}
				}
			}
			
			if (level == -1)
			{
				throw new Error("Quality level cannot be set at this time.");
			}
			else
			{
				if (level != _desiredQualityLevel)
				{
					beginQualityLevelChange(level);
				}
			}
		}
		
		/**
		 * 
		 */
		public function loadNextChunk():void{
			setState(HTTPStreamingState.LOAD);
		}
		
		/**
		 * @inheritDoc
		 */	
		public function get isBestEffortFetchEnabled():Boolean
		{
			return _indexHandler != null && 
				_indexHandler.isBestEffortFetchEnabled;
		}
		
		/**
		 * Returns the duration of the current fragment
		 */
		public function get fragmentDuration():Number 
		{
			return _fragmentDuration;
		}
		
		///////////////////////////////////////////////////////////////////////
		/// Internals
		///////////////////////////////////////////////////////////////////////
		/**
		 * Process some small chunk of functionality and then 
		 * tries to return a byte array to the caller.
		 */
		protected function doSomeProcessingAndGetBytes():ByteArray
		{
			var bytes:ByteArray = null;
			var input:IDataInput = null;
			var date:Date;
			
			switch(_state)
			{
				case HTTPStreamingState.INIT:
					// do nothing
					break;
				
				case HTTPStreamingState.SEEK:
					if (_downloader != null)
					{
						_downloader.close();
						_fileHandler.flushFileSegment(_downloader.getBytes());
					}
					
					setState(HTTPStreamingState.LOAD);
					break;

				case HTTPStreamingState.WAIT:
					date = new Date();
					if (date.getTime() > _retryAfterTime)
					{
						setState(HTTPStreamingState.LOAD);
					}
					break;
				
				case HTTPStreamingState.LOAD:
					// we need to notify our clients about a completed change
					if (_qualityLevelChanged)
					{
						endQualityLevelChange();
					}
					
					_fragmentDuration = -1;
					_endOfStream = false;
					
					// Ask the index handler to provide the url for 
					// the next chunk of data we need to load.
					var wasSeek:Boolean = false;
					if(!_didBeginSeek) // we are in seeking mode
					{
						_request = _indexHandler.getFileForTime(_seekTarget, _qualityLevel);
						wasSeek = true;
					}
					else
					{
						_request = _indexHandler.getNextFile(_qualityLevel);
					}
					
					// update _isLiveStalled so HTTPNetStream can access it.
					// request.kind will always be LIVE_STALL as long as we are live stalled. 
					_isLiveStalled = (_request.kind == HTTPStreamRequestKind.LIVE_STALL);
					
					switch(_request.kind)
					{
						case HTTPStreamRequestKind.DOWNLOAD:
						case HTTPStreamRequestKind.BEST_EFFORT_DOWNLOAD:
						
							if(wasSeek)
							{	
								// mark that we already tried the seek so we don't try again later
								_didBeginSeek = true;
							}

							// If we obtained some valid url we can use for loading data
							// then we use internal source to actually download the chunk
							if (_downloader == null)
							{
								_downloader = new BemTVDownloader();
							}

							var downloaderMonitor:IEventDispatcher = _dispatcher;
							if (_request.kind == HTTPStreamRequestKind.BEST_EFFORT_DOWNLOAD)
							{
								// special case: best effort download.
								// indexHandler will intercept download events, then
								// fire DOWNLOAD_ERROR, DOWNLOAD_SKIP, or DOWNLOAD_CONTINUE to indicate
								// that we should proceed
								downloaderMonitor = _request.bestEffortDownloaderMonitor;
								_bestEffortDownloadResult = null;
							}
							CONFIG::LOGGING
							{			
								logger.debug("downloader.open "+_request.url);
							}
							_downloader.open(_request.urlRequest, downloaderMonitor, OSMFSettings.hdsFragmentDownloadTimeout);
							setState(HTTPStreamingState.BEGIN_FRAGMENT);
							break;
						case HTTPStreamRequestKind.RETRY:
						case HTTPStreamRequestKind.LIVE_STALL:
							// If we finished processing current fragments and we don't know 
							// if we have any additional data, we are waiting a little for 
							//things to update
							date = new Date();
							_retryAfterTime = date.getTime() + (1000.0 * _request.retryAfter);
							setState(HTTPStreamingState.WAIT);
							break;
						case HTTPStreamRequestKind.DONE:
							// If we finished processing current fragments and we know for
							// sure that we don't have any additional data, we are stopping
							// the provider
							_endFragment = true;
							_endOfStream = true;
							
							if (_downloader != null)
							{
								bytes = _fileHandler.flushFileSegment(_downloader.getBytes()); 
							}
							setState(HTTPStreamingState.STOP);	
							break;
					}
					break;
				
				case HTTPStreamingState.BEGIN_FRAGMENT:
					if(_request.kind == HTTPStreamRequestKind.BEST_EFFORT_DOWNLOAD)
					{
						CONFIG::LOGGING
						{
							logger.debug("_bestEffortDownloadResult = " + _bestEffortDownloadResult);
						}
						if(_bestEffortDownloadResult == null)
						{
							// we're waiting for the index handler to tell us what to do
							break;
						} 
						else if(_bestEffortDownloadResult == HTTPStreamingEvent.DOWNLOAD_ERROR)
						{
							// a timeout occured.
							// code elsewhere will eventually trigger a stream stop.
							break;
						} 
						else if(_bestEffortDownloadResult == HTTPStreamingEvent.DOWNLOAD_SKIP)
						{
							// index handler wants us to ignore this fragment.
							// go back to load state to trigger another request.
							setState(HTTPStreamingState.LOAD);
							break;
						}
						else if(_bestEffortDownloadResult == HTTPStreamingEvent.DOWNLOAD_CONTINUE)
						{
							// index handler wants us to process this fragment.
							// fall through
						}
						else
						{
							// unknown state
							break;
						}
						
						// once we accept a fragment the continue state, mark _isLiveStalled as false
						_isLiveStalled = false;
					}
					
					_endFragment = false;
					_hasErrors = false;
					if (!_didCompleteSeek)
					{
						_fileHandler.beginProcessFile(true, _seekTarget);
						_didCompleteSeek = true;
					}
					else
					{
						_fileHandler.beginProcessFile(false, 0);
					}
					
					_dispatcher.dispatchEvent( 
						new HTTPStreamingEvent(
							HTTPStreamingEvent.BEGIN_FRAGMENT, 
							false,
							true,
							NaN,
							null,
							null,
							_streamName
						)
					);

					setState(HTTPStreamingState.READ);
					break;
				
				case HTTPStreamingState.READ:
					if (_downloader != null)
					{
						input = _downloader.getBytes(_fileHandler.inputBytesNeeded);
						
						if (input != null)
						{
							if(_discontinuityOnNextSegment){
								CONFIG::LOGGING
								{
									logger.info("Timecode Discontinuity: Dispatching DISCONTINUITY event");
								}
								_dispatcher.dispatchEvent(new HTTPHLSStreamingEvent(HTTPHLSStreamingEvent.DISCONTINUITY));
								_discontinuityOnNextSegment = false;
							}
							bytes = _fileHandler.processFileSegment(input);
						}
						else
						{
							_endFragment = (_downloader != null && _downloader.isOpen && _downloader.isComplete && !_downloader.hasData);
							_hasErrors = (_downloader != null && _downloader.hasErrors);
						}
					}
					
					if (_state == HTTPStreamingState.READ)
					{
						if (_endFragment)
						{
							if (_downloader != null)
							{
								_downloader.saveRemainingBytes();
							}
							setState(HTTPStreamingState.END_FRAGMENT);
						}
					}
					break;
				
				case HTTPStreamingState.END_FRAGMENT:
					if (_downloader != null)
					{
						input = _downloader.getBytes();
						if (input != null)
						{
							bytes = _fileHandler.endProcessFile(input);
						}
						if(bytes === null){
							bytes = new ByteArray();
						}
						var flushBytes:ByteArray = _fileHandler.flushFileSegment(new ByteArray());
						bytes.writeBytes(flushBytes);
					}
					
					var availableQualityLevels:Vector.<QualityLevel> = new Vector.<QualityLevel>;
					for (var i:uint = 0; i < _qualityRates.length; i++)
					{
						availableQualityLevels.push(new QualityLevel(i, _qualityRates[i], _streamNames[i]));
					}
					
					var requestURL:String = _request.urlRequest.url;
					var fragmentIdentifier:String = requestURL.substr(requestURL.lastIndexOf("Seg"));
					
					var lastFragmentDetails:FragmentDetails = new FragmentDetails(_downloader.downloadBytesCount, _fragmentDuration, _downloader.downloadDuration, _qualityLevel, fragmentIdentifier);
					
					_qosInfo = new HTTPStreamHandlerQoSInfo(availableQualityLevels, _qualityLevel, lastFragmentDetails);
					
					
					_dispatcher.dispatchEvent( 
						new HTTPStreamingEvent(
							HTTPStreamingEvent.END_FRAGMENT,
							false,
							true,
							NaN,
							null,
							null,
							_streamName
						)
					);
					
					
					setState(HTTPStreamingState.LOAD);
					break;
			}
			
			return bytes;
		}
		
		/**
		 * @private
		 * 
		 * Sets the state of the stream provider to the specified value.
		 */
		protected function setState(value:String):void
		{
			_state = value;
			
			CONFIG::LOGGING
			{
				if (_state != previouslyLoggedState)
				{
					logger.debug("State = " + _state);
					previouslyLoggedState = _state;
				}
			}
		}
		
		/**
		 * @private
		 * 
		 * Event listener for <code>DVRSTREAMINFO</code>. This event indicates that 
		 * index handler has detected DVR information while processing index file.
		 * We just forward this further for processing as is needed by DVRCastTrait.
		 */
		private function onDVRStreamInfo(event:DVRStreamInfoEvent):void
		{
			_dvrInfo = event.info as DVRInfo;
			_dispatcher.dispatchEvent(event);
		}
		
		/**
		 * @private
		 * 
		 * Event listener for <code>NOTIFY_INDEX_READY</code> event. We store
		 * the server offset and the live status for further processing.
		 */
		private function onIndexReady(event:HTTPStreamingIndexHandlerEvent):void
		{
			_isReady = true;
			_isLive = event.live;
			_offset = event.offset;

			CONFIG::LOGGING
			{			
				logger.debug("Stream [ " + loggedStreamName + " ] refreshed. ( offset = " + _offset + ", live = " + _isLive + ").");
			}
			
			if (!_qualityAndStreamNameInSync)
			{
				CONFIG::LOGGING
				{			
					logger.debug("Stream name [ " + loggedStreamName + " ] and quality level [" + _qualityLevel + "] are not in sync.");
				}
				
				_qualityAndStreamNameInSync = true;
				changeQualityLevel(_streamName);
			}
		}
		
		/**
		 * @private
		 * 
		 * Event listener for <code>NOTIFY_RATES</code> event. We save the stream names,
		 * stream bitrates and quality levels internally for future reference when 
		 * a dynamic switch command will be issued.
		 */
		private function onRatesReady(event:HTTPStreamingIndexHandlerEvent):void
		{
			_ratesAreReady = true;
			_qualityRates = event.rates;
			_streamNames = event.streamNames;
			_numQualityLevels = _qualityRates.length;
		}
		
		/**
		 * @private
		 * 
		 * Event listener for <code>REQUEST_LOAD_INDEX</code> event. We start the download
		 * of the index file and on completion we forward that to indexHandler for 
		 * further processing.
		 */
		private function onRequestLoadIndex(event:HTTPStreamingIndexHandlerEvent):void
		{
			// ignore any additonal request if an loader operation is still in progress
			_pendingIndexDownloadRequests[_pendingIndexDownloadRequestsLenght] = event;
			_pendingIndexDownloadRequestsLenght++;
			
			if (_currentIndexDownloadEvent == null)
			{
				_currentIndexDownloadEvent = event;
				_indexDownloader.open(_currentIndexDownloadEvent.request, _indexDownloaderMonitor, OSMFSettings.hdsIndexDownloadTimeout);
			}
		}
		
		/**
		 * @private
		 * 
		 * Event listener for completion of index file download. We can close the
		 * loader object and send data for further processing.
		 */ 
		private function onIndexComplete(event:HTTPStreamingEvent):void
		{
			// FM-1003 (http://bugs.adobe.com/jira/browse/FM-1003) 
			// Re-dispatch this event on the _dispatcher
			_dispatcher.dispatchEvent(event);
			var input:IDataInput = _indexDownloader.getBytes();
			var bytes:ByteArray = new ByteArray();
			input.readBytes(bytes, 0, input.bytesAvailable);
			bytes.position = 0;
			
			_indexHandler.processIndexData(bytes, _currentIndexDownloadEvent.requestContext);
			processPendingIndexLoadingRequest();
		}
		
		/**
		 * @private 
		 * 
		 * Event listener for error triggered by download of index file. We'll just 
		 * forward this event further.
		 */ 
		private function onIndexError(event:HTTPStreamingEvent):void
		{
			CONFIG::LOGGING
			{			
				logger.error("Attempting to download the index file (bootstrap) caused error!");
			}
			
			if (_indexDownloader != null)
			{
				_indexDownloader.close();
			}
			_currentIndexDownloadEvent = null;
			_dispatcher.dispatchEvent(event);
		}
		
		/**
		 * @private
		 * 
		 * Processes next request for loading an index file.
		 */
		private function processPendingIndexLoadingRequest():void
		{
			_pendingIndexDownloadRequests.shift();
			_pendingIndexDownloadRequestsLenght--;
			
			if (_pendingIndexDownloadRequestsLenght == 0)
			{
				if (_indexDownloader != null)
				{
					_indexDownloader.close();
				}
				_currentIndexDownloadEvent = null;
			}
			else
			{
				_currentIndexDownloadEvent = _pendingIndexDownloadRequests[0];
				_indexDownloader.open(_currentIndexDownloadEvent.request, _indexDownloaderMonitor, OSMFSettings.hdsIndexDownloadTimeout);
			}	
		}
		
		/**
		 * @private
		 * 
		 * Event listener called when index handler of file handler obtain fragment duration.
		 */
		private function onFragmentDuration(event:HTTPStreamingEvent):void
		{
			_fragmentDuration = event.fragmentDuration;
		}
		
		/**
		 * @private
		 * 
		 * Event listener called when index handler of file handler need to handle script 
		 * data objects. We just forward them for further processing.
		 */
		private function onScriptData(event:HTTPStreamingEvent):void
		{
			_dispatcher.dispatchEvent(
				new HTTPStreamingEvent(
					event.type,
					event.bubbles,
					event.cancelable,
					event.fragmentDuration,
					event.scriptDataObject,
					event.scriptDataMode,
					_streamName
				)
			);
		}
		
		/**
		 * @private
		 * 
		 * Event listener for errors dispatched by index or file handler. We just forward
		 * them for further processing, but in the future we may hide some errors.
		 */
		private function onError(event:HTTPStreamingEvent):void
		{
			CONFIG::LOGGING
			{			
				logger.error("error: " + event );
			}
			
			_dispatcher.dispatchEvent(event);
		}

		/**
		 * @private
		 * 
		 * Begins the change of the current quality level to the specified one.
		 */
		private function beginQualityLevelChange(level:int):void
		{
			_qualityLevelChanged = true;
			
			_desiredQualityLevel = level;
			_desiredQualityStreamName = _streamNames[_desiredQualityLevel];
			
			_dispatcher.dispatchEvent(
				new HTTPStreamingEvent(
					HTTPStreamingEvent.TRANSITION,
					false,
					false,
					NaN,
					null,
					null,
					_desiredQualityStreamName
				)
			);
			
			CONFIG::LOGGING
			{
				logger.debug("Quality level switch in progress. The next chunk will use the quality level [" + _desiredQualityLevel + "] with stream ["  + _desiredQualityStreamName + " ].");
			}

		}
		
		/**
		 * @private
		 * 
		 * Ends the change of the current quality level.
		 */
		private function endQualityLevelChange():void
		{
			_qualityLevel = _desiredQualityLevel;
			_streamName = _desiredQualityStreamName;
			
			CONFIG::LOGGING
			{
				if (_streamName == null)
				{
					loggedStreamName = _streamName;
				}
				else
				{
					loggedStreamName = _streamName.substr(_streamName.lastIndexOf("/"));
				}
			}
			
			_desiredQualityLevel = -1;
			_desiredQualityStreamName = null;
			_qualityLevelChanged = false;
			
			_dispatcher.dispatchEvent(
				new HTTPStreamingEvent(
					HTTPStreamingEvent.TRANSITION_COMPLETE,
					false,
					false,
					NaN,
					null,
					null,
					_streamName
				)
			);

			CONFIG::LOGGING
			{
				logger.debug("Quality level switch completed. The current quality level [" + _qualityLevel + "] with stream ["  + loggedStreamName + " ].");
			}
		}
		
		/**
		 * @private
		 * 
		 * Called on _indexHandler DOWNLOAD_SKIP, DOWNLOAD_CONTINUE, and DOWNLOAD_ERROR events.
		 */
		private function onBestEffortDownloadEvent(event:HTTPStreamingEvent):void
		{
			if(event.type == HTTPStreamingEvent.DOWNLOAD_COMPLETE)
			{
				// DOWNLOAD_COMPLETE events are just passed through
				// they do not tell us whether or not to proceed with processing
				forwardEventToDispatcher(event);
			}
			else
			{
				if(_bestEffortDownloadResult != null)
				{
					return;
				}
				_bestEffortDownloadResult = event.type; // see handling of BEGIN_FRAGMENT state
				forwardEventToDispatcher(event);
			}
		}
		
		/**
		 * @private
		 * 
		 * Forwards an event to _dispatcher.
		 */
		private function forwardEventToDispatcher(event:Event):void
		{
			if(_dispatcher != null)
			{
				_dispatcher.dispatchEvent(event);
			}
		}
		
		/// Internals
		private var _dispatcher:IEventDispatcher = null;
		
		private var _resource:MediaResourceBase = null;
		
		private var _qosInfo:HTTPStreamHandlerQoSInfo;

		private var _downloader:BemTVDownloader = null;
		private var _request:HTTPStreamRequest = null;
		
		private var _indexHandler:HTTPStreamingIndexHandlerBase = null;
		private var _fileHandler:HTTPStreamingFileHandlerBase = null;	
		private var _indexInfo:HTTPStreamingIndexInfoBase = null;
		
		private var _streamName:String = null;
		private var _seekTarget:Number = -1;
		private var _didBeginSeek:Boolean = false;
		private var _didCompleteSeek:Boolean = false;
		
		private var _streamNames:Array = null;
		private var _qualityRates:Array = null; 	
		private var _numQualityLevels:int = 0;
		
		private var _qualityLevel:int = 0;
		private var _qualityLevelChanged:Boolean = false;
		private var _desiredQualityLevel:int = -1;
		private var _desiredQualityStreamName:String = null;
		private var _qualityAndStreamNameInSync:Boolean = false;
		
		private var _fragmentDuration:Number = 0;
		private var _endFragment:Boolean = false;
		
		private var _indexDownloaderMonitor:EventDispatcher = new EventDispatcher();
		private var _indexDownloader:HTTPStreamDownloader = new HTTPStreamDownloader();
		private var _currentIndexDownloadEvent:HTTPStreamingIndexHandlerEvent = null;
		private var _pendingIndexDownloadRequests:Vector.<HTTPStreamingIndexHandlerEvent> = new Vector.<HTTPStreamingIndexHandlerEvent>();
		private var _pendingIndexDownloadRequestsLenght:int = 0;

		private var _hasErrors:Boolean = false;
		private var _isReady:Boolean = false;
		private var _ratesAreReady:Boolean = false;
		private var _endOfStream:Boolean = false;
		
		private var _isLive:Boolean = false;
		private var _offset:Number = -1;
		private var _dvrInfo:DVRInfo = null;
		
		private var _state:String = null;
		private var _retryAfterTime:Number = -1;
		
		private var _bestEffortDownloadResult:String = null;
		
		private var _isLiveStalled:Boolean = false;
		
		private var _discontinuityOnNextSegment:Boolean = false;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.denivip.osmf.net.httpstreaming.HTTPHLSStreamSource") as Logger;
			private var previouslyLoggedState:String = null;
			
			private var loggedStreamName:String = null;
		}

	}
}
