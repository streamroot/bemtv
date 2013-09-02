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
package org.osmf.net.httpstreaming
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.net.httpstreaming.flv.FLVTag;
	import org.osmf.net.httpstreaming.flv.FLVTagAudio;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
	import org.osmf.net.httpstreaming.flv.FLVTagVideo;
	import org.osmf.utils.OSMFStrings;

	CONFIG::LOGGING 
	{	
		import org.osmf.logging.Log;
		import org.osmf.logging.Logger;
	}

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * HTTPStreamMixer class supports mixing alternate and media data
	 * provided by different sources.
	 * 
	 * @langversion 3.0
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @productversion OSMF 1.6
	 */
	public class HTTPStreamMixer extends EventDispatcher implements IHTTPStreamSource
	{
		/**
		 * Default constructor.
		 */
		public function HTTPStreamMixer(dispatcher:IEventDispatcher)
		{
			if (dispatcher == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			_dispatcher = dispatcher;
			
			// we setup additional high priority event listeners in order to block
			// DVRInfo, BEGIN_FRAGMENT and END_FRAGMENT events dispatched by the alternate 
			// source - events which may confuse the listening clients
			addEventListener(DVRStreamInfoEvent.DVRSTREAMINFO, 			onDVRStreamInfo, 		false, HIGH_PRIORITY, true);
			addEventListener(HTTPStreamingEvent.SCRIPT_DATA, 			onScriptData, 			false, HIGH_PRIORITY, true);
			addEventListener(HTTPStreamingEvent.BEGIN_FRAGMENT, 		onBeginFragment, 		false, HIGH_PRIORITY, true);
			addEventListener(HTTPStreamingEvent.END_FRAGMENT, 			onEndFragment, 			false, HIGH_PRIORITY, true);
			addEventListener(HTTPStreamingEvent.TRANSITION, 			onHTTPStreamingEvent,	false, HIGH_PRIORITY, true);
			addEventListener(HTTPStreamingEvent.TRANSITION_COMPLETE, 	onHTTPStreamingEvent,	false, HIGH_PRIORITY, true);
			addEventListener(HTTPStreamingEvent.DOWNLOAD_ERROR,			onHTTPStreamingEvent,	false, HIGH_PRIORITY, true);
			
			setState(HTTPStreamingState.INIT);
			
			_alternateIgnored = true;
		}
	
		/**
		 * @inheritDoc
		 */
		public function get isReady():Boolean
		{
			// we are interested only by the media track which is the one which dictates the timeline
			return (video != null && video.source.isReady);
		}

		/**
		 * @inheritDoc
		 */
		public function get endOfStream():Boolean
		{
			// we are interested only by the media track which is the one which dictates the timeline
			return (video != null && video.source.endOfStream);
		}

		/**
		 * @inheritDoc
		 */
		public function get hasErrors():Boolean
		{
			// we are interested only by the media track which is the one which dictates the timeline
			return (video != null && video.source.hasErrors);
		}

		/**
		 *  Closes all associated sources.
		 */
		public function close():void
		{
			setState(HTTPStreamingState.HALT);
			
			clearBuffers();
			
			if (_alternateHandler != null)
			{
				_alternateHandler.close();
			}
			if (_desiredAlternateHandler != null && _desiredAlternateHandler != _alternateHandler)
			{
				_desiredAlternateHandler.close();
			}
			if (_mediaHandler != null)
			{
				_mediaHandler.close();
			}
			if (_desiredMediaHandler != null && _desiredMediaHandler != _mediaHandler)
			{
				_desiredMediaHandler.close();
			}
		}
		
		/**
		 * Seeks to the specified offset in stream.
		 */
		public function seek(offset:Number):void
		{
			// For now we just implement a plain seek without considering
			// any of the already downloaded data - a good place to 
			// think about some "fake" in buffer seeking.
			// XXX Here we need to implement enhanced seeking
			
			setState(HTTPStreamingState.SEEK);
			
			clearBuffers();
			
			_currentTime = 0;
			_alternateIgnored = (_alternateHandler == null);;
			updateFilters();
			
			if (_mediaHandler != null)
			{
				_mediaHandler.source.seek(offset);
			}
			if (_desiredMediaHandler != null && _desiredMediaHandler != _mediaHandler)
			{
				_desiredMediaHandler.source.seek(offset);
			}
			if (_alternateHandler != null)
			{
				_alternateHandler.source.seek(offset);
			}
			if (_desiredAlternateHandler != null && _desiredAlternateHandler != _alternateHandler)
			{
				_desiredAlternateHandler.source.seek(offset);
			}
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
		 * Handler for alternate source.
		 */
		public function get audio():IHTTPStreamHandler
		{
			return _desiredAlternateHandler;
		}
		public function set audio(value:IHTTPStreamHandler):void
		{
			if (_desiredAlternateHandler != value)
			{
				CONFIG::LOGGING
				{
					logger.debug( value == null ? "No audio source." : "Specific audio source selected.");
				}
				
				_desiredAlternateHandler = value;
				_alternateNeedsInitialization = true;
				
				_dispatcher.dispatchEvent(
					new HTTPStreamingEvent(
						HTTPStreamingEvent.TRANSITION,
						false,
						false,
						NaN,
						null,
						null,
						(_desiredAlternateHandler != null ? _desiredAlternateHandler.streamName : null)
					)
				);
			}
		}
		
		/**
		 * Handler for media source.
		 */
		public function get video():IHTTPStreamHandler
		{
			return _desiredMediaHandler;
		}
		public function set video(value:IHTTPStreamHandler):void
		{
			if (value == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			if (_desiredMediaHandler != value)
			{
				CONFIG::LOGGING
				{
					logger.debug("Video source selected.");
				}
				
				_desiredMediaHandler = value;
				_mediaNeedsInitialization = true;
			}
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
			
			switch(_state)
			{
				case HTTPStreamingState.INIT:
					// do nothing.
					break;
				
				case HTTPStreamingState.SEEK:
					// we just wait a little bit more until we go to decide
					// what should we consume
					setState(HTTPStreamingState.READ);
					break;
				
				case HTTPStreamingState.READ:
					// do the mixing
					bytes = internalMixBytes();
					if (bytes.length == 0)
					{
						bytes = null;
					}
					else
					{
						bytes.position = 0;
					}
					
					// check to see if the mixer needs to update any handler
					// this is better to be done at tag boundry
					if (
							(_mediaNeedsInitialization && _mediaTag == null)
						|| 	(_alternateNeedsInitialization && _alternateTag == null)
					)
					{
						updateHandlers();
						updateFilters();
					}
					
					if (_alternateNeedsSynchronization && (_mediaTime != -1 || _alternateTime != -1))
					{
						_alternateNeedsSynchronization = false;
						
						if (_alternateHandler != null)
						{
							var alternateSynchronizationTime:int = _alternateTime != -1 ? _alternateTime : _mediaTime;
							CONFIG::LOGGING
							{
								logger.debug("Synchronizing alternate packets. (currentTime = " + _currentTime + ", mediaTime = " + _mediaTime + ", alternateSyncTime =" + alternateSynchronizationTime + ").");
							}
							_alternateHandler.source.seek(alternateSynchronizationTime / 1000);
						}
					}

					// check if we need to request additional data from sources 
					_mediaNeedsMoreData =   !_mediaTagDataLoaded 
										 ||	(_mediaInput.bytesAvailable == 0)
										 || (_mediaInput.bytesAvailable != 0 && _mediaTag == null);	

					_alternateNeedsMoreData = 	!_alternateTagDataLoaded 
										 ||	(_alternateInput.bytesAvailable == 0)
										 || (_alternateInput.bytesAvailable != 0 && _alternateTag == null);
				
					if (_mediaNeedsMoreData || _alternateNeedsMoreData)
					{
						var alternateBytes:ByteArray = null;
						if (!_alternateIgnored && _alternateNeedsMoreData && _alternateHandler != null && _alternateHandler.source.isReady)
						{
							alternateBytes = _alternateHandler.source.getBytes();
							if (alternateBytes == null && (_alternateHandler.source.hasErrors || _alternateHandler.source.endOfStream))
							{
								CONFIG::LOGGING
								{
									logger.debug("Alternate audio track unavailable.");
								}
								
								_dispatcher.dispatchEvent(
									new HTTPStreamingEvent(
										HTTPStreamingEvent.ACTION_NEEDED,
										false,
										false,
										NaN,
										null,
										null,
										(_alternateHandler != null ? _alternateHandler.streamName : null)
									)
								);
								
								_alternateIgnored = true;
								updateFilters();
							}
						}	
						var mediaBytes:ByteArray = null;
						if (_mediaNeedsMoreData && _mediaHandler != null && _mediaHandler.source.isReady)
						{
							mediaBytes = _mediaHandler.source.getBytes();	
						}
						if (mediaBytes != null || alternateBytes != null)
						{
							updateBuffers(mediaBytes, alternateBytes);
						}
					}

					break;
			}
			
			return bytes;
		}
		
		/**
		 * @private
		 * 
		 * Mixes two media streams based on their time codes.
		 */
		private function internalMixBytes():ByteArray
		{
			var mixedBytes:ByteArray = new ByteArray();
			var keepProcessing:Boolean = true;
			
			while (keepProcessing)
			{
				// process media input and get the next media tag
				if (_mediaTag == null)
				{
					_mediaTagDataLoaded = false;
				}
				while (!_mediaTagDataLoaded && _mediaInput.bytesAvailable)
				{
					// if we don't have enough data to read the tag header then return
					// any mixed tags and wait for addional data to be added to media buffer
					if ((_mediaTag == null) && (_mediaInput.bytesAvailable < FLVTag.TAG_HEADER_BYTE_COUNT) )
					{
						return mixedBytes;
					}

					// if we have enough data to read header, read the header and detect tag type
					if (_mediaTag == null)
					{
						_mediaTag = createTag( _mediaInput.readByte());
						_mediaTag.readRemainingHeader(_mediaInput);
					}

					if (!_mediaTagDataLoaded)
					{
						// if we don't have enough data to read the tag data then return
						// any mixed tags and wait for addional data to be added to media buffer
						if (_mediaInput.bytesAvailable < (_mediaTag.dataSize + FLVTag.PREV_TAG_BYTE_COUNT))
						{
							return mixedBytes;
						}
						
						// any tags whose timestamp are smaller than the latest media mixing time
						// and the tags which are marked for filtering
						if (shouldFilterTag(_mediaTag, _mediaFilterTags))
						{
							CONFIG::LOGGING
							{
								if (_mediaTag is FLVTagVideo)
								{
									droppedVideoFrames++;
									totalDroppedVideoFrames++;
								}
							}
							
							_mediaInput.position += _mediaTag.dataSize + FLVTag.PREV_TAG_BYTE_COUNT;
							_mediaTag = null;
						}
						else					
						{
							_mediaTag.readData(_mediaInput);
							_mediaTag.readPrevTag(_mediaInput);
							_mediaTagDataLoaded = true;
							updateTimes(_mediaTag);
						}
					}
				}
				
				// process alternate input and get the next alternate tag
				if (_alternateTag == null)
				{
					_alternateTagDataLoaded = false;
				}
				while (!_alternateIgnored && !_alternateTagDataLoaded && _alternateInput.bytesAvailable)
				{
					// if we don't have enough data to read the tag header then return
					// any mixed tags and wait for addional data to be added to alternate buffer
					if ((_alternateTag == null) && (_alternateInput.bytesAvailable < FLVTag.TAG_HEADER_BYTE_COUNT) )
					{
						return mixedBytes;
					}
					
					// if we have enough data to read header, read the header and detect tag type
					if (_alternateTag == null)
					{
						_alternateTag = createTag( _alternateInput.readByte());
						_alternateTag.readRemainingHeader(_alternateInput);
					}
					
					if (!_alternateTagDataLoaded)
					{
						// if we don't have enough data to read the tag data then return
						// any mixed tags and wait for addional data to be added to alternate buffer
						if (_alternateInput.bytesAvailable < (_alternateTag.dataSize + FLVTag.PREV_TAG_BYTE_COUNT))
						{
							return mixedBytes;
						}
						
						// skip any media tags which may be present in the alternate buffer or any
						// tags whose timestamp are smaller than the latest alternate mixing time
						if (shouldFilterTag(_alternateTag, _alternateFilterTags))
						{
							CONFIG::LOGGING
							{
								if (_alternateTag is FLVTagAudio)
								{
									droppedAudioFrames++;
									totalDroppedAudioFrames++;
								}
							}

							_alternateInput.position += _alternateTag.dataSize + FLVTag.PREV_TAG_BYTE_COUNT;
							_alternateTag = null;
						}
						else					
						{
							_alternateTag.readData(_alternateInput);
							_alternateTag.readPrevTag(_alternateInput);
							_alternateTagDataLoaded = true;
							updateTimes(_alternateTag);
						}
					}
				} 
				
				if (_mediaTagDataLoaded || _alternateTagDataLoaded)
				{
					CONFIG::LOGGING
					{
						if (checkVideoFrame && _mediaTag is FLVTagVideo)
						{
							checkVideoFrame = false;
							
							var type:int = FLVTagVideo(_mediaTag).frameType;
							var time:Number = _mediaTag.timestamp;
							if (type != FLVTagVideo.FRAME_TYPE_KEYFRAME)
							{
								logger.warn("Frame at " + time + " is not a key frame. This could lead to video not being displayed.");
							}
						}
					}
					if (_alternateIgnored)
					{
						_currentTime = _mediaTag.timestamp;
						_mediaTag.write(mixedBytes);
						_mediaTag = null;
						keepProcessing = true;
					} 
					else 
					{
						if (_mediaTime > -1 || _alternateTime > -1)
						{
							if (
								(_alternateTag != null) 
								&& _alternateTagDataLoaded
								&& (_alternateTag.timestamp >= _currentTime) 
								&& (_alternateTag.timestamp <= _mediaTime))
							{
								_currentTime = _alternateTag.timestamp;
								_alternateTag.write(mixedBytes);
								_alternateTag = null;
							}
							else if (
								(_mediaTag != null)
								&& _mediaTagDataLoaded
								&& (_mediaTag.timestamp >= _currentTime) 
								&& (_mediaTag.timestamp <= _alternateTime ))
							{
								_currentTime = _mediaTag.timestamp;
								_mediaTag.write(mixedBytes);
								_mediaTag = null;	
							}
							
							keepProcessing = (_mediaInput.bytesAvailable && _alternateInput.bytesAvailable);
						}
						else
						{
							if (_alternateTime != -1 && _alternateNeedsSynchronization)
							{
								_alternateNeedsSynchronization = false;
							}
							keepProcessing = false;
						}
					}
				}
				else
				{
					keepProcessing = false;
				}
			}
			
			return mixedBytes;
		}

		/**
		 * @private
		 * 
		 * Updates the internal buffers with more data.
		 */
		private function updateBuffers(mediaInput:IDataInput, alternateInput:IDataInput):void
		{
			// we remove the already processed data from internal buffers
			// only if we processed at least half of the internal buffers
			var unprocessedBytes:ByteArray = new ByteArray();
			if (
				_mediaTag == null 
				&& _mediaInput.position != 0 
				&& _mediaInput.bytesAvailable < (_mediaInput.length / 2)
			)
			{
				_mediaInput.readBytes(unprocessedBytes, 0, _mediaInput.bytesAvailable);
				_mediaInput.clear();
				unprocessedBytes.readBytes(_mediaInput, 0, unprocessedBytes.bytesAvailable);
				unprocessedBytes.clear();
			}
			
			if (
				_alternateTag == null
				&& _alternateInput.position != 0 
				&& _alternateInput.bytesAvailable < (_alternateInput.length / 2)
			)
			{
				_alternateInput.readBytes(unprocessedBytes, 0, _alternateInput.bytesAvailable);
				_alternateInput.clear();
				unprocessedBytes.readBytes(_alternateInput, 0, unprocessedBytes.bytesAvailable);
				unprocessedBytes.clear();
			}
			
			// we are adding the new available data to internal buffers
			// to allow for further processing
			if (mediaInput != null && mediaInput.bytesAvailable)
			{
				mediaInput.readBytes(_mediaInput, _mediaInput.length, mediaInput.bytesAvailable);
			}
			if (alternateInput != null && alternateInput.bytesAvailable)
			{
				alternateInput.readBytes(_alternateInput, _alternateInput.length, alternateInput.bytesAvailable);
			}
		}	

		/**
		 * @private
		 * 
		 * Clears internal buffers.
		 */
		private function clearBuffers():void
		{
			clearAlternateBuffers();
			clearMediaBuffers();
		}
		
		/**
		 * @private
		 * 
		 * Clears the internal alternate buffers when seeking or closing the mixer. It is important
		 * to do this due the fact that in order for the mix to work, the buffers should 
		 * be aligned at tag boundry.
		 */ 
		private function clearAlternateBuffers():void
		{
			_alternateTime = -1;
			_alternateTag = null;
			_alternateTagDataLoaded = false;
			_alternateInput.clear();
		}
		
		/**
		 * @private
		 * 
		 * Clears the internal media buffers when seeking or closing the mixer. It is important
		 * to do this due the fact that in order for the mix to work, the buffers should 
		 * be aligned at tag boundry.
		 */ 
		private function clearMediaBuffers():void
		{
			_mediaTime = -1;
			_mediaTag = null;
			_mediaTagDataLoaded = false;
			_mediaInput.clear();
		}

		/**
		 * @private
		 * 
		 * Create a specific tag based on the provided type.
		 */
		private function createTag(type:int):FLVTag
		{
			var tag:FLVTag = null;
			
			switch (type)
			{
				case FLVTag.TAG_TYPE_AUDIO:
				case FLVTag.TAG_TYPE_ENCRYPTED_AUDIO:
					tag = new FLVTagAudio(type);
					break;
				
				case FLVTag.TAG_TYPE_VIDEO:
				case FLVTag.TAG_TYPE_ENCRYPTED_VIDEO:
					tag = new FLVTagVideo(type);
					break;
				
				case FLVTag.TAG_TYPE_SCRIPTDATAOBJECT:
				case FLVTag.TAG_TYPE_ENCRYPTED_SCRIPTDATAOBJECT:
					tag = new FLVTagScriptDataObject(type);
					break;
				
				default:
					tag = new FLVTag(type);	// the generic case
					break;
			}	
			
			return tag;
		}
		
		/**
		 * @private
		 * 
		 * Checks if a tag should be filter out based on its type.
		 */
		private function shouldFilterTag(tag:FLVTag, filterTags:uint):Boolean
		{
			if (tag == null)
			{
				return true;
			}
			
			// if the timestamp is lower than the current time
			if (tag.timestamp < _currentTime)
			{
				return true;
			}
			
			switch (tag.tagType)
			{
				case FLVTag.TAG_TYPE_AUDIO:
				case FLVTag.TAG_TYPE_ENCRYPTED_AUDIO:
					return  (FILTER_AUDIO & filterTags) || (tag.timestamp < _alternateTime);
					break;
				
				case FLVTag.TAG_TYPE_VIDEO:
				case FLVTag.TAG_TYPE_ENCRYPTED_VIDEO:
					return (FILTER_VIDEO & filterTags) || (tag.timestamp < _mediaTime);
					break;
				
				case FLVTag.TAG_TYPE_SCRIPTDATAOBJECT:
				case FLVTag.TAG_TYPE_ENCRYPTED_SCRIPTDATAOBJECT:
					return (FILTER_DATA & filterTags) || (tag.timestamp < _mediaTime);
					break;
			}	
			
			return false;
			
		}
		
		/**
		 * @private
		 * 
		 * Update time used to synchronize both tracks.
		 */
		private function updateTimes(tag:FLVTag):void
		{
			if (tag != null)
			{
				if (tag is FLVTagAudio)
				{
					_alternateTime = tag.timestamp;
				}
				else
				{
					_mediaTime = tag.timestamp;
				}
			}
		}
		
		/**
		 * @private
		 * 
		 * Method which updates the alternate and video handlers.
		 */
		private function updateHandlers():void
		{
			if (_mediaNeedsInitialization)
			{
				if (_mediaHandler != _desiredMediaHandler)
				{
					if (_mediaHandler != null)
					{
						_mediaHandler.close();
						_mediaHandler = null;
					}
					_mediaHandler = _desiredMediaHandler;
					clearMediaBuffers();
				}
				_mediaNeedsInitialization = false;
			}
			
			if (_alternateNeedsInitialization)
			{
				if (_alternateHandler != _desiredAlternateHandler)
				{
					if (_alternateHandler != null)
					{
						_alternateHandler.close();
						_alternateHandler = null;
					}
					_alternateHandler = _desiredAlternateHandler;
					clearAlternateBuffers();
					
					_alternateNeedsSynchronization = true;
					_alternateIgnored = (_alternateHandler == null);
					
				}
				_alternateNeedsInitialization = false;
								
				_dispatcher.dispatchEvent(
					new HTTPStreamingEvent(
						HTTPStreamingEvent.TRANSITION_COMPLETE,
						false,
						false,
						NaN,
						null,
						null,
						(_alternateHandler != null ? _alternateHandler.streamName : null)
					)
				);
			}
		}
		
		/**
		 * @private
		 * 
		 * Method which updates the alternate and media filters.
		 */
		private function updateFilters():void
		{
			if (_alternateIgnored)
			{
				_mediaFilterTags = FILTER_NONE;
				_alternateFilterTags = FILTER_ALL;
			}
			else
			{
				_mediaFilterTags = FILTER_AUDIO;
				_alternateFilterTags = FILTER_VIDEO;
			}
		}
		
		/**
		 * @private
		 * Saves the current state of the object and sets it to the value specified.
		 **/ 
		private function setState(value:String):void
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
		 * Event handler for SCRIPT_DATA event. We forward this  event for further processing.
		 */ 
		private function onScriptData(event:HTTPStreamingEvent):void
		{
			// when mixing in alternative audio tracks we need to
			// block onMetadata and onXMPData messages generated 
			// by the alternate source as they may alter duration 
			// of the main media
			if (_alternateHandler != null && _alternateHandler.streamName == event.url)
			{
				var methodName:* = event.scriptDataObject.objects[0];
				if (methodName == "onMetaData" || methodName == "onXMPData")
				{
					return;
				}
			}
			_dispatcher.dispatchEvent(event);
		}
		
		/**
		 * @private
		 * 
		 * Event handler for DVRStreamInfo event. We just want to block the event dispatched
		 * by the alternate handler as the media handler is the only owner of the timeline.
		 */ 
		private function onDVRStreamInfo(event:DVRStreamInfoEvent):void
		{
			_dispatcher.dispatchEvent(event);
		}
		
		/**
		 * @private
		 * 
		 * Event handler for begin fragment.
		 */
		private function onBeginFragment(event:HTTPStreamingEvent):void
		{
			if (_mediaHandler != null && _mediaHandler.streamName == event.url)
			{
				if (_alternateHandler != null && _alternateIgnored)
				{
					_alternateIgnored = false;
					_alternateNeedsSynchronization = true;
				}
				
				CONFIG::LOGGING
				{
					logger.debug("dvf=" + droppedVideoFrames + "(" + totalDroppedVideoFrames + "), daf=" + droppedAudioFrames + "(" + totalDroppedAudioFrames + ").");
					
					droppedVideoFrames = 0;
					droppedVideoFrames = 0;
					checkVideoFrame = true;
				}
				
				_dispatcher.dispatchEvent(event);
			}
		}

		/**
		 * @private
		 * 
		 * Event handler for end fragment.
		 */
		private function onEndFragment(event:HTTPStreamingEvent):void
		{
			if (_mediaHandler != null && _mediaHandler.streamName == event.url)
			{
				_dispatcher.dispatchEvent(event);
			}
		}
		
		/**
		 * @private
		 * 
		 * Event handler for all streaming events that we just forward 
		 * for further processing.
		 */
		private function onHTTPStreamingEvent(event:HTTPStreamingEvent):void
		{
			_dispatcher.dispatchEvent(event);
		}
		
		/// Internals
		private static const FILTER_NONE:uint = 0;
		private static const FILTER_VIDEO:uint = 1;
		private static const FILTER_AUDIO:uint = 2;
		private static const FILTER_DATA:uint = 4;
		private static const FILTER_ALL:uint = 255;
		
		private static const HIGH_PRIORITY:int = 10000;
		private var _dispatcher:IEventDispatcher = null;
		
		private	var _currentTime:uint = 0;
		private var _mediaTime:int = -1;
		private var _alternateTime:int = -1;
				
		private var _mediaTag:FLVTag = null;
		private var _mediaTagDataLoaded:Boolean = true;
		private	var _mediaInput:ByteArray = new ByteArray();
		private var _mediaFilterTags:uint = FILTER_NONE;
		private var _mediaHandler:IHTTPStreamHandler = null;
		private var _desiredMediaHandler:IHTTPStreamHandler = null;
		private var _mediaNeedsInitialization:Boolean = false;
		private var _mediaNeedsMoreData:Boolean = false;
		
		private var _alternateTag:FLVTag = null;
		private var _alternateTagDataLoaded:Boolean = true;
		private	var _alternateInput:ByteArray = new ByteArray();
		private var _alternateFilterTags:uint = FILTER_NONE;
		private var _alternateHandler:IHTTPStreamHandler = null;
		private var _desiredAlternateHandler:IHTTPStreamHandler = null;
		private var _alternateNeedsInitialization:Boolean = false;
		private var _alternateNeedsMoreData:Boolean = false;
		private var _alternateNeedsSynchronization:Boolean = true;
		private var _alternateIgnored:Boolean = false;
		
		private var _state:String = null;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.httpstreaming.HTTPStreamMixer");
			private var previouslyLoggedState:String = null;
			
			private var checkVideoFrame:Boolean = false;
			private var droppedVideoFrames:int = 0;
			private var droppedAudioFrames:int = 0;
			private var totalDroppedAudioFrames:int = 0;
			private var totalDroppedVideoFrames:int = 0;
		}

	}
}