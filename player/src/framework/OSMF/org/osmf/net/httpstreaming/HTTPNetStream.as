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
package org.osmf.net.httpstreaming
{
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamPlayOptions;
	import flash.net.NetStreamPlayTransitions;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetStreamCodes;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.net.httpstreaming.flv.FLVHeader;
	import org.osmf.net.httpstreaming.flv.FLVParser;
	import org.osmf.net.httpstreaming.flv.FLVTag;
	import org.osmf.net.httpstreaming.flv.FLVTagAudio;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataMode;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
	import org.osmf.net.httpstreaming.flv.FLVTagVideo;
	import org.osmf.utils.OSMFSettings;
	
	CONFIG::LOGGING 
	{	
		import org.osmf.logging.Log;
		import org.osmf.logging.Logger;
	}
	
	CONFIG::FLASH_10_1	
	{
		import flash.net.NetStreamAppendBytesAction;
		import flash.events.DRMErrorEvent;
		import flash.events.DRMStatusEvent;
	}
	
	[ExcludeClass]

	[Event(name="DVRStreamInfo", type="org.osmf.events.DVRStreamInfoEvent")]

	/**
	 * 
	 * @private
	 * 
	 * HTTPNetStream is a NetStream subclass which can accept input via the
	 * appendBytes method.  In general, the assumption is that a large media
	 * file is broken up into a number of smaller fragments.
	 * 
	 * There are two important aspects of working with an HTTPNetStream:
	 * 1) How to map a specific playback time to the media file fragment
	 * which holds the media for that time.
	 * 2) How to unmarshal the data from a media file fragment so that it can
	 * be fed to the NetStream as TCMessages. 
	 * 
	 * The former is the responsibility of HTTPStreamingIndexHandlerBase,
	 * the latter the responsibility of HTTPStreamingFileHandlerBase.
	 */	
	public class HTTPNetStream extends NetStream 
	{
		/**
		 * Constructor.
		 * 
		 * @param connection The NetConnection to use.
		 * @param indexHandler Object which exposes the index, which maps
		 * playback times to media file fragments.
		 * @param fileHandler Object which canunmarshal the data from a
		 * media file fragment so that it can be fed to the NetStream as
		 * TCMessages.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function HTTPNetStream( connection:NetConnection, factory:HTTPStreamingFactory, resource:URLResource = null)
		{
			super(connection);
			_resource = resource;
			_factory = factory;
			
			addEventListener(DVRStreamInfoEvent.DVRSTREAMINFO, 			onDVRStreamInfo);
			addEventListener(HTTPStreamingEvent.SCRIPT_DATA, 			onScriptData);
			addEventListener(HTTPStreamingEvent.BEGIN_FRAGMENT, 		onBeginFragment);
			addEventListener(HTTPStreamingEvent.END_FRAGMENT, 			onEndFragment);
			addEventListener(HTTPStreamingEvent.TRANSITION, 			onTransition);
			addEventListener(HTTPStreamingEvent.TRANSITION_COMPLETE, 	onTransitionComplete);
			addEventListener(HTTPStreamingEvent.ACTION_NEEDED, 			onActionNeeded);
			addEventListener(HTTPStreamingEvent.DOWNLOAD_ERROR,			onDownloadError);
			
			addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			
			CONFIG::FLASH_10_1
			{
				addEventListener(DRMErrorEvent.DRM_ERROR, onDRMError);
				addEventListener(DRMStatusEvent.DRM_STATUS, onDRMStatus);
			}
			
			this.bufferTime = OSMFSettings.hdsMinimumBufferTime;
			this.bufferTimeMax = 0;
			
			setState(HTTPStreamingState.INIT);
			
			_mixer = new HTTPStreamMixer(this);
			_mixer.video = new HTTPStreamSource(_factory, _resource, _mixer);
			
			_source = _mixer;
			
			_mainTimer = new Timer(OSMFSettings.hdsMainTimerInterval); 
			_mainTimer.addEventListener(TimerEvent.TIMER, onMainTimer);	
		}
		
		///////////////////////////////////////////////////////////////////////
		/// Public API overrides
		///////////////////////////////////////////////////////////////////////
		/**
		 * Plays the specified stream with respect to provided arguments.
		 */
		override public function play(...args):void 
		{
			processPlayParameters(args);
			CONFIG::LOGGING
			{
				logger.debug("Play initiated for [" + _playStreamName +"] with parameters ( start = " + _playStart.toString() + ", duration = " + _playForDuration.toString() +" ).");
			}
			
			// Signal to the base class that we're entering Data Generation Mode.
			super.play(null);
			
			// Before we feed any TCMessages to the Flash Player, we must feed
			// an FLV header first.
			var header:FLVHeader = new FLVHeader();
			var headerBytes:ByteArray = new ByteArray();
			header.write(headerBytes);
			attemptAppendBytes(headerBytes);
			
			// Initialize ourselves.
			_mainTimer.start();
			_initialTime = -1;
			_seekTime = -1;
			
			_notifyPlayStartPending = true;
			_notifyPlayUnpublishPending = false;
			
			changeSourceTo(_playStreamName, _playStart);
		}

		/**
		 * Plays the specified stream and supports dynamic switching and alternate audio streams. 
		 */
		override public function play2(param:NetStreamPlayOptions):void
		{
			switch(param.transition)
			{
				case NetStreamPlayTransitions.RESET:
					play(param.streamName, param.start, param.len);
					break;
				
				case NetStreamPlayTransitions.SWITCH:
					changeQualityLevelTo(param.streamName);
					break;
			
				case NetStreamPlayTransitions.SWAP:
					changeAudioStreamTo(param.streamName);
					break;
				
				default:
					// Not sure which other modes we should add support for.
					super.play2(param);
			}
		} 
		
		/**
		 * Seeks into the media stream for the specified offset in seconds.
		 */
		override public function seek(offset:Number):void
		{
			if(offset < 0)
			{
				offset = 0;		// FMS rule. Seek to <0 is same as seeking to zero.
			}
			
			// we can't seek before the playback starts 
			if (_state != HTTPStreamingState.INIT)    
			{
				if(_initialTime < 0)
				{
					_seekTarget = offset + 0;	// this covers the "don't know initial time" case, rare
				}
				else
				{
					_seekTarget = offset + _initialTime;
				}
				
				setState(HTTPStreamingState.SEEK);		
			}
			
			_notifyPlayUnpublishPending = false;
		}

		/**
		 * Closes the NetStream object.
		 */
		override public function close():void
		{
			_mixer.close();
			
			_mainTimer.stop();
			notifyPlayStop();
			
			setState(HTTPStreamingState.HALT);
			
			super.close();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set bufferTime(value:Number):void
		{
			super.bufferTime = value;
			_desiredBufferTime_Min = Math.max(OSMFSettings.hdsMinimumBufferTime, value);
			_desiredBufferTime_Max = _desiredBufferTime_Min + OSMFSettings.hdsAdditionalBufferTime;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get time():Number
		{
			if(_seekTime >= 0 && _initialTime >= 0)
			{
				_lastValidTimeTime = (super.time + _seekTime) - _initialTime; 
				//  we remember what we say when time is valid, and just spit that back out any time we don't have valid data. This is probably the right answer.
				//  the only thing we could do better is also run a timer to ask ourselves what it is whenever it might be valid and save that, just in case the
				//  user doesn't ask... but it turns out most consumers poll this all the time in order to update playback position displays
			}
			return _lastValidTimeTime;
		}

		///////////////////////////////////////////////////////////////////////
		/// Custom public API - specific to HTTPNetStream 
		///////////////////////////////////////////////////////////////////////
		/**
		 * Get stream information from the associated information.
		 */ 
		public function DVRGetStreamInfo(streamName:Object):void
		{
			if (_mixer.isReady)
			{
				// TODO: should we re-trigger the event?
			}
			else
			{
				// TODO: should there be a guard to protect the case where isReady is not yet true BUT play has already been called, so we are in an
				// "initializing but not yet ready" state? This is only needed if the caller is liable to call DVRGetStreamInfo and then, before getting the
				// event back, go ahead and call play()
				_mixer.video.getDVRInfo(streamName);
			}
		}
		
		/**
		 * Gets the last QoS information. This information is used by the HTTPStreamingSwitchManager
		 * when deciding if there is need for an up-switch or down-switch.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.0
		 */
		public function get qosInfo():HTTPStreamQoSInfo
		{
			return ( _mixer.video != null ? _mixer.video.qosInfo : null);
		}

		///////////////////////////////////////////////////////////////////////
		/// Internals
		///////////////////////////////////////////////////////////////////////
		/**
		 * @private
		 * 
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
		 * Processes provided arguments to obtain the actual
		 * play parameters.
		 */
		private function processPlayParameters(args:Array):void
		{
			if (args.length < 1)
			{
				throw new Error("HTTPNetStream.play() requires at least one argument");
			}

			_playStreamName = args[0];

			_playStart = 0;
			if (args.length >= 2)
			{
				_playStart = Number(args[1]);
			}
			
			_playForDuration = -1;
			if (args.length >= 3)
			{
				_playForDuration = Number(args[2]);
			}
		}
		
		/**
		 * @private
		 * 
		 * Changes the main media source to specified stream name.
		 */
		private function changeSourceTo(streamName:String, seekTarget:Number):void
		{
			_initializeFLVParser = true;
			_seekTarget = seekTarget;
			_mixer.video.open(streamName);
			setState(HTTPStreamingState.SEEK);
		}
		
		/**
		 * @private
		 * 
		 * Changes the quality of the main stream.
		 */
		private function changeQualityLevelTo(streamName:String):void
		{
			_qualityLevelNeedsChanging = true;
			_desiredQualityStreamName = streamName;
			
			if (
					_mixer.isReady 
				&& (_mixer.video != null && _mixer.video.streamName != _desiredQualityStreamName)
			)
			{
				CONFIG::LOGGING
				{
					logger.debug("Stream source is ready so we can initiate change quality to [" + _desiredQualityStreamName + "]");
				}
				_mixer.video.changeQualityLevel(_desiredQualityStreamName);
				_qualityLevelNeedsChanging = false;
				_desiredQualityStreamName = null;
			}
			
			_notifyPlayUnpublishPending = false;
		}

		/**
		 * @private
		 * 
		 * Changes audio track to load from an alternate track.
		 */
		private function changeAudioStreamTo(streamName:String):void
		{
			_audioStreamNeedsChanging = true;
			_desiredAudioStreamName = streamName;
			
			if (
					_mixer.video.isOpen
				&& (
						(_mixer.audio == null && _desiredAudioStreamName != null)	
					||  (_mixer.audio != null && _mixer.audio.streamName != _desiredAudioStreamName)
				)
			)
			{
				CONFIG::LOGGING
				{
					logger.debug("Initiating change of audio stream to [" + _desiredAudioStreamName + "]");
				}
				
				var audioResource:MediaResourceBase = HTTPStreamingUtils.createHTTPStreamingResource(_resource, _desiredAudioStreamName);
				if (audioResource != null)
				{
					// audio handler is not dispatching events on the NetStream
					_mixer.audio = new HTTPStreamSource(_factory, audioResource, _mixer);
					_mixer.audio.open(_desiredAudioStreamName);
				}
				else
				{
					_mixer.audio = null;
				}
				
				_audioStreamNeedsChanging = false;
				_desiredAudioStreamName = null;
			}
			
			_notifyPlayUnpublishPending = false;
		}
		
		/**
		 * @private
		 * 
		 * Event handler for net status events. 
		 */
		private function onNetStatus(event:NetStatusEvent):void
		{
			CONFIG::LOGGING
			{
				logger.debug("NetStatus event:" + event.info.code);
			}
			
			switch(event.info.code)
			{
				case NetStreamCodes.NETSTREAM_BUFFER_EMPTY:
					if  (_state == HTTPStreamingState.HALT) 
					{
						if (_notifyPlayUnpublishPending)
						{
							notifyPlayUnpublish();
							_notifyPlayUnpublishPending = false; 
						}
					}
					break;
				
				case NetStreamCodes.NETSTREAM_PLAY_STREAMNOTFOUND:
					// if we have received a stream not found error
					// then we close all data
					close();
					break;
			}
			
			CONFIG::FLASH_10_1
			{
				if( event.info.code == NetStreamCodes.NETSTREAM_DRM_UPDATE)
				{
					// if a DRM Update is needed, then we block further data processing
					// as reloading of current media will be required
					CONFIG::LOGGING
					{
						logger.debug("DRM library needs to be updated. Waiting until DRM state is updated."); 
					}
					_waitForDRM = true;
				}
			}

		}
		
		CONFIG::FLASH_10_1
		{
			/**
			 * @private
			 * 
			 * We need to process DRM-related errors in order to prevent downloading
			 * of unplayable content. 
			 */ 
			private function onDRMError(event:DRMErrorEvent):void
			{
				CONFIG::LOGGING
				{
					logger.debug("Received an DRM error (" + event.toString() + ").");
					logger.debug("Entering waiting mode until DRM state is updated."); 
				}
				_waitForDRM = true;
				setState(HTTPStreamingState.WAIT);
			}
			
			private function onDRMStatus(event:DRMStatusEvent):void
			{
				if (event.voucher != null)
				{
					CONFIG::LOGGING
					{
						logger.debug("DRM state updated. We'll exit waiting mode once the buffer is consumed.");
					}
					_waitForDRM = false;
				}
			}
		}
		
		/**
		 * @private
		 * 
		 * We cycle through HTTPNetStream states and do chunk
		 * processing. 
		 */  
		private function onMainTimer(timerEvent:TimerEvent):void
		{	
			switch(_state)
			{
				case HTTPStreamingState.INIT:
					// do nothing
					break;
				
				case HTTPStreamingState.WAIT:
					// if we are getting dry then go back into
					// active play mode and get more bytes 
					// from the stream provider
					if (!_waitForDRM && this.bufferLength < _desiredBufferTime_Min)
					{
						setState(HTTPStreamingState.PLAY);
					}
					break;
				
				case HTTPStreamingState.SEEK:
					// In seek mode we just forward the seek offset to 
					// the stream provider. The only problem is that
					// we may call seek before our stream provider is
					// able to fulfill our request - so we'll stay in seek
					// mode until the provider is ready.
					if (_source.isReady)
					{
						_enhancedSeekTarget = _seekTarget;
						
						super.seek(_seekTarget);
						CONFIG::FLASH_10_1
						{
							appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
						}
						
						_seekTime = -1;
						_source.seek(_seekTarget);
						setState(HTTPStreamingState.WAIT);
					}
					break;
				
				case HTTPStreamingState.PLAY:
					if (_notifyPlayStartPending)
					{
						_notifyPlayStartPending = false;
						notifyPlayStart();
					}
					
					if (_qualityLevelNeedsChanging)
					{
						changeQualityLevelTo(_desiredQualityStreamName);
					}
					if (_audioStreamNeedsChanging)
					{
						changeAudioStreamTo(_desiredAudioStreamName);
					}
										
					var processed:int = 0;
					var keepProcessing:Boolean = true;
					
					while(keepProcessing)
					{
						var bytes:ByteArray = _source.getBytes();
						
						if (bytes != null)
						{
							processed += processAndAppend(bytes);	
						}
						
						if (
							    (_state != HTTPStreamingState.PLAY) 	// we are no longer in play mode
							 || (bytes == null) 						// or we don't have any additional data
							 || (processed >= OSMFSettings.hdsBytesProcessingLimit) 	// or we have processed enough data  
						)
						{
							keepProcessing = false;
						}
					}
					
					if (_state == HTTPStreamingState.PLAY)
					{
						if (processed > 0)
						{
							CONFIG::LOGGING
							{
								logger.debug("Processed " + processed + " bytes ( buffer = " + this.bufferLength + " )" ); 
							}
							
							// if our buffer has grown big enough then go into wait
							// mode where we let the NetStream consume the buffered 
							// data
							if (this.bufferLength > _desiredBufferTime_Max || _waitForDRM)
							{
								setState(HTTPStreamingState.WAIT);
							}
						}
						else
						{
							// if we reached the end of stream then we need stop and
							// dispatch this event to all our clients.						
							if (_source.endOfStream)
							{
								super.bufferTime = 0.1;
								CONFIG::LOGGING
								{
									logger.debug("End of stream reached. Stopping."); 
								}
								setState(HTTPStreamingState.STOP);
							}
						}
					}
					break;
				
				case HTTPStreamingState.STOP:
					CONFIG::FLASH_10_1
					{
						appendBytesAction(NetStreamAppendBytesAction.END_SEQUENCE);
						appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
					}
					
					var playCompleteInfo:Object = new Object();
					playCompleteInfo.code = NetStreamCodes.NETSTREAM_PLAY_COMPLETE;
					playCompleteInfo.level = "status";
					
					var playCompleteInfoSDOTag:FLVTagScriptDataObject = new FLVTagScriptDataObject();
					playCompleteInfoSDOTag.objects = ["onPlayStatus", playCompleteInfo];
					
					var tagBytes:ByteArray = new ByteArray();
					playCompleteInfoSDOTag.write(tagBytes);
					attemptAppendBytes(tagBytes);
					setState(HTTPStreamingState.HALT);
					break;
				
				case HTTPStreamingState.HALT:
					// do nothing
					break;
			}
		}

		/**
		 * @private
		 * 
		 * Event handler for all DVR related information events.
		 */
		private function onDVRStreamInfo(event:DVRStreamInfoEvent):void
		{
			_dvrInfo = event.info as DVRInfo;
		}
		
		/**
		 * @private
		 * 
		 * Also on fragment boundaries we usually start our own FLV parser
		 * object which is used to process script objects, to update our
		 * play head and to detect if we need to stop the playback.
		 */
		private function onBeginFragment(event:HTTPStreamingEvent):void
		{
			CONFIG::LOGGING
			{
				logger.debug("Detected begin fragment for stream [" + event.url + "].");
				logger.debug("Dropped frames=" + this.info.droppedFrames + ".");
			}			
			
			if (_initialTime < 0 || _seekTime < 0 || _insertScriptDataTags ||  _playForDuration >= 0)
			{
				if (_flvParser == null)
				{
					CONFIG::LOGGING
					{
						logger.debug("Initialize the FLV Parser ( seekTime = " + _seekTime + ", initialTime = " + _initialTime + ", playForDuration = " + _playForDuration + " ).");
						if (_insertScriptDataTags != null)
						{
							logger.debug("Script tags available (" + _insertScriptDataTags.length + ") for processing." );	
						}
					}
					
					if (_enhancedSeekTarget >= 0 || _playForDuration >= 0)
					{
						_flvParserIsSegmentStart = true;	
					}
					_flvParser = new FLVParser(false);
				}
				_flvParserDone = false;
			}
		}

		/**
		 * @private
		 * 
		 * Usually the end of fragment is processed by the associated switch
		 * manager as is a good place to decide if we need to switch up or down.
		 */
		private function onEndFragment(event:HTTPStreamingEvent):void
		{
			CONFIG::LOGGING
			{
				logger.debug("Reached end fragment for stream [" + event.url + "].");
			}			
		}
		
		/**
		 * @private
		 * 
		 * We notify the starting of the switch so that the associated switch manager
		 * correctly update its state. We do that by dispatching a NETSTREAM_PLAY_TRANSITION
		 * event.
		 */
		private function onTransition(event:HTTPStreamingEvent):void
		{
			dispatchEvent( 
				new NetStatusEvent( 
					NetStatusEvent.NET_STATUS
					, false
					, false
					, {code:NetStreamCodes.NETSTREAM_PLAY_TRANSITION, level:"status", details:event.url}
				)
			); 
		}
		
		/**
		 * @private
		 * 
		 * We notify the switch completition so that switch manager to correctly update 
		 * its state and dispatch any related event. We do that by inserting an 
		 * onPlayStatus data packet into the stream.
		 */
		private function onTransitionComplete(event:HTTPStreamingEvent):void
		{
			onActionNeeded(event);
			
			var info:Object = new Object();
			info.code = NetStreamCodes.NETSTREAM_PLAY_TRANSITION_COMPLETE;
			info.level = "status";
			info.details = event.url;
			
			var sdoTag:FLVTagScriptDataObject = new FLVTagScriptDataObject();
			sdoTag.objects = ["onPlayStatus", info];
			
			insertScriptDataTag(sdoTag);
		}
		
		/**
		 * @private
		 * 
		 * We received an download error event. We will dispatch a NetStatusEvent with StreamNotFound
		 * error to notify all NetStream consumers and close the current NetStream.
		 */
		private function onDownloadError(event:HTTPStreamingEvent):void
		{
			// We map all URL errors to Play.StreamNotFound.
			dispatchEvent
					( new NetStatusEvent
						( NetStatusEvent.NET_STATUS
							, false
							, false
							, {code:NetStreamCodes.NETSTREAM_PLAY_STREAMNOTFOUND, level:"error", details:event.url}
						)
					);
		}
		
		/**
		 * @private
		 * 
		 * We notify that the playback started only when we start loading the 
		 * actual bytes and not when the play command was issued. We do that by
		 * dispatching a NETSTREAM_PLAY_START NetStatusEvent.
		 */
		private function notifyPlayStart():void
		{
			dispatchEvent( 
				new NetStatusEvent( 
					NetStatusEvent.NET_STATUS
					, false
					, false
					, {code:NetStreamCodes.NETSTREAM_PLAY_START, level:"status"}
				)
			); 
		}

		/**
		 * @private
		 * 
		 * We notify that the playback stopped only when close method is invoked.
		 * We do that by dispatching a NETSTREAM_PLAY_STOP NetStatusEvent.
		 */
		private function notifyPlayStop():void
		{
			dispatchEvent(
				new NetStatusEvent( 
					NetStatusEvent.NET_STATUS
					, false
					, false
					, {code:NetStreamCodes.NETSTREAM_PLAY_STOP, level:"status"}
				)
			); 
		}

		/**
		 * @private
		 * 
		 * We dispatch NETSTREAM_PLAY_UNPUBLISH event when we are preparing
		 * to stop the HTTP processing.
		 */		
		private function notifyPlayUnpublish():void
		{
			dispatchEvent(
				new NetStatusEvent( 
					NetStatusEvent.NET_STATUS
					, false
					, false
					, {code:NetStreamCodes.NETSTREAM_PLAY_UNPUBLISH_NOTIFY, level:"status"}
				)
			);
		}

		/**
		 * @private
		 * 
		 * Inserts a script data object in a queue which will be processed 
		 * by the NetStream next time it will play.
		 */
		private function insertScriptDataTag(tag:FLVTagScriptDataObject, first:Boolean = false):void
		{
			if (!_insertScriptDataTags)
			{
				_insertScriptDataTags = new Vector.<FLVTagScriptDataObject>();
			}
			
			if (first)
			{
				_insertScriptDataTags.unshift(tag);	
			}
			else
			{
				_insertScriptDataTags.push(tag);
			}
		}
		
		/**
		 * @private
		 * 
		 * Consumes all script data tags from the queue. Returns the number of bytes
		 * 
		 */
		private function consumeAllScriptDataTags(timestamp:Number):int
		{
			var processed:int = 0;
			var index:int = 0;
			var bytes:ByteArray = null;
			var tag:FLVTagScriptDataObject = null;
			
			for (index = 0; index < _insertScriptDataTags.length; index++)
			{
				bytes = new ByteArray();
				tag = _insertScriptDataTags[index];
				
				if (tag != null)
				{
					tag.timestamp = timestamp;
					tag.write(bytes);
					attemptAppendBytes(bytes);
					processed += bytes.length;
				}
			}
			_insertScriptDataTags.length = 0;
			_insertScriptDataTags = null;			
			
			return processed;
		}
		
		/**
		 * @private
		 * 
		 * Processes and appends the provided bytes.
		 */
		private function processAndAppend(inBytes:ByteArray):uint
		{
			if (!inBytes || inBytes.length == 0)
			{
				return 0;
			}

			var bytes:ByteArray;
			var processed:uint = 0;
			
			if (_flvParser == null)
			{
				// pass through the initial bytes 
				bytes = inBytes;
			}
			else
			{
				// we need to parse the initial bytes
				_flvParserProcessed = 0;
				inBytes.position = 0;	
				_flvParser.parse(inBytes, true, onTag);	
				processed += _flvParserProcessed;
				if(!_flvParserDone)
				{
					// the common parser has more work to do in-path
					return processed;
				}
				else
				{
					// the common parser is done, so flush whatever is left 
					// and then pass through the rest of the segment
					bytes = new ByteArray();
					_flvParser.flush(bytes);
					_flvParser = null;	
				}
			}
			
			processed += bytes.length;
			if (_state != HTTPStreamingState.STOP)
			{
				attemptAppendBytes(bytes);
			}
			
			return processed;
		}
		
		/**
		 * @private
		 * 
		 * Method called by FLV parser object every time it detects another
		 * FLV tag inside the buffer it tries to parse.
		 */
		private function onTag(tag:FLVTag):Boolean
		{
			var i:int;
			
			if (_insertScriptDataTags != null)
			{
				CONFIG::LOGGING
				{
					logger.debug("Consume all queued script data tags ( use timestamp = " + tag.timestamp + " ).");
				}
				_flvParserProcessed += consumeAllScriptDataTags(tag.timestamp);
			}
			
			var currentTime:Number = (tag.timestamp / 1000.0) + _fileTimeAdjustment;
			if (_playForDuration >= 0)
			{
				if (_initialTime >= 0)	// until we know this, we don't know where to stop, and if we're enhanced-seeking then we need that logic to be what sets this up
				{
					if (currentTime > (_initialTime + _playForDuration))
					{
						setState(HTTPStreamingState.STOP);
						_flvParserDone = true;
						if (_seekTime < 0)
						{
							_seekTime = _playForDuration + _initialTime;	// FMS behavior... the time is always the final time, even if we seek to past it
							// XXX actually, FMS  actually lets exactly one frame though at that point and that's why the time gets to be what it is
							// XXX that we don't exactly mimic that is also why setting a duration of zero doesn't do what FMS does (plays exactly that one still frame)
						}
						return false;
					}
				}
			}
			
			
			if (_enhancedSeekTarget < 0)
			{
				if (_initialTime < 0)
				{
					_initialTime = _dvrInfo != null ? _dvrInfo.startTime : currentTime;
				}
				if (_seekTime < 0)
				{
					_seekTime = currentTime;
				}
			}		
			else // doing enhanced seek
			{
				if (currentTime < _enhancedSeekTarget)
				{
					if (tag is FLVTagVideo)
					{
						if (_enhancedSeekTags == null)
						{
							_enhancedSeekTags = new Vector.<FLVTagVideo>();
						}

						if (_flvParserIsSegmentStart)	
						{
							var _muteTag:FLVTagVideo = new FLVTagVideo();
							_muteTag.timestamp = tag.timestamp; // may get overwritten, ok
							_muteTag.codecID = FLVTagVideo(tag).codecID; // same as in use
							_muteTag.frameType = FLVTagVideo.FRAME_TYPE_INFO;
							_muteTag.infoPacketValue = FLVTagVideo.INFO_PACKET_SEEK_START;
							// and start saving, with this as the first...
							_enhancedSeekTags.push(_muteTag);
							_flvParserIsSegmentStart = false;
						}	

						_enhancedSeekTags.push(tag);
					} // else is a data tag, which are simply passthrough with unadjusted timestamps, rather than discarding or saving for later
					else if (tag is FLVTagScriptDataObject)
					{
						bytes = new ByteArray();
						tag.write(bytes);
						_flvParserProcessed += bytes.length;
						attemptAppendBytes(bytes);
					} // else tag is FLVTagAudio, which we discard unless is a configuration tag which needs to be passthrough			
					else if (tag is FLVTagAudio && FLVTagAudio(tag).isCodecConfiguration)	
					{
						bytes = new ByteArray();
						tag.write(bytes);
						_flvParserProcessed += bytes.length;
						attemptAppendBytes(bytes);
					}
				}
				else
				{
					_enhancedSeekTarget = -1;
					if (_seekTime < 0)
					{
						_seekTime = currentTime;
					}
					if(_initialTime < 0)
					{
						_initialTime = currentTime;
					}
					
					if (_enhancedSeekTags != null && _enhancedSeekTags.length > 0)
					{
						var _unmuteTag:FLVTagVideo = new FLVTagVideo();
						_unmuteTag.timestamp = tag.timestamp;  // may get overwritten, ok
						_unmuteTag.codecID = (_enhancedSeekTags[0]).codecID;	// take the codec ID of the corresponding SEEK_START
						_unmuteTag.frameType = FLVTagVideo.FRAME_TYPE_INFO;
						_unmuteTag.infoPacketValue = FLVTagVideo.INFO_PACKET_SEEK_END;
						_enhancedSeekTags.push(_unmuteTag);
					
						// twiddle and dump
						for (i=0; i<_enhancedSeekTags.length; i++)
						{
							var vTag:FLVTagVideo;
							
							vTag = _enhancedSeekTags[i];
							if (vTag.codecID == FLVTagVideo.CODEC_ID_AVC && vTag.avcPacketType == FLVTagVideo.AVC_PACKET_TYPE_NALU)
							{
								// for H.264 we need to move the timestamp forward but the composition time offset backwards to compensate
								var adjustment:int = tag.timestamp - vTag.timestamp; // how far we are adjusting
								var compTime:int = vTag.avcCompositionTimeOffset;
								compTime -= adjustment; // do the adjustment
								vTag.avcCompositionTimeOffset = compTime;	// save adjustment
								vTag.timestamp = tag.timestamp; // and adjust the timestamp forward
							}
							else
							{
								// the simple case
								vTag.timestamp = tag.timestamp;
							}
							bytes = new ByteArray();
							vTag.write(bytes);
							_flvParserProcessed += bytes.length;
							attemptAppendBytes(bytes);
						}
						_enhancedSeekTags = null;
					}
					
					// and append this one
					bytes = new ByteArray();
					tag.write(bytes);
					_flvParserProcessed += bytes.length;
					attemptAppendBytes(bytes);
					if (_playForDuration >= 0)
					{
						return true;	// need to continue seeing the tags, and can't shortcut because we're being dropped off mid-segment
					}
					_flvParserDone = true;
					return false;	// and end of parsing (caller must dump rest, unparsed)
				}
				
				return true;
			} // enhanced seek
			
			// finally, pass this one on to appendBytes...
			var bytes:ByteArray = new ByteArray();
			tag.write(bytes);
			attemptAppendBytes(bytes);
			_flvParserProcessed += bytes.length;
			
			// probably done seeing the tags, unless we are in playForDuration mode...
			if (_playForDuration >= 0)
			{
				if (_mediaFragmentDuration >= 0 && _flvParserIsSegmentStart)
				{
					// if the segmentDuration has been reported, it is possible that we might be able to shortcut
					// but we need to be careful that this is the first tag of the segment, otherwise we don't know what duration means in relation to the tag timestamp
					
					_flvParserIsSegmentStart = false; // also used by enhanced seek, but not generally set/cleared for everyone. be careful.
					currentTime = (tag.timestamp / 1000.0) + _fileTimeAdjustment;
					if (currentTime + _mediaFragmentDuration >= (_initialTime + _playForDuration))
					{
						// it stops somewhere in this segment, so we need to keep seeing the tags
						return true;
					}
					else
					{
						// stop is past the end of this segment, can shortcut and stop seeing tags
						_flvParserDone = true;
						return false;
					}
				}
				else
				{
					return true;	// need to continue seeing the tags because either we don't have duration, or started mid-segment so don't know what duration means
				}
			}
			// else not in playForDuration mode...
			_flvParserDone = true;
			return false;
		}

		/**
		 * @private
		 * 
		 * Event handler invoked when we need to handle script data objects.
		 */
		private function onScriptData(event:HTTPStreamingEvent):void
		{
			if (event.scriptDataMode == null || event.scriptDataObject == null)
			{
				return;
			}

			CONFIG::LOGGING
			{
				logger.debug("onScriptData called with mode [" + event.scriptDataMode + "].");
			}

			switch (event.scriptDataMode)
			{
				case FLVTagScriptDataMode.NORMAL:
					insertScriptDataTag(event.scriptDataObject, false);
					break;
				
				case FLVTagScriptDataMode.FIRST:
					insertScriptDataTag(event.scriptDataObject, true);
					break;
				
				case FLVTagScriptDataMode.IMMEDIATE:
					if (client)
					{
						var methodName:* = event.scriptDataObject.objects[0];
						var methodParameters:* = event.scriptDataObject.objects[1];
						
						CONFIG::LOGGING
						{
							logger.debug(methodName + " invoked."); 
						}
						
						if (client.hasOwnProperty(methodName))
						{
							// XXX note that we can only support a single argument for immediate dispatch
							client[methodName](methodParameters);	
						}
					}
					break;
			}
		}
		
		/**
		 * @private
		 * 
		 * We need to do an append bytes action to reset internal state of the NetStream.
		 */
		private function onActionNeeded(event:HTTPStreamingEvent):void
		{
			CONFIG::LOGGING
			{
				logger.debug("We need to to an appendBytesAction in order to reset NetStream internal state");
			}

			CONFIG::FLASH_10_1
			{
				appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
			}
			
			// Before we feed any TCMessages to the Flash Player, we must feed
			// an FLV header first.
			var header:FLVHeader = new FLVHeader();
			var headerBytes:ByteArray = new ByteArray();
			header.write(headerBytes);
			attemptAppendBytes(headerBytes);
		}
		
		/**
		 * @private
		 * 
		 * Attempts to use the appendsBytes method. Do noting if this is not compiled
		 * for an Argo player or newer.
		 */
		private function attemptAppendBytes(bytes:ByteArray):void
		{
			CONFIG::FLASH_10_1
			{
				appendBytes(bytes);
			}
		}

		///////////////////////////////////////////////////////////////////////////////////
//		/**
//		 * @private
//		 * 
//		 * Event handler called when the index handler has successfully parse
//		 * the index information. We are ready to start the playback after this.
//		 */
//		private function onIndexReady(event:HTTPStreamingIndexHandlerEvent):void
//		{
//			if (_pendingIndexInitializations > 0)
//			{
//				// we are using only the offset from main stream
//				if (event.target == _mediaHandler)
//				{
//					_mediaIsReady = true;
//					if (event.live && _dvrInfo == null && !isNaN(event.offset))
//					{
//						_mediaSeekTarget = _audioSeekTarget = event.offset;
//					}
//				}
//				
//				// if we just initialized an audio stream
//				if (event.target == _audioHandler)
//				{
//					if (_mixer != null && _mixer.videoTime != 0 && _mixer.audioTime != 0)
//					{
//						_mediaSeekTarget = _mixer.videoTime / 1000;
//						_audioSeekTarget = _mixer.audioTime / 1000;
//					}
//					else
//					{
//						_mediaSeekTarget = _mediaBufferRemaining / 1000;
//						_audioSeekTarget = _mediaSeekTarget;
//					}
//				}
//				
//				_pendingIndexInitializations--;
//				if (_pendingIndexInitializations == 0)
//				{
////					setState(HTTPStreamingState.LOAD_SEEK);
//				}
//			}
//		}

//		/**
//		 * @private
//		 * 
//		 * Event handler for all index handler errors.
//		 */		
//		private function onIndexError(event:HTTPStreamingEvent):void
//		{
//			notifyURLError(null);
//		}
//		
//		/**
//		 * @private
//		 * 
//		 * Event handler for all file handler errors.
//		 */  
//		private function onFileError(event:HTTPStreamingEvent):void
//		{
//			notifyFileError(null);
//		}
//
//		/**
//		 * @private
//		 * 
//		 * We notify that some error occured when processing the specified file.
//		 * We actually map all URL errors to NETSTREAM_PLAY_STREAMNOTFOUND NetStatusEvent.
//		 * You can check the details property to see the url which triggered 
//		 * this error.
//		 */
//		private function notifyFileError(url:String):void
//		{
//			dispatchEvent( 
//				new NetStatusEvent( 
//					NetStatusEvent.NET_STATUS
//					, false
//					, false
//					, {code:NetStreamCodes.NETSTREAM_PLAY_FILESTRUCTUREINVALID, level:"error", details:url}
//				)
//			);
//		}
//
//		/**
//		 * @private
//		 * 
//		 * We notify that it was some error when downloading the desired url.
//		 * We actually map all URL errors to NETSTREAM_PLAY_STREAMNOTFOUND NetStatusEvent.
//		 * You can check the details property to see the url which triggered 
//		 * this error.
//		 */
//		private function notifyURLError(url:String):void
//		{
//			dispatchEvent(
//				new NetStatusEvent( 
//					NetStatusEvent.NET_STATUS
//					, false
//					, false
//					, {code:NetStreamCodes.NETSTREAM_PLAY_STREAMNOTFOUND, level:"error", details:url}
//				)
//			);
//		}
		
		/// Internals
		
		// This was exposed as a public property in OSMFSettings: hdsMinimumBufferTime
		//
		// private static const MINIMUM_BUFFER_TIME:Number = 4;
		
		// This was exposed as a public property in OSMFSettings: hdsAdditionalBufferTime
		//
		// private static const ADDITIONAL_BUFFER_TIME:Number = 2;
		
		private var _desiredBufferTime_Min:Number = 0;
		private var _desiredBufferTime_Max:Number = 0;
				
		// This was exposed as a public property in OSMFSettings: hdsBytesProcessingLimit
		//
		// private static const BYTES_PROCESSING_LIMIT:Number = 65000;
		
		// This was exposed as a public property in OSMFSettings: hdsMainTimerInterval
		//
		// private static const MAIN_TIMER_INTERVAL:int = 25;
		
		private var _mainTimer:Timer = null;
		private var _state:String = HTTPStreamingState.INIT;
		
		private var _playStreamName:String = null;
		private var _playStart:Number = -1;
		private var _playForDuration:Number = -1; 

		private var _resource:URLResource = null;
		private var _factory:HTTPStreamingFactory = null;
		
		private var _mixer:HTTPStreamMixer = null;
		private var _source:IHTTPStreamSource = null;
		
		private var _qualityLevelNeedsChanging:Boolean = false;
		private var _desiredQualityStreamName:String = null;
		private var _audioStreamNeedsChanging:Boolean = false;
		private var _desiredAudioStreamName:String = null;
		
		private var _seekTarget:Number = -1;
		private var _enhancedSeekTarget:Number = -1;
		private var _enhancedSeekTags:Vector.<FLVTagVideo>;

		private var _notifyPlayStartPending:Boolean = false;
		private var _notifyPlayUnpublishPending:Boolean = false;
		
		private var _initialTime:Number = -1;	// this is the timestamp derived at start-of-play (offset or not)... what FMS would call "0"
		private var _seekTime:Number = -1;		// this is the timestamp derived at end-of-seek (enhanced or not)... what we need to add to super.time (assuming play started at zero)
		private var _lastValidTimeTime:Number = 0; // this is the last known timestamp
		
		private var _initializeFLVParser:Boolean = false;
		private var _flvParser:FLVParser = null;	// this is the new common FLVTag Parser
		private var _flvParserDone:Boolean = true;	// signals that common parser has done everything and can be removed from path
		private var _flvParserProcessed:uint;
		private var _flvParserIsSegmentStart:Boolean = false;

		private var _insertScriptDataTags:Vector.<FLVTagScriptDataObject> = null;
		
		private var _fileTimeAdjustment:Number = 0;	// this is what must be added (IN SECONDS) to the timestamps that come in FLVTags from the file handler to get to the index handler timescale
		// XXX an event to set the _fileTimestampAdjustment is needed

		private var _mediaFragmentDuration:Number = 0;
		
		private var _dvrInfo:DVRInfo = null;
		
		private var _waitForDRM:Boolean = false;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.httpstreaming.HTTPNetStream");
			private var previouslyLoggedState:String = null;
		}
	}
}
