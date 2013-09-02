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
	
	import org.osmf.utils.OSMFStrings;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Reflects the stream properties as exposed by DVRCast. 
	 */	
	public class DVRCastStreamInfo
	{
		public var callTime:Date;
		public var offline:Boolean;
		public var beginOffset:Number;
		public var endOffset:Number;
		public var windowDuration:Number;
		public var recordingStart:Date;
		public var recordingEnd:Date;
		public var isRecording:Boolean;
		public var streamName:String;
		public var lastUpdate:Date;
		public var currentLength:Number;
		public var maxLength:Number;
		
		public function DVRCastStreamInfo(value:Object):void
		{
			readFromDynamicObject(value);
		}
		
		public function readFromDynamicObject(value:Object):void
		{
			try
			{
				callTime = value.callTime;
				offline = value.offline;
				beginOffset = value.begOffset;
				endOffset = value.endOffset;
				windowDuration = value.windowDuration;
				recordingStart = value.startRec;
				recordingEnd = value.stopRec;
				isRecording = value.isRec;
				streamName = value.streamName;
				lastUpdate = value.lastUpdate;
				currentLength = value.currLen;
				maxLength = value.maxLen;
			}
			catch (e:Error)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
		}
		
		public function readFromDVRCastStreamInfo(value:DVRCastStreamInfo):void
		{
			try
			{
				callTime = value.callTime;
				offline = value.offline;
				beginOffset = value.beginOffset;
				endOffset = value.endOffset;
				windowDuration = value.windowDuration;
				recordingStart = value.recordingStart;
				recordingEnd = value.recordingEnd;
				isRecording = value.isRecording;
				streamName = value.streamName;
				lastUpdate = value.lastUpdate;
				currentLength = value.currentLength;
				maxLength = value.maxLength;
			}
			catch (e:Error)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
		}
		
		public function toString():String
		{
			return "callTime: " + callTime
				 + "\noffline: " + offline
				 + "\nbeginOffset: " + beginOffset
				 + "\nendOffset: " + endOffset
				 + "\nwindowDuration: " + windowDuration
				 + "\nrecordingStart: " + recordingStart
				 + "\nrecordingEnd: " + recordingEnd
				 + "\nisRecording: " + isRecording
				 + "\nstreamName: " + streamName
				 + "\nlastUpdate: " + lastUpdate
				 + "\ncurrentLength: " + currentLength
				 + "\nmaxLength: " + maxLength;
		}
	}
}