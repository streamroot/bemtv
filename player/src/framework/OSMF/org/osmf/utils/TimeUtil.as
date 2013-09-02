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
package org.osmf.utils
{
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Class that contains static utility methods for manipulating and working
	 * with time values.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class TimeUtil
	{
		/**
		 * Takes a time as a string and returns that time in seconds.
		 * <p>
		 * The following time values are supported:<ul>
		 * <li>full clock format in "hours:minutes:seconds" (for example 00:03:00).</li>
		 * <li>offset time (for example 10s or 2m).</li>
		 * </ul></p>
		 * Note: Offset times without units (for example 10) are assumed to be seconds.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function parseTime(value:String):Number 
		{
			var time:Number = 0;
			var a:Array = value.split(":");
			
			if (a.length > 1) 
			{
				// Clock format, e.g. "hh:mm:ss"
				time = a[0] * 3600;
				time += a[1] * 60;
				time += Number(a[2]);
			}
			else 
			{
				// Offset time format, e.g. "1h", "8m", "10s"
				var mul:int = 0;
				
				switch (value.charAt(value.length-1)) 
				{
					case 'h':
						mul = 3600;
						break;
					case 'm':
						mul = 60;
						break;
					case 's':
						mul = 1;
						break;
				}
				
				if (mul) 
				{
					time = Number(value.substr(0, value.length-1)) * mul;
				}
				else 
				{
					time = Number(value);
				}
			}
			
			return time;
		}

		/**
		 * Takes time in seconds and returns a string in a time code
		 * format of hh:mm:ss.  If hours are not present, returns only
		 * mm:ss. For example, passing a value of <code>18750</code> will
		 * return <code>05:12:30</code>, but passing a value of <code>31</code>
		 * will return <code>00:31</code>. So in other words, minutes and seconds 
		 * will always be present.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function formatAsTimeCode(sec:Number):String 
		{
			var h:Number = Math.floor(sec / 3600);
			h = isNaN(h) ? 0 : h;
			
			var m:Number = Math.floor((sec % 3600) / 60);
			m = isNaN(m) ? 0 : m;
			
			var s:Number = Math.floor((sec % 3600) % 60);
			s = isNaN(s) ? 0 : s;
			
			return (h == 0 ? "" : (h < 10 ? "0" + h.toString() + ":" : h.toString() + ":")) +
					(m < 10 ? "0" + m.toString() : m.toString()) + ":" + 
					(s < 10 ? "0" + s.toString() : s.toString());
		}
	}
}
