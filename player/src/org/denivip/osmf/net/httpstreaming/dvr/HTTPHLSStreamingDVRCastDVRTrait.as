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

package org.denivip.osmf.net.httpstreaming.dvr
{
	import flash.net.NetConnection;
	
	import org.denivip.osmf.net.httpstreaming.hls.HTTPHLSNetStream;
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.traits.DVRTrait;
	
	/**
	 * @private
	 * 
	 * Defines a DVRTrait subclass that interacts with a DVRCast equiped
	 * http streaming.
	 */	
	public class HTTPHLSStreamingDVRCastDVRTrait extends DVRTrait
	{
		public function HTTPHLSStreamingDVRCastDVRTrait(connection:NetConnection, stream:HTTPHLSNetStream, dvrInfo:DVRInfo)
		{
			_connection = connection;
			_stream = stream; 
			_dvrInfo = dvrInfo;
			_stream.addEventListener(DVRStreamInfoEvent.DVRSTREAMINFO, onDVRStreamInfo);
			
			super(dvrInfo.isRecording, dvrInfo.windowDuration);			
		}
		
		//
		// Internal
		//
		
		private function onDVRStreamInfo(event:DVRStreamInfoEvent):void
		{
			_dvrInfo = event.info as DVRInfo;
			setIsRecording(_dvrInfo == null? false : _dvrInfo.isRecording);
		}
		
		private var _connection:NetConnection;
		private var _stream:HTTPHLSNetStream;
		private var _dvrInfo:DVRInfo;
	}
}