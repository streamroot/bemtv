/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.net.rtmpstreaming
{
	import flash.events.NetStatusEvent;
	
	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}
	
	import org.osmf.net.NetStreamCodes;
	import org.osmf.net.SwitchingRuleBase;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * InsufficientBufferRule is a switching rule that switches down when
	 * the buffer has insufficient data.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class InsufficientBufferRule extends SwitchingRuleBase
	{
		/**
		 * Constructor.
		 * 
		 * @param metrics The metrics provider used by this rule to determine
		 * whether to switch.
		 * @param minBufferLength The minimum buffer length that must be
		 * maintained before the rule suggests a switch down.  The default
		 * value is 2 seconds.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function InsufficientBufferRule(metrics:RTMPNetStreamMetrics, minBufferLength:Number=2)
		{
			super(metrics);
			
			_panic = false;
			this.minBufferLength = minBufferLength;
			metrics.netStream.addEventListener(NetStatusEvent.NET_STATUS, monitorNetStatus, false, 0, true);
		}
				
		/**
		 * @private
		 */
		override public function getNewIndex():int
		{
			var newIndex:int = -1;
			
			if (_panic || (rtmpMetrics.netStream.bufferLength < minBufferLength && rtmpMetrics.netStream.bufferLength > rtmpMetrics.netStream.bufferTime))
			{
				CONFIG::LOGGING
				{
					if (!_panic)
					{
						debug("Buffer of " + Math.round(rtmpMetrics.netStream.bufferLength)  + " < " + minBufferLength + " seconds");
					}
				}
				
				newIndex = 0;
			}
			
			CONFIG::LOGGING
			{
				if (newIndex != -1)
				{
					debug("getNewIndex() - about to return: " + newIndex + ", detail=" + _moreDetail);
				}
			} 
			
			return newIndex;
		}
		
		private function monitorNetStatus(e:NetStatusEvent):void 
		{
			switch (e.info.code) 
			{
				case NetStreamCodes.NETSTREAM_BUFFER_FULL:
					_panic = false;
					break;
				case NetStreamCodes.NETSTREAM_BUFFER_EMPTY:
					if (Math.round(rtmpMetrics.netStream.time) != 0)
					{
						_panic = true;
						_moreDetail = "Buffer was empty";
					}
					break;
				case NetStreamCodes.NETSTREAM_PLAY_INSUFFICIENTBW:
					_panic = true;
					_moreDetail = "Stream had insufficient bandwidth";
					break;
			}
		}
		
		private function get rtmpMetrics():RTMPNetStreamMetrics
		{
			return metrics as RTMPNetStreamMetrics;
		}

		CONFIG::LOGGING
		{
		private function debug(s:String):void
		{
			logger.debug(s);
		}
		}
				
		private var _panic:Boolean;
		private var _moreDetail:String;
		private var minBufferLength:Number;
				
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.rtmpstreaming.InsufficientBufferRule");
		}
	}
}
