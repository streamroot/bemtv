/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.net.dvr
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.Timer;
	
	import org.osmf.utils.OSMFStrings;
	
	[ExcludeClass]
	
	/**
	 * @private 
	 */	
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * @private
	 * 
	 * Helper class for obtaining a stream information record from an
	 * FMS DVRCast application.
	 * 
	 * The object helps in facilitating multiple retries on a given
	 * interval. By default, 5 attempts are made, 3 seconds apart.
	 */
	internal class DVRCastStreamInfoRetriever extends EventDispatcher
	{
		// Public Interface
		//
		
		public function DVRCastStreamInfoRetriever(connection:NetConnection, streamName:String)
		{
			super();
			
			if (connection == null || streamName == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			this.connection = connection;
			this.streamName = streamName;
		}
		
		public function get streamInfo():DVRCastStreamInfo
		{
			return _streamInfo;
		}
		
		public function get error():Object
		{
			return _error;
		}
		
		public function retrieve(retries:int = 5, timeOut:Number = 3):void
		{
			if (!isNaN(this.retries))
			{
				// Ignore the request: a retreival attempt is ongoing..
			}
			else
			{
				retries ||= 1;
				
				_streamInfo = null;
				_error = _error 
					= 	{ message : OSMFStrings.getString(OSMFStrings.DVR_MAXIMUM_RPC_ATTEMPTS).replace("%i", retries)
						};
				this.retries = retries;
				
				timer = new Timer(timeOut * 1000, 1);
				
				getStreamInfo();
			}
		}
		
		// Internals
		//
		
		private var connection:NetConnection;
		private var streamName:String;
		private var retries:Number;
		private var timer:Timer;
		
		private var _streamInfo:DVRCastStreamInfo;
		private var _error:Object;
		
		private function getStreamInfo():void
		{
			var responder:Responder = new TestableResponder(onGetStreamInfoResult, onServerCallError);
			
			retries--;
			
			connection.call(DVRCastConstants.RPC_GET_STREAM_INFO, responder, streamName);
		}

		private function onGetStreamInfoResult(result:Object):void
		{
			if (result && result.code == DVRCastConstants.RESULT_GET_STREAM_INFO_SUCCESS)
			{
				_error = null;
				_streamInfo = new DVRCastStreamInfo(result.data);
				complete();
			}
			else if (result && result.code == DVRCastConstants.RESULT_GET_STREAM_INFO_RETRY)
			{
				if (retries != 0)
				{
					timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
					timer.start();
				}
				else
				{
					complete();	
				}
			}
			else
			{
				_error = { message: OSMFStrings.getString(OSMFStrings.DVR_UNEXPECTED_SERVER_RESPONSE) + result.code}; // make const.
				complete();
			}
		}
		
		private function onServerCallError(error:Object):void
		{
			_error = error;
			complete();
		}
		
		private function onTimerComplete(event:TimerEvent):void
		{
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			getStreamInfo();
		}
		
		private function complete():void
		{
			retries = NaN;
			timer = null;
			dispatchEvent(new Event(Event.COMPLETE));
		}		
	}
}