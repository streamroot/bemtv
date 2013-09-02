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
package org.osmf.net
{
	/**
	 * DynamicStreamingItem represents a single stream in
	 * a DynamicStreamingResource.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class DynamicStreamingItem
	{
		/**
		 * Constructor.
		 * 
		 * @param streamName The stream name that will be passed to <code>NetStream.play()</code>
		 * @param bitrate The stream's encoded bitrate in kbps.
		 * @param width Optional width for the stream.
		 * @param height Optional height for the stream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function DynamicStreamingItem(streamName:String, bitrate:Number, width:int=-1, height:int=-1)
		{			
			_stream = streamName;
			_bitrate = bitrate;
			_width = width;
			_height = height;
		}
			
		/**
		 * The stream name that will be passed to <code>NetStream.play()</code>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get streamName():String
		{
			return _stream;
		}
		
		public function set streamName(value:String):void
		{
			_stream = value;
		}
		
		/**
		 * The stream's bitrate, specified in kilobits per second (kbps).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get bitrate():Number
		{
			return _bitrate;
		}
		
		public function set bitrate(value:Number):void
		{
			_bitrate = value;
		}
		
		/**
		 * The stream's encoded width or -1 if not specified.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get width():int
		{
			return _width;
		}
		
		public function set width(value:int):void
		{
			_width = value;
		}
		
		/**
		 * The stream's encoded height or -1 if not specified.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get height():int
		{
			return _height;
		}
		
		public function set height(value:int):void
		{
			_height = value;
		}
				
		private var _bitrate:Number;
		private var _stream:String;
		private var _width:int;
		private var _height:int;
	}
}
