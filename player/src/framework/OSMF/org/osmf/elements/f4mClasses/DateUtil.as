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
package org.osmf.elements.f4mClasses
{
	[ExcludeClass]

	/**
	* @private
	* 
	* 	Class that contains static utility methods for manipulating and working
	*	with Dates.
	* 
	* 	@langversion ActionScript 3.0
	*	@playerversion Flash 9.0
	*	@tiptext
	*  
	*  @langversion 3.0
	*  @playerversion Flash 10
	*  @playerversion AIR 1.5
	*  @productversion OSMF 1.0
	*/	
	internal class DateUtil
	{
	
		/**
		* Parses dates that conform to the W3C Date-time Format into Date objects.
		*
		* This function is useful for parsing RSS 1.0 and Atom 1.0 dates.
		*
		* @param str
		*
		* @returns
		*
		* @langversion ActionScript 3.0
		* @playerversion Flash 9.0
		* @tiptext
		*
		* @see http://www.w3.org/TR/NOTE-datetime
		*  
		*  @langversion 3.0
		*  @playerversion Flash 10
		*  @playerversion AIR 1.5
		*  @productversion OSMF 1.0
		*/		     
		public static function parseW3CDTF(str:String):Date
		{
            var finalDate:Date;
			try
			{
				var dateStr:String = str.substring(0, str.indexOf("T"));
				var timeStr:String = str.substring(str.indexOf("T")+1, str.length);
				var dateArr:Array = dateStr.split("-");
				var year:Number = Number(dateArr.shift());
				var month:Number = Number(dateArr.shift());
				var date:Number = Number(dateArr.shift());
				
				var multiplier:Number;
				var offsetHours:Number;
				var offsetMinutes:Number;
				var offsetStr:String;
				
				if (timeStr.indexOf("Z") != -1)
				{
					multiplier = 1;
					offsetHours = 0;
					offsetMinutes = 0;
					timeStr = timeStr.replace("Z", "");
				}
				else if (timeStr.indexOf("+") != -1)
				{
					multiplier = 1;
					offsetStr = timeStr.substring(timeStr.indexOf("+")+1, timeStr.length);
					offsetHours = Number(offsetStr.substring(0, offsetStr.indexOf(":")));
					offsetMinutes = Number(offsetStr.substring(offsetStr.indexOf(":")+1, offsetStr.length));
					timeStr = timeStr.substring(0, timeStr.indexOf("+"));
				}
				else // offset is -
				{
					multiplier = -1;
					offsetStr = timeStr.substring(timeStr.indexOf("-")+1, timeStr.length);
					offsetHours = Number(offsetStr.substring(0, offsetStr.indexOf(":")));
					offsetMinutes = Number(offsetStr.substring(offsetStr.indexOf(":")+1, offsetStr.length));
					timeStr = timeStr.substring(0, timeStr.indexOf("-"));
				}
				var timeArr:Array = timeStr.split(":");
				var hour:Number = Number(timeArr.shift());
				var minutes:Number = Number(timeArr.shift());
				var secondsArr:Array = (timeArr.length > 0) ? String(timeArr.shift()).split(".") : null;
				var seconds:Number = (secondsArr != null && secondsArr.length > 0) ? Number(secondsArr.shift()) : 0;
				var milliseconds:Number = (secondsArr != null && secondsArr.length > 0) ? Number(secondsArr.shift()) : 0;
				var utc:Number = Date.UTC(year, month-1, date, hour, minutes, seconds, milliseconds);
				var offset:Number = (((offsetHours * 3600000) + (offsetMinutes * 60000)) * multiplier);
				finalDate = new Date(utc - offset);
	
				if (finalDate.toString() == "Invalid Date")
				{
					throw new Error("This date does not conform to W3CDTF.");
				}
			}
			catch (e:Error)
			{
				var eStr:String = "Unable to parse the string [" +str+ "] into a date. ";
				eStr += "The internal error was: " + e.toString();
				throw new Error(eStr);
			}
            return finalDate;
		}
	 
	}
}
