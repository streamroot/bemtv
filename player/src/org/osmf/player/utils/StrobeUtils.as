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
 * 
 **********************************************************/

package org.osmf.player.utils
{
	/**
	 * Utilities, unit converters, etc
	 */ 
	public class StrobeUtils
	{
		public static const KBITSPS_BYTESTPS_RATIO:uint = 128;
		
		public static function kbitsPerSecond2BytesPerSecond(value:Number):Number
		{
			return value * KBITSPS_BYTESTPS_RATIO;
		}
		
		public static function bytesPerSecond2kbitsPerSecond(value:Number):Number
		{
			return value / KBITSPS_BYTESTPS_RATIO;
		}
		
		public static function bytes2String(value:Number):String
		{
			if (isNaN(value) || value == 0)
			{
				return value.toString();
			}
			
			var s:Array 	= ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB'];
			var e:Number 	= Math.floor( Math.log( value ) / Math.log( 1024 ) );
			return ( value / Math.pow( 1024, Math.floor( e ) ) ).toFixed( 2 ) + " " + s[e];	
		}
		
		public static function bytesPerSecond2String(value:Number):String
		{
			if (isNaN(value) || value == 0)
			{
				return value.toString();
			}
			var bitsps:Number = value * 8;
			var s:Array 	= ['bits/s', 'kbit/s', 'Mbit/s', 'Gbit/s', 'Tbit/s', 'Pbit/s'];
			var e:Number 	= Math.floor( Math.log( bitsps ) / Math.log( 1000 ) );
			return ( bitsps / Math.pow( 1000, Math.floor( e ) ) ).toFixed( 2 ) + " " + s[e];			
		}
		
		public static function bytesPerSecond2ByteString(value:Number):String
		{
			if (isNaN(value) || value == 0)
			{
				return value.toString();
			}
			var bitsps:Number = value;
			var s:Array 	= ['Bytes/s', 'KB/s', 'MB/s', 'GB/s', 'TB/s', 'PB/s'];
			var e:Number 	= Math.floor( Math.log( bitsps ) / Math.log( 1024 ) );
			return ( bitsps / Math.pow( 1024, Math.floor( e ) ) ).toFixed( 2 ) + " " + s[e];			
		}
		
		public static function retrieveHostNameFromUrl(url:String):String
		{
			var result:String = url;
			var startPosition:int = result.indexOf('://')+3;
			var endPosition:int = result.indexOf("/", startPosition);
			if (endPosition < 0)
			{
				endPosition = result.length; 
			}
			result = result.substring(startPosition, endPosition);
			return result;	 
		}
	}
}