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
	import org.osmf.net.SwitchingRuleBase;

	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}
	
	/**
	 * SufficientBandwidthRule is a switching rule that switches up when the
	 * user has sufficient bandwidth to do so.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class SufficientBandwidthRule extends SwitchingRuleBase
	{
		/**
		 * Constructor.
		 * 
		 * @param metrics The metrics provider used by this rule to determine
		 * whether to switch.
		 **/
		public function SufficientBandwidthRule(metrics:RTMPNetStreamMetrics)
		{
			super(metrics);
		}

		/**
		 * @private
		 */
        override public function getNewIndex():int 
        {
        	var newIndex:int = -1;
        	var moreDetail:String;
        	
        	// Wait until the metrics class can calculate a stable average bandwidth
        	if (rtmpMetrics.averageMaxBytesPerSecond != 0) 
        	{
				// First find the preferred bitrate level we should be at by finding
				// the highest profile that can play, given the current average max
				// bytes per second.
				for (var i:int = rtmpMetrics.resource.streamItems.length - 1; i >= 0; i--) 
				{
					if (rtmpMetrics.averageMaxBytesPerSecond * 8 / 1024 > (rtmpMetrics.resource.streamItems[i].bitrate * BANDWIDTH_SAFETY_MULTIPLE)) 
					{
						newIndex = i;
						break;
					}
				}
								
				// If we are about to recommend a switch up, check some other metrics
				// to verify the recommendation
				if (newIndex > rtmpMetrics.currentIndex) 
				{
	        		// We switch up only if conditions are perfect - no framedrops and
	        		// a stable buffer.
	        		newIndex = (rtmpMetrics.droppedFPS < MIN_DROPPED_FPS && rtmpMetrics.netStream.bufferLength > rtmpMetrics.netStream.bufferTime) ? newIndex : -1;
	        		
					CONFIG::LOGGING
					{
		        		if (newIndex != -1)
		        		{
	        				debug("Move up since avg dropped FPS " + Math.round(rtmpMetrics.droppedFPS) + " < " + MIN_DROPPED_FPS + " and bufferLength > " + rtmpMetrics.netStream.bufferTime);
	        			}
	        		}
	        	}
	        	else
	        	{
	        		newIndex = -1;
	        	}
        	} 
        	
			CONFIG::LOGGING
			{
	        	if (newIndex != -1)
    	    	{
        			debug("getNewIndex() - about to return: " + newIndex + ", detail=" + moreDetail);
        		}
        	}
        	         	 
        	return newIndex;
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
		
		private static const BANDWIDTH_SAFETY_MULTIPLE:Number = 1.15;
		private static const MIN_DROPPED_FPS:int = 2;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.rtmpstreaming.SufficientBandwidthRule");
		}
	}
}
