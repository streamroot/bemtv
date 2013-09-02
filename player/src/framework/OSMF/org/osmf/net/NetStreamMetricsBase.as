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
package org.osmf.net
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}

	/**
	 * The NetStreamMetricsBase class serves as a base class for a provider of
	 * run-time metrics to the NetStreamSwitchManager and its set of switching
	 * rules.  It calculates running averages for metrics that apply to all
	 * delivery methods.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class NetStreamMetricsBase extends EventDispatcher
	{		
		/**
		 * Constructor.
		 * 
		 * Note that for correct operation of this class, the caller must set the
		 * resource which the monitored stream is playing.
		 * 
		 * @param netStream The NetStream instance the class will monitor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function NetStreamMetricsBase(netStream:NetStream)
		{
			super();

			_netStream = netStream;
			
			_droppedFPS = 0;
			_lastFrameDropCounter = 0;
			_lastFrameDropValue = 0;
			_maxFPS = 0;
			_averageDroppedFPSArray = new Array();

			_timer = new Timer(DEFAULT_UPDATE_INTERVAL);
			_timer.addEventListener(TimerEvent.TIMER, onTimerEvent);

			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
		}

		/**
		 * Returns the DynamicStreamingResource which the class is referencing.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get resource():DynamicStreamingResource
		{
			return _resource;
		}
		
		public function set resource(value:DynamicStreamingResource):void 
		{
			_resource = value;
			_maxAllowedIndex = value != null ? value.streamItems.length - 1 : 0;
		}

		/**
		 * The NetStream object supplied to the constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get netStream():NetStream
		{
			return _netStream;
		}
		
		/**
		 * The current stream index.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get currentIndex():int
		{
			return _currentIndex;
		}
		
		public function set currentIndex(value:int):void 
		{
			_currentIndex = value;
		}
		
		/**
		 * The maximum allowed index value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get maxAllowedIndex():int 
		{
			return _maxAllowedIndex;
		}
		
		public function set maxAllowedIndex(value:int):void
		{
			_maxAllowedIndex = value;
		}
		
		/**
		 * The update interval (in milliseconds) at which metrics are recalculated.  If
		 * set to zero, then metrics will not be recalculated.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get updateInterval():Number 
		{
			return _timer.delay;
		}
		
		public function set updateInterval(value:Number):void 
		{
			_timer.delay = value;
			
			if (value <= 0)
			{
				_timer.stop();
			} 
		}
				
		/**
		 * The maximum achieved frame rate for this NetStream. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get maxFPS():Number
		{
			return _maxFPS;
		}
		
		/**
		 * The frame drop rate calculated over the last interval.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get droppedFPS():Number
		{
			return _droppedFPS;
		}
		
		/**
		 * The average frame-drop rate calculated over the life of the NetStream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get averageDroppedFPS():Number
		{
			return _averageDroppedFPS;
		}
		
		// Protected
		//
		
		/**
		 * Method invoked when the metrics should be recalculated.  If
		 * updateInterval is set, this method will be invoked whenever the
		 * updateInterval is reached.
		 **/
		protected function calculateMetrics():void
		{
			try 
			{
				// Estimate max (true) framerate.
				_maxFPS = netStream.currentFPS > _maxFPS ? netStream.currentFPS : _maxFPS;
				
				// Frame drop rate, per second, calculated over last second.
				if (_timer.currentCount - _lastFrameDropCounter > 1000 / _timer.delay) 
				{
					_droppedFPS = (netStream.info.droppedFrames - _lastFrameDropValue) / ((_timer.currentCount - _lastFrameDropCounter) * _timer.delay/1000);
					_lastFrameDropCounter = _timer.currentCount;
					_lastFrameDropValue = netStream.info.droppedFrames;
				}
				_averageDroppedFPSArray.unshift(_droppedFPS);
				if (_averageDroppedFPSArray.length > DEFAULT_AVG_FRAMERATE_SAMPLE_SIZE) 
				{
					_averageDroppedFPSArray.pop();
				}
				var totalDroppedFrameRate:Number = 0;
				for (var f:uint=0;f < _averageDroppedFPSArray.length;f++) 
				{
					totalDroppedFrameRate += _averageDroppedFPSArray[f];
				}
				
				_averageDroppedFPS = _averageDroppedFPSArray.length < DEFAULT_AVG_FRAMERATE_SAMPLE_SIZE ? 0 : totalDroppedFrameRate / _averageDroppedFPSArray.length;
				
			}
			catch (error:Error) 
			{
				CONFIG::LOGGING
				{
					logger.debug(".calculateMetrics() - " + error);
				}
				throw(error);
			}
		}
		
		// Internals
		//

		private function onNetStatusEvent(event:NetStatusEvent):void 
		{
			switch (event.info.code) 
			{
				case NetStreamCodes.NETSTREAM_PLAY_START:
					if (!_timer.running && updateInterval > 0) 
					{
						_timer.start();
					}
					break;
				case NetStreamCodes.NETSTREAM_PLAY_STOP:
					_timer.stop();
					break;
			}
		}
		
		private function onTimerEvent(event:TimerEvent):void 
		{
			if (isNaN(netStream.time))
			{
				_timer.stop();
			}
			else
			{
				calculateMetrics();
			}
		}
		
		private var _netStream:NetStream;
		private var _resource:DynamicStreamingResource;
		private var _currentIndex:int;
		private var _maxAllowedIndex:int;

		private var _timer:Timer;
		private var _averageDroppedFPSArray:Array;
		private var _averageDroppedFPS:Number;
		private var _droppedFPS:Number;
		private var _lastFrameDropValue:Number;
		private var _lastFrameDropCounter:Number;
		private var _maxFPS:Number;
		
		private static const DEFAULT_UPDATE_INTERVAL:Number = 100;
		private static const DEFAULT_AVG_FRAMERATE_SAMPLE_SIZE:Number = 50;
		
		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.NetStreamMetricsBase");
		}
	}
}
