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
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	import org.denivip.osmf.net.httpstreaming.hls.HTTPHLSNetStream;
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.net.NetClient;
	import org.osmf.net.NetStreamCodes;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.traits.TimeTrait;

	/**
	 * @private
	 */	
	public class HTTPHLSStreamingDVRCastTimeTrait extends TimeTrait
	{
		public function HTTPHLSStreamingDVRCastTimeTrait(connection:NetConnection, stream:HTTPHLSNetStream, dvrInfo:DVRInfo)
		{
			super(NaN);

			_connection = connection;
			_stream = stream; 
			_dvrInfo = dvrInfo;
			_stream.addEventListener(DVRStreamInfoEvent.DVRSTREAMINFO, onDVRStreamInfo);
			_stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			NetClient(_stream.client).addHandler(NetStreamCodes.ON_PLAY_STATUS, onPlayStatus);
		}
		
		override public function get duration():Number
		{
			if (_dvrInfo == null)
			{
				return NaN;
			}
			
			return _dvrInfo.curLength;
		}
		
		override public function get currentTime():Number
		{
			return _stream.time;
		}
		
		//
		// Internal
		//
		
		private function onDVRStreamInfo(event:DVRStreamInfoEvent):void
		{
			_dvrInfo = event.info as DVRInfo;
			setDuration(_dvrInfo.curLength);
		}
		
		private function onNetStatus(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_UNPUBLISH_NOTIFY:
					// When a live stream is unpublished, we should signal that
					// the stream has stopped.
					signalComplete();
					break;
			}
		}
		
		private function onPlayStatus(event:Object):void
		{			
			switch(event.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_COMPLETE:
					// For streaming, NetStream.Play.Complete means playback
					// has completed.  But this isn't fired for progressive.
					signalComplete();
					break;
			}
		}

		private var _connection:NetConnection;
		private var _stream:HTTPHLSNetStream;
		private var _dvrInfo:DVRInfo;
	}
}