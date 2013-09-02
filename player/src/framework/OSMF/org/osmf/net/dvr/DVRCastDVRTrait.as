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
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.DVRTrait;
	import org.osmf.utils.OSMFStrings;

	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	}

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Defines a DVRTrait subclass that interacts with a DVRCast equiped
	 * FMS server.
	 */	
	internal class DVRCastDVRTrait extends DVRTrait
	{
		/**
		 * @inherited
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		

		public function DVRCastDVRTrait(connection:NetConnection, stream:NetStream, resource:MediaResourceBase)
		{
			if (connection != null && stream != null)
			{
				this.stream = stream;
					
				streamInfo = resource.getMetadataValue(DVRCastConstants.STREAM_INFO_KEY) as DVRCastStreamInfo;
				recordingInfo = resource.getMetadataValue(DVRCastConstants.RECORDING_INFO_KEY) as DVRCastRecordingInfo;
				
				// Setup 
				streamInfoRetriever = new DVRCastStreamInfoRetriever(connection, streamInfo.streamName); 
				streamInfoRetriever.addEventListener(Event.COMPLETE, onStreamInfoRetrieverComplete);
				
				streamInfoUpdateTimer = new Timer(DVRCastConstants.STREAM_INFO_UPDATE_DELAY);
				streamInfoUpdateTimer.addEventListener(TimerEvent.TIMER, onStreamInfoUpdateTimer);
				streamInfoUpdateTimer.start(); 
					
				super(streamInfo.isRecording);
				
				updateProperties();
			}
			else
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
		}
		
		// Overrides
		//
		
		/**
		 * @private
		 * @inherited
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override protected function isRecordingChangeStart(value:Boolean):void
		{
			CONFIG::LOGGING { logger.debug("isRecordingChangeStart({0})", streamInfo.isRecording); }
			
			if (value)
			{
				// We're going into recording mode: update the start duration, and timer:
				recordingInfo.startDuration = streamInfo.currentLength;
				recordingInfo.startTime = new Date();
			}
			else
			{
				// We're leaving recording mode: nothing to do.
			}
		}
		
		// Internals
		//
		
		private var connection:NetConnection;
		private var stream:NetStream;
		
		private var streamInfo:DVRCastStreamInfo;
		private var recordingInfo:DVRCastRecordingInfo;
		
		private var streamInfoUpdateTimer:Timer;
		private var streamInfoRetriever:DVRCastStreamInfoRetriever; 
		
		private var offset:Number;
		
		private function updateProperties():void
		{
			setIsRecording(streamInfo.isRecording);
		}
		
		private function onStreamInfoUpdateTimer(event:TimerEvent):void
		{
			streamInfoRetriever.retrieve();
		}
		
		private function onStreamInfoRetrieverComplete(event:Event):void
		{
			if (streamInfoRetriever.streamInfo != null)
			{
				streamInfo.readFromDVRCastStreamInfo(streamInfoRetriever.streamInfo);
				updateProperties();
			}
			else
			{
				dispatchEvent
					( new MediaErrorEvent
						( MediaErrorEvent.MEDIA_ERROR
						, false, false
						, new MediaError(MediaErrorCodes.DVRCAST_STREAM_INFO_RETRIEVAL_FAILED)
						)
					);
			}
		}
		
		CONFIG::LOGGING
		{	
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.net.dvr.DVRCastDVRTrait");		
		}
	}
}