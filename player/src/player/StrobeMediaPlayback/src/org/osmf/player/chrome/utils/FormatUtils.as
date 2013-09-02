/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/

package org.osmf.player.chrome.utils
{
	/**
	 * Formatting utilities. 
	 */
	public class FormatUtils
	{
		public function FormatUtils()
		{
		}
		
		/**
		 * Formats a string suitable for displaying the current position of the playhead and the total duration of a media.
		 * 
		 * There are special formating rules for the currentPosition that depends on the total duration, that's why we format both values at the same time.
		 */ 
		public static function formatTimeStatus(currentPosition:Number, totalDuration:Number, isLive:Boolean=false, LIVE:String="Live"):Vector.<String>
		{
			var h:Number;
			var m:Number;
			var s:Number;
			function prettyPrintSeconds(seconds:Number, leadingMinutes:Boolean = false, leadingHours:Boolean = false):String
			{
				seconds = Math.floor(isNaN(seconds) ? 0.0 : Math.max(0.0, seconds));
				h = Math.floor(seconds / 3600.0);
				m = Math.floor(seconds % 3600.0 / 60.0);
				s = seconds % 60.0;
				return ((h > 0.0 || leadingHours) ? (h + ":") : "")
				+ (((h > 0.0 || leadingMinutes) && m < 10.0) ? "0" : "")
					+ m + ":" 
					+ (s < 10.0 ? "0" : "") 
					+ s;
			}	
						
			var totalDurationString:String =  isNaN(totalDuration) ? LIVE : prettyPrintSeconds(totalDuration);			
			var currentPositionString:String = isLive ? LIVE :  prettyPrintSeconds(currentPosition, h>0||m>9, h>0);
			
			while (currentPositionString.length < totalDurationString.length)
			{
				currentPositionString = ' ' + currentPositionString;
			}
			while (totalDurationString.length < currentPositionString.length)
			{
				totalDurationString = ' ' + totalDurationString;
			}
			
			var result:Vector.<String> = new Vector.<String>();
			result[0] = currentPositionString;
			result[1] = totalDurationString;
			return result;
		}
		
		
	}
}