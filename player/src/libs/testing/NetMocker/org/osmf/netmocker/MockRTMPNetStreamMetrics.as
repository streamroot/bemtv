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
*  Contributor: Adobe Systems Inc.
* 
*****************************************************/
package org.osmf.netmocker
{
	import flash.net.NetStream;
	
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;

	public class MockRTMPNetStreamMetrics extends RTMPNetStreamMetrics
	{
		public function MockRTMPNetStreamMetrics(netStream:NetStream)
		{
			super(netStream);
			
			_droppedFPS = 0;
			_maxFPS = 0;
			_averageDroppedFPS = 0;
			_enabled = true;
			_currentIndex = 0;
			_averageMaxBytesPerSecond = 0;
			_netStream = netStream;
		}

		override public function get maxFPS():Number
		{
			return _maxFPS;
		}
		
		public function set maxFPS(value:Number):void
		{
			_maxFPS = value;
		}
		
		override public function get droppedFPS():Number
		{
			return _droppedFPS;
		}
		
		public function set droppedFPS(value:Number):void
		{
			_droppedFPS = value;
		}
		
		override public function get averageDroppedFPS():Number
		{
			return _averageDroppedFPS;
		}
		
		public function set averageDroppedFPS(value:Number):void
		{
			_averageDroppedFPS = value;
		}
		
		
		override public function get averageMaxBytesPerSecond():Number
		{
			return _averageMaxBytesPerSecond;
		}
		
		public function set averageMaxBytesPerSecond(value:Number):void
		{
			_averageMaxBytesPerSecond = value;
		}
		
		override public function get currentIndex():int
		{
			return _currentIndex;
		}
		
		override public function set currentIndex(value:int):void
		{
			_currentIndex = value;
		}
		
		override public function get maxAllowedIndex():int
		{
			return _dsResource.streamItems.length - 1;
		}
		
		override public function get resource():DynamicStreamingResource
		{
			return _dsResource;
		}
		
		override public function set resource(value:DynamicStreamingResource):void
		{
			_dsResource = value;
		}
		
		override public function get netStream():NetStream
		{
			return _netStream;
		}
		
		private var _averageMaxBytesPerSecond:Number;
		private var _averageDroppedFPS:Number;
		private var _droppedFPS:Number;
		private var _maxFPS:Number;
		private var _currentIndex:int;
		private var _dsResource:DynamicStreamingResource;
		private var _enabled:Boolean;
		private var _netStream:NetStream;
	}
}
