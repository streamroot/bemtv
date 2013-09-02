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
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.TimeTrait;
	import org.osmf.utils.OSMFStrings;

	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	}

	[ExcludeClass]

	/**
	 * @private
	 */	
	internal class DVRCastTimeTrait extends TimeTrait
	{
		public function DVRCastTimeTrait(connection:NetConnection, stream:NetStream, resource:MediaResourceBase)
		{
			super(NaN);
			
			if (connection == null || stream == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			this.stream = stream;
			
			stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			
			durationUpdateTimer = new Timer(DVRCastConstants.LOCAL_DURATION_UPDATE_INTERVAL);
			durationUpdateTimer.addEventListener(TimerEvent.TIMER, onDurationUpdateTimer);
			durationUpdateTimer.start();
			
			streamInfo = resource.getMetadataValue(DVRCastConstants.STREAM_INFO_KEY) as DVRCastStreamInfo;
			recordingInfo = resource.getMetadataValue(DVRCastConstants.RECORDING_INFO_KEY) as DVRCastRecordingInfo;
		}
		
		override public function get duration():Number
		{
			var result:Number;
			
			if (streamInfo.isRecording)
			{
				// When the stream is being recorded:
				result
					// Initial duration available on play start:
					= (recordingInfo.startDuration - recordingInfo.startOffset)
					// Plus the timer measured elapsed time since play start:
					+ (new Date().time - recordingInfo.startTime.time) / 1000;
			}
			else
			{
				// When the stream is (currently) not recording, return the
				// last known length minus the starting offset:
				result = streamInfo.currentLength - recordingInfo.startOffset;				
			}
			
			// Make sure that the result is not negative:
			result = isNaN(result) ? NaN : Math.max(0, result);
										
			return result;
		}
		
		override public function get currentTime():Number
		{
			return stream.time;
		}
		
		// Internals
		//
		
		private var durationUpdateTimer:Timer;
		private var oldDuration:Number;
		
		private var stream:NetStream;
		
		private var streamInfo:DVRCastStreamInfo;
		private var recordingInfo:DVRCastRecordingInfo;
		
		private function onDurationUpdateTimer(event:TimerEvent):void
		{
			var newDuration:Number = duration;
			if (newDuration != oldDuration)
			{
				oldDuration = newDuration;
				dispatchEvent(new TimeEvent(TimeEvent.DURATION_CHANGE, false, false, newDuration));
			}
		}
		
		private function onNetStatus(event:NetStatusEvent):void
		{
			CONFIG::LOGGING { logger.debug("NetStatus: {0}", event.info.code); }
			
			if (event.info.code == "NetStream.Play.Stop")
			{
				if (durationUpdateTimer)
				{
					durationUpdateTimer.stop();
				}
				signalComplete();
			}
		}
		
		CONFIG::LOGGING
		{
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.net.dvr.DVRCastTimeTrait");		
		}	
	}
}