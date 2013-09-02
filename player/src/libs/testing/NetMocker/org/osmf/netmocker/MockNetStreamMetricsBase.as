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
package org.osmf.netmocker
{
	import flash.net.NetStream;
	
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.NetStreamMetricsBase;

	public class MockNetStreamMetricsBase extends NetStreamMetricsBase
	{
		public function MockNetStreamMetricsBase(ns:NetStream)
		{
			super(ns);
			
			_frameDropRate = 0;
			_reachedTargetBufferFull = false;
			_lastFrameDropCounter = 0;
			_lastFrameDropValue = 0;
			_maxFrameRate = 0;
			_optimizeForLiveBandwidthEstimate = false;
			_avgMaxBitrateArray = new Array();
			_avgDroppedFrameRateArray = new Array();
			_enabled = true;
			_targetBufferTime = 0;
			_currentIndex = 0;
			_bufferLength = 0;
			_bufferTime = 0.1;
			_avgMaxBitrate = 0;
			_ns = ns;
		}

		public function get reachedTargetBufferFull():Boolean
		{
			return this._reachedTargetBufferFull;
		}
		
		public function set reachedTargetBufferFull(value:Boolean):void
		{
			this._reachedTargetBufferFull = value;
		}
		
		public function get expectedFPS():Number
		{
			return this._maxFrameRate;
		}
		
		public function set maxFrameRate(value:Number):void
		{
			this._maxFrameRate = value;
		}
		
		override public function get droppedFPS():Number
		{
			return this._frameDropRate;
		}
		
		public function set frameDropRate(value:Number):void
		{
			this._frameDropRate = value;
		}
		
		override public function get averageDroppedFPS():Number
		{
			return this._avgDroppedFrameRate;
		}
		
		public function set averageDroppedFPS(value:Number):void
		{
			this._avgDroppedFrameRate = value;
		}
		
		public function get maxBandwidth():Number
		{
			return this._lastMaxBitrate;
		}
		
		public function set lastMaxBitrate(value:Number):void
		{
			this._lastMaxBitrate = value;
		}
		
		public function get averageMaxBandwidth():Number
		{
			return this._avgMaxBitrate;
		}
		
		public function set avgMaxBitrate(value:Number):void
		{
			this._avgMaxBitrate = value;
		}
		
		override public function get currentIndex():int
		{
			return this._currentIndex;
		}
		
		override public function set currentIndex(value:int):void
		{
			this._currentIndex = value;
		}
		
		public function get maxIndex():int
		{
			return _dsResource.streamItems.length - 1;
		}
		
		public function get dynamicStreamingResource():DynamicStreamingResource
		{
			return this._dsResource;
		}
		
		public function set dynamicStreamingResource(value:DynamicStreamingResource):void
		{
			this._dsResource = value;
		}
		
		public function get bufferLength():Number
		{
			return this._bufferLength;
		}
		
		public function set bufferLength(value:Number):void
		{
			this._bufferLength = value;
		}
		
		public function get bufferTime():Number
		{
			return this._bufferTime;
		}
		
		public function set bufferTime(value:Number):void
		{
			this._bufferTime = value;
		}
		
		override public function get netStream():NetStream
		{
			return _ns;
		}
		
		public function get optimizeForLiveBandwidthEstimate():Boolean
		{
			return _optimizeForLiveBandwidthEstimate;
		}
		
		public function set optimizeForLiveBandwidthEstimate(value:Boolean):void
		{
			_optimizeForLiveBandwidthEstimate = value;
		}
				
		private var _reachedTargetBufferFull:Boolean;
		private var _currentBufferSize:Number;
		private var _maxBufferSize:Number;
		private var _lastMaxBitrate:Number;
		private var _avgMaxBitrateArray:Array;
		private var _avgMaxBitrate:Number;
		private var _avgDroppedFrameRateArray:Array;
		private var _avgDroppedFrameRate:Number;
		private var _frameDropRate:Number;
		private var _lastFrameDropValue:Number;
		private var _lastFrameDropCounter:Number;
		private var _maxFrameRate:Number
		private var _currentIndex:uint;
		private var _dsResource:DynamicStreamingResource;
		private var _targetBufferTime:Number;
		private var _enabled:Boolean;
		private var _optimizeForLiveBandwidthEstimate:Boolean;
		private var _bufferLength:Number;	
		private var _bufferTime:Number;
		private var _ns:NetStream;
	}
}
