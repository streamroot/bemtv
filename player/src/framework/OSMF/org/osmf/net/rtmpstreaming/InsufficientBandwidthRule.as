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
	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}
	
	import org.osmf.net.SwitchingRuleBase;
	import org.osmf.utils.OSMFStrings;

	/**
	 * InsufficientBandwidthRule is a switching rule that switches down when
	 * the bandwidth is insufficient for the current stream.
	 * 
	 * <p>When comparing stream bitrates to available bandwidth, the class uses
	 * a "bitrate multiplier" against which the stream bitrate is multiplied.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class InsufficientBandwidthRule extends SwitchingRuleBase
	{
		/**
		 * Constructor.
		 * 
		 * @param metrics The metrics provider used by this rule to determine
		 * whether to switch.
		 * @param bitrateMultiplier A multiplier that is used when the stream
		 * bitrate is compared against available bandwidth.  The stream bitrate
		 * is multiplied by this amount.  The default is 1.15.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function InsufficientBandwidthRule(metrics:RTMPNetStreamMetrics, bitrateMultiplier:Number=1.15)
		{
			super(metrics);
			
			this.bitrateMultiplier = bitrateMultiplier;
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
				// See if we need to switch down based on average max bytes per second
				for (var i:int = rtmpMetrics.currentIndex; i >= 0; i--) 
				{
					if (rtmpMetrics.averageMaxBytesPerSecond * 8 / 1024 > (rtmpMetrics.resource.streamItems[i].bitrate * bitrateMultiplier)) 
					{
						newIndex = i;
						break;
					}
				}
				
				newIndex = (newIndex == rtmpMetrics.currentIndex) ? -1 : newIndex;
				
				CONFIG::LOGGING
				{
					if ((newIndex != -1) && (newIndex < rtmpMetrics.currentIndex))
					{
						debug("Average bandwidth of " + Math.round(rtmpMetrics.averageMaxBytesPerSecond) + " < " + bitrateMultiplier + " * rendition bitrate");
					}
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

		private var bitrateMultiplier:Number;
			
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.rtmpstreaming.InsufficientBandwidthRule");
		}
	}
}
