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
package org.denivip.osmf.net.httpstreaming.hls
{
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamPlayOptions;
	import flash.net.NetStreamPlayTransitions;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import org.denivip.osmf.events.HTTPHLSStreamingEvent;
	import org.denivip.osmf.plugins.HLSSettings;
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.QoSInfoEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.NetClient;
	import org.osmf.net.NetStreamCodes;
	import org.osmf.net.NetStreamPlaybackDetailsRecorder;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.net.httpstreaming.HTTPStreamHandlerQoSInfo;
	import org.osmf.net.httpstreaming.HTTPStreamingFactory;
	import org.osmf.net.httpstreaming.IHTTPStreamHandler;
	import org.osmf.net.httpstreaming.IHTTPStreamSource;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.net.httpstreaming.flv.FLVHeader;
	import org.osmf.net.httpstreaming.flv.FLVParser;
	import org.osmf.net.httpstreaming.flv.FLVTag;
	import org.osmf.net.httpstreaming.flv.FLVTagAudio;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataMode;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
	import org.osmf.net.httpstreaming.flv.FLVTagVideo;
	import org.osmf.net.qos.FragmentDetails;
	import org.osmf.net.qos.PlaybackDetails;
	import org.osmf.net.qos.QoSInfo;
	import org.osmf.net.qos.QualityLevel;
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
	
	[Event(name="DVRStreamInfo", type="org.osmf.events.DVRStreamInfoEvent")]
	
	[Event(name="runAlgorithm", type="org.osmf.events.HTTPStreamingEvent")]

	[Event(name="qosUpdate", type="org.osmf.events.QoSInfoEvent")]

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
	public class HTTPHLSNetStream extends NetStream
	{
		private var _reloadTryCount:int = 0;
		
		/**
		 * Constructor.
		 * 
		 * @param connection The NetConnection to use.
		 * @param factory Object which exposes the index, which maps
		 * playback times to media file fragments.
		 * @param resource Object which canunmarshal the data from a
		 * media file fragment so that it can be fed to the NetStream as
		 * TCMessages.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function HTTPHLSNetStream( connection:NetConnection, factory:HTTPStreamingFactory, resource:URLResource = null)
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
			addEventListener(HTTPHLSStreamingEvent.DISCONTINUITY,		onDiscontinuity);
			
			addEventListener(HTTPStreamingEvent.DOWNLOAD_COMPLETE,		onDownloadComplete);
			
			addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, HIGH_PRIORITY, true);
			
			CONFIG::FLASH_10_1
			{
				addEventListener(DRMErrorEvent.DRM_ERROR, onDRMError);
				addEventListener(DRMStatusEvent.DRM_STATUS, onDRMStatus);
			}
			
			this.bufferTime = OSMFSettings.hdsMinimumBufferTime;
			this.bufferTimeMax = 0;
			
			setState(HTTPStreamingState.INIT);
			
			createSource(resource);
			
			_mainTimer = new Timer(OSMFSettings.hdsMainTimerInterval); 
			_mainTimer.addEventListener(TimerEvent.TIMER, onMainTimer);
		}
		
		///////////////////////////////////////////////////////////////////////
		/// Public API overrides
		///////////////////////////////////////////////////////////////////////
		
		override public function set client(object:Object):void
		{
			super.client = object;
			
			if (client is NetClient && _resource is DynamicStreamingResource)
			{
				playbackDetailsRecorder = new NetStreamPlaybackDetailsRecorder(this, client as NetClient, _resource as DynamicStreamingResource);
			}
		}
		
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
			_isPlaying = true;
			_isPaused = false;
			
			_notifyPlayStartPending = true;
			_notifyPlayUnpublishPending = false;
			
			changeSourceTo(_playStreamName, _playStart);
		}
		
		/**
		 * Pauses playback.
		 */
		override public function pause():void 
		{
			_isPaused = true;
			super.pause();
		}
		
		/**
		 * Resumes playback.
		 */
		override public function resume():void 
		{
			_isPaused = false;
			super.resume();
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
				
				dispatchEvent(
					new NetStatusEvent(
						NetStatusEvent.NET_STATUS, 
						false, 
						false, 
						{
							code:NetStreamCodes.NETSTREAM_SEEK_START, 
							level:"status"
						}
					)
				);		
			}
			
			_notifyPlayUnpublishPending = false;
		}

		/**
		 * Closes the NetStream object.
		 */
		override public function close():void
		{
			if (_videoHandler != null)
			{
				_videoHandler.close();
			}
			if (_mixer != null)
			{
				_mixer.close();
			}
			
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
		
		/**
		 * @inheritDoc
		 */
		override public function get bytesLoaded():uint
		{
			return _bytesLoaded;
		}

		///////////////////////////////////////////////////////////////////////
		/// Custom public API - specific to HTTPNetStream 
		///////////////////////////////////////////////////////////////////////
		/**
		 * Get stream information from the associated information.
		 */ 
		public function DVRGetStreamInfo(streamName:Object):void
		{
			if (_source.isReady)
			{
				// TODO: should we re-trigger the event?
			}
			else
			{
				// TODO: should there be a guard to protect the case where isReady is not yet true BUT play has already been called, so we are in an
				// "initializing but not yet ready" state? This is only needed if the caller is liable to call DVRGetStreamInfo and then, before getting the
				// event back, go ahead and call play()
				_videoHandler.getDVRInfo(streamName);
			}
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
			_videoHandler.open(streamName);
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
					_source.isReady 
				&& (_videoHandler != null && _videoHandler.streamName != _desiredQualityStreamName)
			)
			{
				CONFIG::LOGGING
				{
					logger.debug("Stream source is ready so we can initiate change quality to [" + _desiredQualityStreamName + "]");
				}
				_videoHandler.changeQualityLevel(_desiredQualityStreamName);
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
			if (_mixer == null)
			{
				CONFIG::LOGGING
				{
					logger.warn("Invalid operation(changeAudioStreamTo) for legacy source. Should been a mixed source.");
				}
				
				_audioStreamNeedsChanging = false;
				_desiredAudioStreamName = null;
				return;
			}
			
			_audioStreamNeedsChanging = true;
			_desiredAudioStreamName = streamName;
			
			if (
					_videoHandler.isOpen
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
				var audioResource:MediaResourceBase;
				if(_desiredAudioStreamName)
					audioResource = new StreamingURLResource(_desiredAudioStreamName);
				if (audioResource != null)
				{
					// audio handler is not dispatching events on the NetStream
					_mixer.audio = new HTTPHLSStreamSource(_factory, audioResource, _mixer);
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
				case NetStreamCodes.NETSTREAM_PLAY_START:
					if(!_started){
						bufferTime = OSMFSettings.hdsMinimumBufferTime;//HLSSettings.hlsBufferSizeDef;
						_started = true;
						CONFIG::LOGGING
						{
							logger.debug("Playback started. Buffer size = "+bufferTime);
						}
					}
					break;
				case NetStreamCodes.NETSTREAM_PAUSE_NOTIFY:
					bufferTime = HLSSettings.hlsBufferSizePause;
					CONFIG::LOGGING
					{
						logger.debug("Playback paused. Buffer size ="+bufferTime);
					}
					break;
				case NetStreamCodes.NETSTREAM_UNPAUSE_NOTIFY:
					bufferTime = bufferLength;
					CONFIG::LOGGING
					{
						logger.debug("Playback unpaused. Buffer size ="+bufferTime);
					}
					break;
				
				case NetStreamCodes.NETSTREAM_BUFFER_EMPTY:
					emptyBufferInterruptionSinceLastQoSUpdate = true;
					_wasBufferEmptied = true;
					CONFIG::LOGGING
					{
						logger.debug("Received NETSTREAM_BUFFER_EMPTY. _wasBufferEmptied = "+_wasBufferEmptied+" bufferLength "+this.bufferLength);
					}
					if  (_state == HTTPStreamingState.HALT) 
					{
						if (_notifyPlayUnpublishPending)
						{
							notifyPlayUnpublish();
							_notifyPlayUnpublishPending = false; 
						}
					}
					bufferTime = OSMFSettings.hdsMinimumBufferTime;//HLSSettings.hlsBufferSizeDef;
					break;
				
				case NetStreamCodes.NETSTREAM_BUFFER_FULL:
					_wasBufferEmptied = false;
					CONFIG::LOGGING
					{
						logger.debug("Received NETSTREAM_BUFFER_FULL. _wasBufferEmptied = "+_wasBufferEmptied+" bufferLength "+this.bufferLength);
					}
					bufferTime = (bufferTime >= HLSSettings.hlsBufferSizeDef) ? HLSSettings.hlsBufferSizeBig : HLSSettings.hlsBufferSizeDef;
					break;
				
				case NetStreamCodes.NETSTREAM_BUFFER_FLUSH:
					_wasBufferEmptied = false;
					CONFIG::LOGGING
					{
						logger.debug("Received NETSTREAM_BUFFER_FLUSH. _wasBufferEmptied = "+_wasBufferEmptied+" bufferLength "+this.bufferLength);
					}
					break;
				
				case NetStreamCodes.NETSTREAM_PLAY_STREAMNOTFOUND:
					// if we have received a stream not found error
					// then we close all data
					close();
					break;
				
				case NetStreamCodes.NETSTREAM_SEEK_NOTIFY:
					if (! event.info.hasOwnProperty("sentFromHTTPNetStream") )
					{
						// we actually haven't finished seeking, so we stop the propagation of the event
						event.stopImmediatePropagation();
						
						CONFIG::LOGGING
						{
							logger.debug("Seek notify caught and stopped");
						}
					}
					bufferTime = OSMFSettings.hdsMinimumBufferTime;//HLSSettings.hlsBufferSizeDef;
					break;
				
				default:
					// Some http based error?  If yes, shut'er down.
					var httpCode:int = parseInt(event.info.code);
					if( !isNaN(httpCode) && httpCode >= 400 ){
						close();
						dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, true, false, new MediaError(404, "Can't open stream!")));
					}
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
			if (_seeking && time != _timeBeforeSeek)
			{
				_seeking = false;
				_timeBeforeSeek = Number.NaN;
				
				CONFIG::LOGGING
				{
					logger.debug("Seek complete and time updated to: " + time + ". Dispatching HTTPNetStatusEvent.NET_STATUS - Seek.Notify");
				}
				
				dispatchEvent(
					new NetStatusEvent(
						NetStatusEvent.NET_STATUS, 
					    false, 
						false, 
						{
							code:NetStreamCodes.NETSTREAM_SEEK_NOTIFY, 
							level:"status", 
							seekPoint:time,
							sentFromHTTPNetStream:true
						}
					)
				);				
			}
			
			if (currentFPS > maxFPS)
			{
				maxFPS = currentFPS;
			}
			
			switch(_state)
			{
				case HTTPStreamingState.INIT:
					// do nothing
					break;
				
				case HTTPStreamingState.WAIT:
					// if we are getting dry then go back into
					// active play mode and get more bytes 
					// from the stream provider
					
					if (!_waitForDRM && (this.bufferLength < _desiredBufferTime_Min || checkIfExtraBufferingNeeded()))
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
					if (_source.isReady )
					{
						_timeBeforeSeek = time;
						_seeking = true;
						
						// cleaning up the previous seek info
						_flvParser = null;
						if (_enhancedSeekTags != null)
						{
							_enhancedSeekTags.length = 0;
							_enhancedSeekTags = null;
						}
						
						_enhancedSeekTarget = _seekTarget;
						
						// Netstream seek in data generation mode only clears the buffer.
						// It does not matter what value you pass to it. However, netstream
						// apparently doesn't do that if the value given is larger than
						// (2^31 - 1) / 1000, which is max int signed divided by 1000 miliseconds
						// Therefore, we always seek to 0. This is a workaround for FM-1519
						super.seek(0);
						
						CONFIG::FLASH_10_1
						{
							appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
						}
						
						_wasBufferEmptied = true;
						
						if (playbackDetailsRecorder != null)
						{
							if (playbackDetailsRecorder.playingIndex != lastTransitionIndex)
							{
								CONFIG::LOGGING
								{
									logger.debug("Seeking before the last transition completed. Inserting TRANSITION_COMPLETE message in stream.");
								}
								
								var info:Object = {};
								info.code = NetStreamCodes.NETSTREAM_PLAY_TRANSITION_COMPLETE;
								info.level = "status";
								info.details = lastTransitionStreamURL;
								
								var sdoTag:FLVTagScriptDataObject = new FLVTagScriptDataObject();
								sdoTag.objects = ["onPlayStatus", info];
								
								insertScriptDataTag(sdoTag);
							}
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
						issueLivenessEventsIfNeeded();
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
								logger.debug("Processed " + processed + " bytes ( buffer = " + this.bufferLength + ", bufferTime = " + this.bufferTime+", wasBufferEmptied = "+_wasBufferEmptied+" )" ); 
							}
							
							if (_waitForDRM)
							{
								setState(HTTPStreamingState.WAIT);
							}
							else if (checkIfExtraBufferingNeeded())
							{
								// special case to keep buffering.
								// see checkIfExtraBufferingNeeded.
							}
							else if (this.bufferLength > _desiredBufferTime_Max)
							{
								// if our buffer has grown big enough then go into wait
								// mode where we let the NetStream consume the buffered 
								// data
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
					
					var playCompleteInfo:Object = {};
					playCompleteInfo.code = NetStreamCodes.NETSTREAM_PLAY_COMPLETE;
					playCompleteInfo.level = "status";
					
					var playCompleteInfoSDOTag:FLVTagScriptDataObject = new FLVTagScriptDataObject();
					playCompleteInfoSDOTag.objects = ["onPlayStatus", playCompleteInfo];
					
					var tagBytes:ByteArray = new ByteArray();
					playCompleteInfoSDOTag.write(tagBytes);
					attemptAppendBytes(tagBytes);
					
					CONFIG::FLASH_10_1
					{
						appendBytesAction(NetStreamAppendBytesAction.END_SEQUENCE);
					}
					
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
		 * There is a rare case in where we may need to perform extra buffering despite the
		 * values of bufferLength and bufferTime. See implementation for details.
		 * 
		 * @return true if we need to go into play state (or remain in play state). 
		 * 
		 **/
		private function checkIfExtraBufferingNeeded():Boolean
		{
			// There is a rare case where the player may have sent a BUFFER_EMPTY and
			// is waiting for bufferLength to grow "big enough" to play, and
			// bufferLength > bufferTime. To address this case, we must buffer
			// until we get a BUFFER_FULL event.
			
			if(!_wasBufferEmptied || // we're not waiting for a BUFFER_FULL
				!_isPlaying || // playback hasn't started yet
				_isPaused) // we're paused
			{
				// we're not in this case
				return false;
			}
			
			if(this.bufferLength > _desiredBufferTime_Max + 30)
			{
				// prevent infinite buffering. if we've buffered a lot more than
				// expected and we still haven't received a BUFFER_FULL, make sure
				// we don't keep buffering endlessly in order to prevent excessive
				// server-side load.
				return false;
			}
			
			CONFIG::LOGGING
			{
				logger.debug("Performing extra buffering because the player is probably stuck. bufferLength = "+this.bufferLength+" bufferTime = "+bufferTime);
			}
			return true;
		}
			
		/**
		 * @private
		 * 
		 * issue NetStatusEvent.NET_STATUS with NetStreamCodes.NETSTREAM_PLAY_LIVE_STALL or
		 * NetStreamCodes.NETSTREAM_PLAY_LIVE_RESUME if needed.
		 **/
		private function issueLivenessEventsIfNeeded():void
		{
			if(_source.isLiveStalled && _wasBufferEmptied) 
			{
				if(!_wasSourceLiveStalled)
				{
					CONFIG::LOGGING
					{
						logger.debug("stall");
					}			
					// remember when we first stalled.
					_wasSourceLiveStalled = true;
					_liveStallStartTime = new Date();
					_issuedLiveStallNetStatus = false;
				}
				// report the live stall if needed
				if(shouldIssueLiveStallNetStatus())
				{
					CONFIG::LOGGING
					{
						logger.debug("issue live stall");
					}			
					dispatchEvent( 
						new NetStatusEvent( 
							NetStatusEvent.NET_STATUS
							, false
							, false
							, {code:NetStreamCodes.NETSTREAM_PLAY_LIVE_STALL, level:"status"}
						)
					);
					_issuedLiveStallNetStatus = true;
				}
			}
			else
			{
				// source reports that live is not stalled
				if(_wasSourceLiveStalled && _issuedLiveStallNetStatus)
				{
					// we went from stalled to unstalled, issue a resume
					dispatchEvent( 
						new NetStatusEvent( 
							NetStatusEvent.NET_STATUS
							, false
							, false
							, {code:NetStreamCodes.NETSTREAM_PLAY_LIVE_RESUME, level:"status"}
						)
					);
				}
				_wasSourceLiveStalled = false;
			}
		}
		
		/**
		 * @private
		 * 
		 * helper for issueLivenessEventsIfNeeded
		 **/
		private function shouldIssueLiveStallNetStatus():Boolean
		{
			if(_issuedLiveStallNetStatus)
			{
				return false;  // we already issued a stall
			}
			if(!_wasBufferEmptied)
			{
				return false; // we still have some content to play
			}
			
			var liveStallTolerance:Number =
				(this.bufferLength + Math.max(OSMFSettings.hdsLiveStallTolerance, 0) + 1)*1000;
			var now:Date = new Date();
            // once we hit the live head, don't signal live stall event for at least a few seconds
            // in order to reduce the number of false positives. this accounts for the case
            // where we've caught up with live.
			return now.valueOf() >= _liveStallStartTime.valueOf() + liveStallTolerance;
			

		}

		/**
		 * @private
		 * 
		 * Event handler for all DVR related information events.
		 */
		private function onDVRStreamInfo(event:DVRStreamInfoEvent):void
		{
			_dvrInfo = event.info as DVRInfo;
			_initialTime = _dvrInfo.startTime;
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
			
			if (_videoHandler == null)
			{
				return;
			}
			
			var date:Date = new Date();
			var machineTimestamp:Number = date.getTime();
			
			var sourceQoSInfo:HTTPStreamHandlerQoSInfo = _videoHandler.qosInfo;
			
			var availableQualityLevels:Vector.<QualityLevel> = null;
			var actualIndex:uint = 0;
			var lastFragmentDetails:FragmentDetails = null;
			
			if (sourceQoSInfo != null)
			{
				availableQualityLevels = sourceQoSInfo.availableQualityLevels;
				actualIndex = sourceQoSInfo.actualIndex;
				lastFragmentDetails = sourceQoSInfo.lastFragmentDetails;
			}
			
			
			var playbackDetailsRecord:Vector.<PlaybackDetails> = null;
			var currentIndex:int = -1;
			
			if (playbackDetailsRecorder != null)
			{
				playbackDetailsRecord = playbackDetailsRecorder.computeAndGetRecord();
				currentIndex = playbackDetailsRecorder.playingIndex;
			}
			
			var qosInfo:QoSInfo = new QoSInfo
				( machineTimestamp 
				, time
				, availableQualityLevels
				, currentIndex
				, actualIndex
				, lastFragmentDetails
				, maxFPS
				, playbackDetailsRecord
				, info
				, bufferLength
				, bufferTime
				, emptyBufferInterruptionSinceLastQoSUpdate
				);
			
			dispatchEvent(new QoSInfoEvent(QoSInfoEvent.QOS_UPDATE, false, false, qosInfo));
			
			// Reset the empty buffer interruption flag
			emptyBufferInterruptionSinceLastQoSUpdate = false;
			
			dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.RUN_ALGORITHM));
			
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
			if (_resource is DynamicStreamingResource)
			{
				lastTransitionIndex = (_resource as DynamicStreamingResource).indexFromName(event.url);
				lastTransitionStreamURL = event.url;
			}
			
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
			
			var info:Object = {};
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
			CONFIG::LOGGING
			{
				logger.error("Error load chunk: " + event.url + " skip to next");
			}
			if(_source)
			{
				if(_source is HTTPHLSStreamSource)
				{	
					var httpCode:int = parseInt(event.reason);
					if(event.url.match(/.m3u8/))
					{
						if( !isNaN(httpCode) && httpCode >= 400 )
						{
							// There's no point in retrying--some 400 level error, which is something bunk client-side
							dispatchEvent( new NetStatusEvent( NetStatusEvent.NET_STATUS, false, false, {code:event.reason, level:"error", details:event.url}));
						}
						else if(_reloadTryCount >= HLSSettings.hlsMaxReloadRetryes)
						{	
							dispatchEvent( new NetStatusEvent( NetStatusEvent.NET_STATUS, false, false, {code:NetStreamCodes.NETSTREAM_PLAY_STREAMNOTFOUND, level:"error", details:event.url}) );
						}
						else
						{
							_reloadTryCount++;
							var t:Timer = new Timer(HLSSettings.hlsReloadTimeout);
							t.addEventListener( TimerEvent.TIMER_COMPLETE,
												function(e:Event):void{
													HTTPHLSStreamSource(_source).loadNextChunk();
												}
											  );
						}
					}
					else
					{
						// A .ts segment.  If this is a 404, then let's try loading the next chunk...
						// jnoring: not sure if this is wise, but it completely fixes streams with missing .ts segments, like:
						// http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8
						if( !isNaN(httpCode) && httpCode >= 400 && httpCode != 404 )
						{
							// There's no point in retrying--some 400 level error, which is something bunk client-side.
							dispatchEvent( new NetStatusEvent( NetStatusEvent.NET_STATUS, false, false, {code:event.reason, level:"error", details:event.url}));
						}
						else
						{
							HTTPHLSStreamSource(_source).loadNextChunk();
						}
					}
				}
			}
		}
		
		private function onDiscontinuity(event:HTTPHLSStreamingEvent):void{
			CONFIG::LOGGING
			{
				logger.debug("Timecode discontinuity: We need to to an appendBytesAction in order to reset NetStream internal state");
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
			
			if (_flvParser) {
				var bytes:ByteArray = new ByteArray();
				_flvParser.flush(bytes);
				_flvParser = null;
			}
		}
		
		private function onDownloadComplete(event:HTTPStreamingEvent):void
		{
			CONFIG::LOGGING
			{
				logger.debug("Download complete: " + event.url + " (" + event.bytesDownloaded + " bytes)"); 
			}
			_bytesLoaded += event.bytesDownloaded;
			_reloadTryCount = 0; // reset error counter
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
			var bytes:ByteArray = null;
			var tag:FLVTagScriptDataObject = null;
			
			for (var index:int = 0; index < _insertScriptDataTags.length; index++)
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
		 * Helper function that calls consumeAllScriptDataTags and also
		 * performs some logging
		 */
		private function doConsumeAllScriptDataTags(timestamp:uint):void
		{
			if (_insertScriptDataTags != null)
			{
				CONFIG::LOGGING
				{
					logger.debug("Consume all queued script data tags ( use timestamp = " + timestamp + " ).");
				}
				_flvParserProcessed += consumeAllScriptDataTags(timestamp);
			}
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
			
			var currentTime:Number = (tag.timestamp / 1000.0) + _fileTimeAdjustment;
			
			// Fix for http://bugs.adobe.com/jira/browse/FM-1544
			// We need to take into account that flv tags' timestamps are 32-bit unsigned ints
			// This means they will roll over, but the bootstrap times won't, since they are 64-bit unsigned ints
			while (currentTime < _initialTime)
			{
				// Add 2^32 (4,294,967,296) milliseconds to the currentTime
				// currentTime is in seconds so we divide that by 1000
				currentTime += 4294967.296;
			}
			
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
					_initialTime = _dvrInfo != null ? _dvrInfo.startTime : (_seekTime > 0 ? _playStart : currentTime);
				}
				if (_seekTime < 0)
				{
					_seekTime = currentTime;
				}
			}		
			else // doing enhanced seek
			{
				// If we're seeking backwards, and this timestamp is still greater than the time before seek...drop it 
				// on the floor.
				if( _enhancedSeekTarget < this._timeBeforeSeek && currentTime >= this._timeBeforeSeek )
				{
					// bzzt.
				}
				else if (currentTime < _enhancedSeekTarget)
				{
					if (_enhancedSeekTags == null)
					{
						_enhancedSeekTags = new Vector.<FLVTag>();
					}
					
					if (tag is FLVTagVideo)
					{                                  
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
					} 
					//else is a data tag, which we are simply saving for later, or a 
					//FLVTagAudio, which we discard unless is a configuration tag
					else if ((tag is FLVTagScriptDataObject) || 
						     (tag is FLVTagAudio && FLVTagAudio(tag).isCodecConfiguration))						                                                                   
					{
						_enhancedSeekTags.push(tag);
					}
				}
				else
				{
					// We've reached the tag whose timestamp is greater
					// than _enhancedSeekTarget.
					// We are safe to consume the script data tags now.
					doConsumeAllScriptDataTags(tag.timestamp);
					
					_enhancedSeekTarget = -1;
					if (_seekTime < 0)
					{
						_seekTime = currentTime;
					}
					if(_initialTime < 0)
					{
						_initialTime = _seekTime > 0 ? _playStart : currentTime;
					}
					
					if (_enhancedSeekTags != null && _enhancedSeekTags.length > 0)
					{
                        var codecID:int;
						var haveSeenVideoTag:Boolean = false;
                        
						// twiddle and dump
						for (i=0; i<_enhancedSeekTags.length; i++)
						{
                            var vTag:FLVTag = _enhancedSeekTags[i];
                            
                            if (vTag.tagType == FLVTag.TAG_TYPE_VIDEO)
                            {
                                var vTagVideo:FLVTagVideo = vTag as FLVTagVideo;
                                
                                if (vTagVideo.codecID == FLVTagVideo.CODEC_ID_AVC && vTagVideo.avcPacketType == FLVTagVideo.AVC_PACKET_TYPE_NALU)
                                {
                                    // for H.264 we need to move the timestamp forward but the composition time offset backwards to compensate
                                    var adjustment:int = tag.timestamp - vTagVideo.timestamp; // how far we are adjusting
                                    var compTime:int = vTagVideo.avcCompositionTimeOffset;
                                    compTime -= adjustment; // do the adjustment
                                    vTagVideo.avcCompositionTimeOffset = compTime;	// save adjustment
                                }
								
								codecID = vTagVideo.codecID;
								haveSeenVideoTag = true;
                            }
                            
                            vTag.timestamp = tag.timestamp;
							
                            bytes = new ByteArray();
                            vTag.write(bytes);
							_flvParserProcessed += bytes.length;
							attemptAppendBytes(bytes);
						}
                        
						if (haveSeenVideoTag)
						{
	                        var _unmuteTag:FLVTagVideo = new FLVTagVideo();
	                        _unmuteTag.timestamp = tag.timestamp;  // may get overwritten, ok
	                        _unmuteTag.codecID = codecID;
	                        _unmuteTag.frameType = FLVTagVideo.FRAME_TYPE_INFO;
	                        _unmuteTag.infoPacketValue = FLVTagVideo.INFO_PACKET_SEEK_END;
	                        
	                        bytes = new ByteArray();
	                        _unmuteTag.write(bytes);
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
			
			// Before appending the tag, trigger the consumption of all
			// the script data tags, with this tag's timestamp
			doConsumeAllScriptDataTags(tag.timestamp);
			
			// finally, pass this one on to appendBytes...
			var bytes:ByteArray = new ByteArray();
			tag.write(bytes);
			attemptAppendBytes(bytes);
			_flvParserProcessed += bytes.length;
			
			// probably done seeing the tags, unless we are in playForDuration mode...
			if (_playForDuration >= 0)
			{
				// using fragment duration to let the parser start when we're getting close to the end 
				// of the play duration (FM-1440)
				if (_source.fragmentDuration >= 0 && _flvParserIsSegmentStart)
				{
					// if the segmentDuration has been reported, it is possible that we might be able to shortcut
					// but we need to be careful that this is the first tag of the segment, otherwise we don't know what duration means in relation to the tag timestamp
					
					_flvParserIsSegmentStart = false; // also used by enhanced seek, but not generally set/cleared for everyone. be careful.
					currentTime = (tag.timestamp / 1000.0) + _fileTimeAdjustment;
					if (currentTime + _source.fragmentDuration >= (_initialTime + _playForDuration))
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
			// [FM-1387] we are appending this action only when we are 
			// dealing with late-binding audio streams
			if (_mixer != null)
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
		
		/**
		 * @private
		 * 
		 * Creates the source object which will be used to consume the associated resource.
		 */
		protected function createSource(resource:URLResource):void
		{
			var streamingResource:StreamingURLResource = resource as StreamingURLResource;
			if (streamingResource == null || streamingResource.alternativeAudioStreamItems == null || streamingResource.alternativeAudioStreamItems.length == 0)
			{
				// we are not in alternative audio scenario, we are going to the legacy mode
				var legacySource:HTTPHLSStreamSource = new HTTPHLSStreamSource(_factory, _resource, this);
				
				_source = legacySource;
				_videoHandler = legacySource;
			}
			else
			{
				_mixer = new HTTPHLSStreamMixer(this);
				_mixer.video = new HTTPHLSStreamSource(_factory, _resource, _mixer);
				
				_source = _mixer;
				_videoHandler = _mixer.video;
			}
		}
		
		private var _desiredBufferTime_Min:Number = 0;
		private var _desiredBufferTime_Max:Number = 0;

		private var _mainTimer:Timer = null;
		private var _state:String = HTTPStreamingState.INIT;
		
		private var _playStreamName:String = null;
		private var _playStart:Number = -1;
		private var _playForDuration:Number = -1; 

		private var _resource:URLResource = null;
		private var _factory:HTTPStreamingFactory = null;
		
		private var _mixer:HTTPHLSStreamMixer = null;
		private var _videoHandler:IHTTPStreamHandler = null;
		private var _source:IHTTPStreamSource = null;
		
		private var _qualityLevelNeedsChanging:Boolean = false;
		private var _desiredQualityStreamName:String = null;
		private var _audioStreamNeedsChanging:Boolean = false;
		private var _desiredAudioStreamName:String = null;
		
		private var _seekTarget:Number = -1;
		private var _enhancedSeekTarget:Number = -1;
		private var _enhancedSeekTags:Vector.<FLVTag>;

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
		
		private var _dvrInfo:DVRInfo = null;
		
		private var _waitForDRM:Boolean = false;
		
		private var maxFPS:Number = 0;
		
		private var playbackDetailsRecorder:NetStreamPlaybackDetailsRecorder = null;
		
		private var lastTransitionIndex:int = -1;
		private var lastTransitionStreamURL:String = null;
		private var _timeBeforeSeek:Number = Number.NaN;
		private var _seeking:Boolean = false;
		private var emptyBufferInterruptionSinceLastQoSUpdate:Boolean = false;
		
		private var _bytesLoaded:uint = 0;

		private var _started:Boolean = false;
		
		private var _wasSourceLiveStalled:Boolean = false;
		private var _issuedLiveStallNetStatus:Boolean = false;
		private var _wasBufferEmptied:Boolean = false;	// true if the player is waiting for BUFFER_FULL.
														// this occurs when we receive a BUFFER_EMPTY or when we we're buffering
														// in response to a seek.
		private var _isPlaying:Boolean = false; // true if we're currently playing. see checkIfExtraKickNeeded
		private var _isPaused:Boolean = false; // true if we're currently paused. see checkIfExtraKickNeeded
		private var _liveStallStartTime:Date;

		private static const HIGH_PRIORITY:int = int.MAX_VALUE;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.denivip.osmf.net.httpstreaming.hls.HTTPHLSNetStream") as Logger;
			private var previouslyLoggedState:String = null;
		}
	}
}
