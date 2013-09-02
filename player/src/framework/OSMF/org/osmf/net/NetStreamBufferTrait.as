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
package org.osmf.net
{
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	
	import org.osmf.traits.BufferTrait;

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The NetStreamBufferTrait class extends BufferTrait for NetStream buffering.
	 * 
	 * @see flash.net.NetStream
	 */  
	public class NetStreamBufferTrait extends BufferTrait
	{		
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function NetStreamBufferTrait(netStream:NetStream)
		{
			super();
			
			this.netStream = netStream;		
			bufferTime = netStream.bufferTime; 						
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);				
		}
		
		/**
		 *  @private
		 */ 
		override public function get bufferLength():Number
		{
			return netStream.bufferLength;
		}
		
		/**
		 * @private
		 * Communicates a <code>bufferTime</code> change to the media through the NetStream. 
		 *
		 * @param newTime New <code>bufferTime</code> value.
		 */											
		override protected function bufferTimeChangeStart(newTime:Number):void
		{
			netStream.bufferTime = newTime;
		}
				
		private function onNetStatus(event:NetStatusEvent):void
		{				
			switch (event.info.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_START:   // Once playing starts, we will be buffering (streaming and progressive, until we receive a Buffer.Full or Buffer.flush
				case NetStreamCodes.NETSTREAM_BUFFER_EMPTY:	 //Grab buffertime once again, since VOD will force it up to .1 from 0				
					bufferTime = netStream.bufferTime;
					setBuffering(true);

					// If we have a zero buffer time (e.g. for a live stream)
					// immediately exit buffer mode.  Note that we don't cancel
					// both setBuffering calls, because clients will typically
					// expect the buffering==false event.  See FM-530.
					if (netStream.bufferTime == 0)
					{				
						setBuffering(false);
					}
					break;
				case NetStreamCodes.NETSTREAM_BUFFER_FLUSH:
				case NetStreamCodes.NETSTREAM_BUFFER_FULL:
					setBuffering(false);
					break;
			}
		}
		
		private var netStream:NetStream;			
	}
}