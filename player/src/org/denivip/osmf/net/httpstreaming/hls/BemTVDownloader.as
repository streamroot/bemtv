package org.denivip.osmf.net.httpstreaming.hls
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.Timer;

	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.events.HTTPStreamingEventReason;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataMode;
	import org.osmf.utils.OSMFSettings;
	import org.osmf.net.httpstreaming.HTTPStreamDownloader;

	import org.denivip.osmf.net.httpstreaming.hls.BemTVURLStream;

	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
	}


	/**
	 * @private
	 *
	 * HTTPStreamDownloader is an utility class which is responsable for
	 * downloading and local buffering HDS streams.
	 *
	 * @langversion 3.0
	 * @playerversion Flash 10.1
	 * @playerversion AIR 1.5
	 * @productversion OSMF 1.6
	 */
	public class BemTVDownloader
	{
		/**
		 * Default constructor.
		 *
		 * @param dispatcher A dispatcher object used by HTTPStreamDownloader to
		 * 					 dispatch any event.
		 **/
		public function BemTVDownloader()
		{
		}

		/**
		 * Returns true if the HTTP stream source is open and false otherwise.
		 **/
		public function get isOpen():Boolean
		{
			return _isOpen;
		}

		/**
		 * Returns true if the HTTP stream source has been completly downloaded.
		 **/
		public function get isComplete():Boolean
		{
			return _isComplete;
		}

		/**
		 * Returns true if the HTTP stream source has data available for processing.
		 **/
		public function get hasData():Boolean
		{
			return _hasData;
		}

		/**
		 * Returns true if the HTTP stream source has not been found or has some errors.
		 */
		public function get hasErrors():Boolean
		{
			return _hasErrors;
		}

		/**
		 * Returns the duration of the last download in seconds.
		 */
		public function get downloadDuration():Number
		{
			return _downloadDuration;
		}

		/**
		 * Returns the bytes count for the last download.
		 */
		public function get downloadBytesCount():Number
		{
			return _downloadBytesCount;
		}

		/**
		 * Opens the HTTP stream source and start downloading the data
		 * immediately. It will automatically close any previous opended
		 * HTTP stream source.
		 **/
		public function open(request:URLRequest, dispatcher:IEventDispatcher, timeout:Number):void
		{
			if (isOpen || (_urlStream != null && _urlStream.connected))
				close();

			if(request == null)
			{
				throw new ArgumentError("Null request in HTTPStreamDownloader open method.");
			}

			_isComplete = false;
			_hasData = false;
			_hasErrors = false;

			_dispatcher = dispatcher;
			if (_savedBytes == null)
			{
				_savedBytes = new ByteArray();
			}

			if (_urlStream == null)
			{
				_urlStream = new BemTVURLStream();
				_urlStream.addEventListener(Event.OPEN, onOpen);
				_urlStream.addEventListener(Event.COMPLETE, onComplete);
				_urlStream.addEventListener(ProgressEvent.PROGRESS, onProgress);
				_urlStream.addEventListener(IOErrorEvent.IO_ERROR, onError);
				_urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			}

			if (_timeoutTimer == null && timeout != -1)
			{
				_timeoutTimer = new Timer(timeout, 1);
				_timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeout);
			}

			if (_urlStream != null)
			{
				_timeoutInterval = timeout;
				_request = request;
				CONFIG::LOGGING
				{
					logger.debug("Loading (timeout=" + _timeoutInterval + ", retry=" + _currentRetry + "):" + _request.url.toString());
				}

				_downloadBeginDate = null;
				_downloadBytesCount = 0;
				startTimeoutMonitor(_timeoutInterval);
				_urlStream.load(_request);
			}
		}

		/**
		 * Closes the HTTP stream source. It closes any open connection
		 * and also clears any buffered data.
		 *
		 * @param dispose Flag to indicate if the underlying objects should
		 * 				  also be disposed. Defaults to <code>false</code>
		 * 				  as is recommended to reuse these objects.
		 **/
		public function close(dispose:Boolean = false):void
		{
			CONFIG::LOGGING
			{
				if (_request != null)
				{
					logger.debug("Closing :" + _request.url.toString());
				}
			}

			stopTimeoutMonitor();

			_isOpen = false;
			_isComplete = false;
			_hasData = false;
			_hasErrors = false;
			_request = null;

			if (_timeoutTimer != null)
			{
				_timeoutTimer.stop();
				if (dispose)
				{
					_timeoutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimeout);
					_timeoutTimer = null;
				}
			}

			if (_urlStream != null)
			{
				if (_urlStream.connected)
				{
					_urlStream.close();
				}
				if (dispose)
				{
					_urlStream.removeEventListener(Event.OPEN, onOpen);
					_urlStream.removeEventListener(Event.COMPLETE, onComplete);
					_urlStream.removeEventListener(ProgressEvent.PROGRESS, onProgress);
					_urlStream.removeEventListener(IOErrorEvent.IO_ERROR, onError);
					_urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
					_urlStream = null;
				}
			}

			if (_savedBytes != null)
			{
				_savedBytes.length = 0;
				if (dispose)
				{
					_savedBytes = null;
				}
			}
		}

		/**
		 * Return the total number of available bytes,
		 * includes both saved bytes and bytes in the underlying url stream
		 **/
		public function get totalAvailableBytes():int
		{
			if (!isOpen)
			{
				return 0;
			}
			else
			{
				return _savedBytes.bytesAvailable + _urlStream.bytesAvailable;
			}
		}

		/**
		 * Returns a buffer containing a specified number of bytes or null if
		 * there are not enough bytes available.
		 *
		 * @param numBytes The number of the bytes to be returned.
		 **/
		public function getBytes(numBytes:int = 0):IDataInput
		{
			if ( !isOpen || numBytes < 0)
			{
				return null;
			}

			if (numBytes == 0)
			{
				numBytes = 1;
			}

			var totalAvailableBytes:int = this.totalAvailableBytes;
			if (totalAvailableBytes == 0)
			{
				_hasData = false;
			}

			if (totalAvailableBytes < numBytes)
			{
				return null;
			}

			// use first the previous saved bytes and complete as needed
			// with bytes from the actual stream.
			if (_savedBytes.bytesAvailable)
			{
				var needed:int = numBytes - _savedBytes.bytesAvailable;
				if (needed > 0)
				{
					_urlStream.readBytes(_savedBytes, _savedBytes.length, needed);
				}

				return _savedBytes;
			}

			// make sure that the saved bytes buffer is empty
			// and return the actual stream.
			_savedBytes.length = 0;
			return _urlStream;
		}

		/**
		 * Clears the saved bytes.
		 **/
		public function clearSavedBytes():void
		{
			if(_savedBytes == null)
			{
				// called after dispose
				return;
			}
			_savedBytes.length = 0;
			_savedBytes.position = 0;
		}

		/**
		 * Copies the specified number of bytes from source into the saved bytes.
		 **/
		public function appendToSavedBytes(source:IDataInput, count:uint):void
		{
			if(_savedBytes == null)
			{
				// called after dispose
				return;
			}
			source.readBytes(_savedBytes, _savedBytes.length, count);
		}

		/**
		 * Saves all remaining bytes from the HTTP stream source to
		 * internal buffer to be available in the future.
		 **/
		public function saveRemainingBytes():void
		{
			if(_savedBytes == null)
			{
				// called after dispose
				return;
			}
			if (_urlStream != null && _urlStream.connected && _urlStream.bytesAvailable)
			{
				_urlStream.readBytes(_savedBytes, _savedBytes.length);
			}
			else
			{
				// no remaining bytes
			}
		}

		/**
		 * Returns a string representation of this object.
		 **/
		public function toString():String
		{
			// TODO : add request url to this string
			return "HTTPStreamSource";
		}

		/// Event handlers
		/**
		 * @private
		 * Called when the connection has been open.
		 **/
		private function onOpen(event:Event):void
		{
			_isOpen = true;
		}

		/**
		 * @private
		 * Called when all data has been downloaded.
		 **/
		private function onComplete(event:Event):void
		{
			if (_downloadBeginDate == null)
			{
				_downloadBeginDate = new Date();
			}

			_downloadEndDate = new Date();
			_downloadDuration = (_downloadEndDate.valueOf() - _downloadBeginDate.valueOf())/1000.0;

			_isComplete = true;
			_hasErrors = false;

			CONFIG::LOGGING
			{
				logger.debug("Loading complete. It took " + _downloadDuration + " sec and " + _currentRetry + " retries to download " + _downloadBytesCount + " bytes.");
			}

			if (_dispatcher != null)
			{
				var streamingEvent:HTTPStreamingEvent = new HTTPStreamingEvent(
					HTTPStreamingEvent.DOWNLOAD_COMPLETE,
					false, // bubbles
					false, // cancelable
					0, // fragment duration
					null, // scriptDataObject
					FLVTagScriptDataMode.NORMAL, // scriptDataMode
					_request.url, // urlString
					_downloadBytesCount, // bytesDownloaded
					HTTPStreamingEventReason.NORMAL, // reason
					this as HTTPStreamDownloader); // downloader
				_dispatcher.dispatchEvent(streamingEvent);
			}
		}

		/**
		 * @private
		 * Called when additional data has been received.
		 **/
		private function onProgress(event:ProgressEvent):void
		{
			if (_downloadBeginDate == null)
			{
				_downloadBeginDate = new Date();
			}

			if (_downloadBytesCount == 0)
			{
				if (_timeoutTimer != null)
				{
					stopTimeoutMonitor();
				}
				_currentRetry = 0;

				_downloadBytesCount = event.bytesTotal;
				CONFIG::LOGGING
				{
					logger.debug("Loaded " + event.bytesLoaded + " bytes from " + _downloadBytesCount + " bytes.");
				}
			}

			_hasData = true;

			if(_dispatcher != null)
			{
				var streamingEvent:HTTPStreamingEvent = new HTTPStreamingEvent(
					HTTPStreamingEvent.DOWNLOAD_PROGRESS,
					false, // bubbles
					false, // cancelable
					0, // fragment duration
					null, // scriptDataObject
					FLVTagScriptDataMode.NORMAL, // scriptDataMode
					_request.url, // urlString
					0, // bytesDownloaded
					HTTPStreamingEventReason.NORMAL, // reason
					this as HTTPStreamDownloader); // downloader
				_dispatcher.dispatchEvent(streamingEvent);
			}

		}

		/**
		 * @private
		 * Called when an error occurred while downloading.
		 **/
		private function onError(event:Event):void
		{
			if (_timeoutTimer != null)
			{
				stopTimeoutMonitor();
			}

			if (_downloadBeginDate == null)
			{
				_downloadBeginDate = new Date();
			}
			_downloadEndDate = new Date();
			_downloadDuration = (_downloadEndDate.valueOf() - _downloadBeginDate.valueOf()) / 1000.0;

			_isComplete = false;
			_hasErrors = true;

			CONFIG::LOGGING
			{
				logger.error("Loading failed. It took " + _downloadDuration + " sec and " + _currentRetry + " retries to fail while downloading [" + _request.url + "].");
				logger.error("URLStream error event: " + event);
			}

			if (_dispatcher != null)
			{
				var reason:String = HTTPStreamingEventReason.NORMAL;
				if(event.type == Event.CANCEL)
				{
					reason = HTTPStreamingEventReason.TIMEOUT;
				}
				var streamingEvent:HTTPStreamingEvent = new HTTPStreamingEvent(
					HTTPStreamingEvent.DOWNLOAD_ERROR,
					false, // bubbles
					false, // cancelable
					0, // fragment duration
					null, // scriptDataObject
					FLVTagScriptDataMode.NORMAL, // scriptDataMode
					_request.url, // urlString
					0, // bytesDownloaded
					reason, // reason
					this as HTTPStreamDownloader); // downloader
				_dispatcher.dispatchEvent(streamingEvent);
			}
		}

		/**
		 * @private
		 * Starts the timeout monitor.
		 */
		private function startTimeoutMonitor(timeout:Number):void
		{
			if (_timeoutTimer != null)
			{
				if (timeout > 0)
				{
					_timeoutTimer.delay = timeout;
				}
				_timeoutTimer.reset();
				_timeoutTimer.start();
			}
		}

		/**
		 * @private
		 * Stops the timeout monitor.
		 */
		private function stopTimeoutMonitor():void
		{
			if (_timeoutTimer != null)
			{
				_timeoutTimer.stop();
			}
		}

		/**
		 * @private
		 * Event handler called when no data was received but the timeout interval passed.
		 */
		private function onTimeout(event:TimerEvent):void
		{
			CONFIG::LOGGING
			{
				logger.error("Timeout while trying to download [" + _request.url + "]");
				logger.error("Canceling and retrying the download.");
			}

			if (OSMFSettings.hdsMaximumRetries > -1)
			{
				_currentRetry++;
			}

			if (
				OSMFSettings.hdsMaximumRetries == -1
				||  (OSMFSettings.hdsMaximumRetries != -1 && _currentRetry < OSMFSettings.hdsMaximumRetries)
			)
			{
				open(_request, _dispatcher, _timeoutInterval + OSMFSettings.hdsTimeoutAdjustmentOnRetry);
			}
			else
			{
				close();
				onError(new Event(Event.CANCEL));
			}
		}

		/// Internals
		private var _isOpen:Boolean = false;
		private var _isComplete:Boolean = false;
		private var _hasData:Boolean = false;
		private var _hasErrors:Boolean = false;
		private var _savedBytes:ByteArray = null;
		private var _urlStream:BemTVURLStream = null;
		private var _request:URLRequest = null;
		private var _dispatcher:IEventDispatcher = null;

		private var _downloadBeginDate:Date = null;
		private var _downloadEndDate:Date = null;
		private var _downloadDuration:Number = 0;
		private var _downloadBytesCount:Number = 0;

		private var _timeoutTimer:Timer = null;
		private var _timeoutInterval:Number = 1000;
		private var _currentRetry:Number = 0;

		CONFIG::LOGGING
		{
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.net.httpstreaming.HTTPStreamDownloader");
		}
	}
}

