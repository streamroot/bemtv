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
package org.osmf.netmocker
{
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamPlayOptions;
	import flash.net.NetStreamPlayTransitions;
	import flash.utils.Timer;
	
	import org.osmf.net.NetStreamCodes;
	
	public class MockNetStream extends NetStream
	{
		/**
		 * Constructor.
		 **/
		public function MockNetStream(connection:NetConnection)
		{
			super(connection);
			_connection = connection;
			
			// Intercept all NetStatusEvents dispatched from the base class.
			eventInterceptor = new NetStatusEventInterceptor(this);
			
			playheadTimer = new Timer(TIMER_DELAY);
			playheadTimer.addEventListener(TimerEvent.TIMER, onPlayheadTimer);
		}
				
		/**
		 * The expected duration of the stream, in seconds.  Necessary so that
		 * this mock stream class knows when to dispatch the events related
		 * to a stream completing.  The default is zero.
		 **/
		public function set expectedDuration(value:Number):void
		{
			this._expectedDuration = value;
		}
		
		public function get expectedDuration():Number
		{
			return _expectedDuration;
		}

		/**
		 * The expected total number of bytes of the stream.  Applies to progressive
		 * media only.  The default is 0.
		 **/
		public function set expectedBytesTotal(value:uint):void
		{
			this._expectedBytesTotal = value;
		}
		
		public function get expectedBytesTotal():uint
		{
			return _expectedBytesTotal;
		}

		/**
		 * The expected duration of the stream when it's a subclip, in seconds.
		 * This is different from expectedDuration when the stream being played
		 * is a subclip.  The default is NaN.
		 **/
		public function set expectedSubclipDuration(value:Number):void
		{
			this._expectedSubclipDuration = value;
		}
		
		public function get expectedSubclipDuration():Number
		{
			return _expectedSubclipDuration;
		}

		/**
		 * The expected width of the stream, in pixels.  Necessary so that
		 * this mock stream class knows the dimensions to include in the
		 * onMetaData callback.  The default is zero.
		 **/
		public function set expectedWidth(value:Number):void
		{
			this._expectedWidth = value;
		}
		
		public function get expectedWidth():Number
		{
			return _expectedWidth;
		}

		/**
		 * The expected array of cue points. Necessary so that this
		 * mock stream class can call the in-stream callback
		 * onCuePoint with the data you expect.
		 * 
		 * Each value in the array should be an object
		 * with the following properties:
		 * <ul>
		 * <li>type - should be "event", "navigation"</li>
		 * <li>time - the time in seconds of the cue point</li>
		 * <li>name - the name of the cue point (can be any string)</li>
		 * <li>parameters - optional array of key/value pairs</li>
		 * </ul>
		 */
		 public function set expectedCuePoints(value:Array):void
		 {
		 	this._expectedCuePoints = value;
		 }
		 
		 public function get expectedCuePoints():Array
		 {
		 	return this._expectedCuePoints;
		 }
		 
		/**
		 * The expected height of the stream, in pixels.  Necessary so that
		 * this mock stream class knows the dimensions to include in the
		 * onMetaData callback.  The default is zero.
		 **/
		public function set expectedHeight(value:Number):void
		{
			this._expectedHeight = value;
		}
		
		public function get expectedHeight():Number
		{
			return _expectedHeight;
		}
		
		/**
		 * An Array of EventInfos, representing the events that are expected
		 * to be dispatched when the playhead has passed a certain position.
		 **/
		public function set expectedEvents(value:Array):void
		{
			this._expectedEvents = value;
		}
		public function get expectedEvents():Array
		{
			return _expectedEvents;
		}
		
		// Overrides
		//
		
		override public function get bufferLength():Number
		{
			return bufferLengthSet ? _bufferLength : super.bufferLength;
		}
		
		public function set bufferLength(value:Number):void
		{
			bufferLengthSet = true;
			_bufferLength = value;
		}
		
		override public function get bytesLoaded():uint
		{
			return _bytesLoaded;
		}

		override public function get bytesTotal():uint
		{
			// The bytesTotal value doesn't "register" until playback begins.
			return (playing || elapsedTime > 0) ? _expectedBytesTotal : 0;
		}
		
		override public function get time():Number
		{
			// Return value is in seconds.
			return playing
						? (elapsedTime + (flash.utils.getTimer() - absoluteTimeAtLastPlay))/1000
						: elapsedTime;
		}
		
		override public function close():void
		{
			playing = false;
			elapsedTime = 0;

			playheadTimer.stop();
		}
		
		override public function play(...arguments):void
		{
			// The flash player sets the bufferTime to a 0.1 minimum for VOD (http://).
			if (arguments != null && arguments.length > 0 && arguments[0].toString().substr(0,4) == "http")
			{
				isProgressive = true;
				
				bufferTime = bufferTime < .1 ? .1 : bufferTime;
			}
			else
			{
				isProgressive = false;
				
				_expectedBytesTotal = 0;
			}

			commonPlay();
		}

		override public function play2(nso:NetStreamPlayOptions):void
		{
			if (nso.transition == NetStreamPlayTransitions.SWITCH)
			{
				var infos:Array =
						[ {"code":NetStreamCodes.NETSTREAM_PLAY_TRANSITION, "details":nso.streamName, "level":LEVEL_STATUS}
						];
				eventInterceptor.dispatchNetStatusEvents(infos, EVENT_DELAY);

				var newTimer:Timer = new Timer(350, 1);
				switchCompleteTimers.push(newTimer);
				newTimer.addEventListener(TimerEvent.TIMER_COMPLETE, sendSwitchCompleteMsg);
				newTimer.start();				
			}
			else
			{
				isProgressive = false;
				_expectedBytesTotal = 0;

				commonPlay();
			}
		}

		override public function pause():void
		{
			if (playing)
			{
				elapsedTime += ((flash.utils.getTimer() - absoluteTimeAtLastPlay) /1000);
			}
			playing = false;
			
			playheadTimer.stop();

			var infos:Array =
					[ {"code":NetStreamCodes.NETSTREAM_PAUSE_NOTIFY,	"level":LEVEL_STATUS}
					, {"code":NetStreamCodes.NETSTREAM_BUFFER_FLUSH,	"level":LEVEL_STATUS}
					];
			eventInterceptor.dispatchNetStatusEvents(infos, EVENT_DELAY);
		}

		override public function resume():void
		{
			absoluteTimeAtLastPlay = flash.utils.getTimer();
			playing = true;

			playheadTimer.start();

			var infos:Array =
					[ {"code":NetStreamCodes.NETSTREAM_UNPAUSE_NOTIFY, 	"level":LEVEL_STATUS}
					, {"code":NetStreamCodes.NETSTREAM_PLAY_START, 		"level":LEVEL_STATUS}
					, {"code":NetStreamCodes.NETSTREAM_BUFFER_FULL,		"level":LEVEL_STATUS}
					];
			eventInterceptor.dispatchNetStatusEvents(infos, EVENT_DELAY);
		}
		
		override public function seek(offset:Number):void
		{
			// Offset is in seconds.
			if (offset >= 0 && offset <= normalizedExpectedDuration)
			{
				// Reset the fake cue point logic
				this.lastFiredCuePointTime = -1;
				
				//elapsedTime = offset;
				if (playing)
				{
					absoluteTimeAtLastPlay = flash.utils.getTimer();
				}
				
				var infos:Array =
						[ {"code":NetStreamCodes.NETSTREAM_SEEK_NOTIFY, 	"level":LEVEL_STATUS}
						, {"code":NetStreamCodes.NETSTREAM_PLAY_START, 		"level":LEVEL_STATUS}
						, {"code":NetStreamCodes.NETSTREAM_BUFFER_FULL,		"level":LEVEL_STATUS}
						];
				eventInterceptor.dispatchNetStatusEvents(infos, EVENT_DELAY);
				
				// There's a bug in NetStream (FP-1705) where NetStream.time
				// doesn't get updated until after the NetStream.Seek.Notify
				// event is dispatched.  We mirror this bug here.
				var timer:Timer = new Timer(300, 1);
				timer.addEventListener(TimerEvent.TIMER, onNetStreamSeekBugTimer);
				timer.start();
				
				function onNetStreamSeekBugTimer(event:TimerEvent):void
				{
					timer.removeEventListener(TimerEvent.TIMER, onNetStreamSeekBugTimer);
					
					elapsedTime = offset;
				}
			}
			else
			{
				// TODO
			}
		}
		
		// Internals
		//
		
		private function onPlayheadTimer(event:TimerEvent):void
		{
			var infos:Array;
			if (time >= normalizedExpectedDuration)
			{
				elapsedTime = normalizedExpectedDuration;
				playing = false;
				
				playheadTimer.stop();
				
				// For progressive, the NetStream.Play.Stop event is fired upon
				// completion.  For streaming, the NetStream.Play.Complete event
				// is fired to onPlayStatus upon completion (and you might get
				// a number of NetStream.Play.Stop events during playback).
				//

				infos =
					[ {"code":NetStreamCodes.NETSTREAM_PLAY_STOP, 		"level":LEVEL_STATUS}
					, {"code":NetStreamCodes.NETSTREAM_BUFFER_FLUSH,	"level":LEVEL_STATUS}
					, {"code":NetStreamCodes.NETSTREAM_BUFFER_EMPTY,	"level":LEVEL_STATUS}
					];
				eventInterceptor.dispatchNetStatusEvents(infos);
				
				if (isProgressive == false)
				{
					this.client.onPlayStatus({code:NetStreamCodes.NETSTREAM_PLAY_COMPLETE});
				}
			}
			else
			{
				infos = getInfosForPosition(time);
				if (infos.length > 0)
				{
					eventInterceptor.dispatchNetStatusEvents(infos);
				}
				
				// Call in-stream onCuePoint if we passed an expected cue point.
				if (expectedCuePoints.length > 0)
				{
					for each (var info:Object in expectedCuePoints)
					{
						if ((time >= info.time) && (info.time > this.lastFiredCuePointTime))
						{
							// This will throw a Reference error if onCuePoint is not
							// implemented on the client object. No reason to eat that
							// exception here because this is an error. It means the caller
							// added expected cue points on a media element with no 
							// possible way of detecting them.
							this.client.onCuePoint(info);
							this.lastFiredCuePointTime = info.time;
							break;
						}
					}
				}
			}
			
			_bytesLoaded = Math.min(_expectedBytesTotal, _bytesLoaded + _expectedBytesTotal / 4);
		}
		
		private function getInfosForPosition(position:Number):Array
		{
			var infos:Array = [];
			
			for (var i:int = _expectedEvents.length; i > 0; i--)
			{
				var eventInfo:EventInfo = _expectedEvents[i-1];
				
				if (position >= eventInfo.position)
				{
					infos.push( {"code":eventInfo.code, "level":eventInfo.level} );
					
					// Remove the eventInfo, we don't want to dispatch
					// it twice.
					_expectedEvents.splice(i-1, 1);
				}
			}
			
			return infos;
		}
		
		private function get normalizedExpectedDuration():Number
		{
			return isNaN(expectedSubclipDuration) ? expectedDuration : expectedSubclipDuration;
		}
		
		private function commonPlay():void
		{
			if (expectedDuration != 0)
			{
				var info:Object = {};
				
				info["duration"] = expectedDuration;

				if (expectedWidth > 0)
				{
					info["width"] = expectedWidth;
				}
				if (expectedHeight > 0)
				{
					info["height"] = expectedHeight;
				}
				if (expectedCuePoints != null && expectedCuePoints.length > 0)
				{
					info["cuePoints"] = expectedCuePoints;
				}
				
				try
				{
					client.onMetaData(info);
				}
				catch (e:ReferenceError)
				{
					// Swallow, there's no such property on the client
					// and that's OK.
				}
			}
			
			absoluteTimeAtLastPlay = flash.utils.getTimer();
			playing = true;
			
			playheadTimer.start();
			
			var infos:Array =
					[ {"code":NetStreamCodes.NETSTREAM_PLAY_RESET, 	"level":LEVEL_STATUS}
					, {"code":NetStreamCodes.NETSTREAM_PLAY_START, 	"level":LEVEL_STATUS}
					, {"code":NetStreamCodes.NETSTREAM_BUFFER_FULL,	"level":LEVEL_STATUS}
					];
			eventInterceptor.dispatchNetStatusEvents(infos, EVENT_DELAY);
		}
		
		private function sendSwitchCompleteMsg(event:TimerEvent):void
		{
			var oldTimer:Timer = switchCompleteTimers.shift();
			oldTimer.removeEventListener(TimerEvent.TIMER, sendSwitchCompleteMsg);
			
			this.client.onPlayStatus({code:NetStreamCodes.NETSTREAM_PLAY_TRANSITION_COMPLETE});
		}		

		private var _connection:NetConnection;
		private var eventInterceptor:NetStatusEventInterceptor;
		private var _expectedDuration:Number = 0;
		private var _expectedBytesTotal:uint = 0;
		private var _expectedSubclipDuration:Number = NaN;
		private var _expectedWidth:Number = 0;
		private var _expectedHeight:Number = 0;
		private var _expectedEvents:Array = [];
		
		private var _expectedCuePoints:Array = [];
		private var lastFiredCuePointTime:int = -1;
		
		private var bufferLengthSet:Boolean = false;
		private var _bufferLength:Number;
		
		private var playheadTimer:Timer;
		private var switchCompleteTimers:Vector.<Timer> = new Vector.<Timer>;
		
		private var playing:Boolean = false;
		private var elapsedTime:Number = 0; // seconds

		private var absoluteTimeAtLastPlay:Number = 0; // milliseconds
		
		private var isProgressive:Boolean;
		private var _bytesLoaded:uint = 0;
		
		private static const TIMER_DELAY:int = 100;
		
		private static const EVENT_DELAY:int = 100;
		
		private static const LEVEL_STATUS:String = "status";
		private static const LEVEL_ERROR:String = "error";
	}
}