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

package org.osmf.net
{
	import __AS3__.vec.Vector;
	
	import flash.errors.IllegalOperationError;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamPlayOptions;
	import flash.net.NetStreamPlayTransitions;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import org.osmf.utils.OSMFStrings;
	
	CONFIG::LOGGING
	{
	import org.osmf.player.debug.StrobeLogger;
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}
	
	/**
	 * NetStreamSwitchManager is a default implementation of
	 * NetStreamSwitchManagerBase.   It manages transitions between
	 * multi-bitrate (MBR) streams using configurable switching rules.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0	 	 	 
	 **/
	public class StrobeNetStreamSwitchManager extends NetStreamSwitchManagerBase
	{
		/**
		 * Constructor.
		 * 
		 * @param connection The NetConnection for the NetStream that will be managed.
		 * @param netStream The NetStream to manage.
		 * @param resource The DynamicStreamingResource that is playing in the NetStream.
		 * @param metrics The provider of runtime metrics.
		 * @param switchingRules The switching rules that this manager will use.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0	 	 	 
		 **/
		public function StrobeNetStreamSwitchManager
			( connection:NetConnection
			, netStream:NetStream
			, resource:DynamicStreamingResource
			, metrics:NetStreamMetricsBase
			, switchingRules:Vector.<SwitchingRuleBase>)
		{
			super();
			
			this.connection = connection;
			this.netStream = netStream;
			this.dsResource = resource;
			this.metrics = metrics;
			this.switchingRules = switchingRules || new Vector.<SwitchingRuleBase>();
			
			_currentIndex = Math.max(0, Math.min(maxAllowedIndex, dsResource.initialIndex));

			checkRulesTimer = new Timer(RULE_CHECK_INTERVAL);
			checkRulesTimer.addEventListener(TimerEvent.TIMER, checkRules);
			
			failedDSI = new Dictionary();
			
			// We set the bandwidth in both directions based on a multiplier applied to the bitrate level. 
			_bandwidthLimit = 1.4 * resource.streamItems[resource.streamItems.length-1].bitrate * 1000/8;
			
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			
			// Make sure we get onPlayStatus first (by setting a higher priority)
			// so that we can expose a consistent state to clients.
			NetClient(netStream.client).addHandler(NetStreamCodes.ON_PLAY_STATUS, onPlayStatus, int.MAX_VALUE);
		}
		
		/**
		 * @private
		 */
		override public function set autoSwitch(value:Boolean):void
		{
			super.autoSwitch = value;
			
			CONFIG::LOGGING
			{
				debug("autoSwitch() - setting to " + value);
			}
			
			if (autoSwitch)
			{
				CONFIG::LOGGING
				{
					debug("autoSwitch() - starting check rules timer.");
				}
				checkRulesTimer.start();
			}
			else
			{
				CONFIG::LOGGING
				{
					debug("autoSwitch() - stopping check rules timer.");
				}
				checkRulesTimer.stop();
			}
		}
		
		/**
		 * @private
		 */
		override public function get currentIndex():uint
		{
			return _currentIndex;
		}

		/**
		 * @private
		 */
		override public function get maxAllowedIndex():int 
		{
			var count:int = dsResource.streamItems.length - 1;
			return (count < super.maxAllowedIndex ? count : super.maxAllowedIndex);
		}
		
		/**
		 * @private
		 */
		override public function set maxAllowedIndex(value:int):void
		{
			if (value > dsResource.streamItems.length)
			{
				throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
			}
			super.maxAllowedIndex = value;
			metrics.maxAllowedIndex = value;
		}
		
		/**
		 * @private
		 **/
		override public function switchTo(index:int):void
		{
			if (!autoSwitch)
			{
				if (index < 0 || index > maxAllowedIndex)
				{
					throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
				}
				else
				{
					CONFIG::LOGGING
					{
						debug("switchTo() - manually switching to index: " + index);
					}
					
					if (metrics.resource == null)
					{
						prepareForSwitching();
					}
					executeSwitch(index);
				}
			}
			else
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_STREAM_NOT_IN_MANUAL_MODE));
			}
		}
		
		// Protected
		//
		
		/**
		 * Override this method to provide additional decisioning around
		 * allowing automatic switches to occur.  This method will be invoked
		 * just prior to a switch request.  If false is returned, that switch
		 * request will not take place.
		 * 
		 * <p>By default, the implementation does the following:</p>
		 * <p>1) When a switch down occurs, the stream being switched from has its
		 * failed count incremented. If, when the switching rules are evaluated
		 * again, a rule suggests switching up, since the stream previously
		 * failed, it won't be tried again until a duration (30s) elapses. This
		 * provides a better user experience by preventing a situation where
		 * the switch up is attempted but then fails almost immediately.</p>
		 * <p>2) Once a stream item has 3 failures, there will be no more
		 * attempts to switch to it until an interval (5m) has expired.  At the
		 * end of this interval, all failed counts are reset to zero.</p>
		 * 
		 * @param newIndex The new index to switch to.
		 **/
		protected function canAutoSwitchNow(newIndex:int):Boolean
		{
			// If this stream has failed, we don't want to try it again until 
			// the wait period has elapsed
			if (dsiFailedCounts[newIndex] >= 1)
			{
				var current:int = getTimer();
				if (current - failedDSI[newIndex] < DEFAULT_WAIT_DURATION_AFTER_DOWN_SWITCH)
				{
					CONFIG::LOGGING
					{
						debug("canAutoSwitchNow() - ignoring switch request because index " + newIndex + " has " + dsiFailedCounts[newIndex]+" failure(s) and only "+ (current - failedDSI[newIndex])/1000 + " seconds have passed since the last failure.");
					}
					return false;
				}
			}
			// If the requested index is currently locked out, then we don't
			// allow the switch.
			else if (dsiFailedCounts[newIndex] > DEFAULT_MAX_UP_SWITCHES_PER_STREAM_ITEM)
			{
				return false;
			}
			
			return true;
		}
		
		/**
		 * The multiplier to apply to the maximum bandwidth for the client.  The
		 * default is 140% of the highest bitrate stream.
		 **/
		protected final function get bandwidthLimit():Number
		{
			return _bandwidthLimit;
		}
		protected final function set bandwidthLimit(value:Number):void
		{
			_bandwidthLimit = value;
		}
						
		// Internals
		//
		
		/**
		 * Executes the switch to the specified index.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function executeSwitch(targetIndex:int, force:Boolean = false):void 
		{
			var nso:NetStreamPlayOptions = new NetStreamPlayOptions();

			var playArgs:Object = NetStreamUtils.getPlayArgsForResource(dsResource);

			nso.start = playArgs.start;
			nso.len = playArgs.len;
			nso.streamName = dsResource.streamItems[targetIndex].streamName;
			nso.oldStreamName = oldStreamName;
			if (force)
			{
				nso.transition = NetStreamPlayTransitions.RESET;
			}
			else
			{
				nso.transition = NetStreamPlayTransitions.SWITCH;
			}
			
			CONFIG::LOGGING
			{
				debug("executeSwitch() - Switching to index " + (targetIndex) + " at " + Math.round(dsResource.streamItems[targetIndex].bitrate) + " kbps");
				logger.qos.ds.targetIndex = targetIndex;
				logger.qos.ds.targetBitrate = Math.round(dsResource.streamItems[targetIndex].bitrate);
			}
						
			switching = true;
			switchingTimestamp = getTimer();
			
			netStream.play2(nso);
			
			oldStreamName = dsResource.streamItems[targetIndex].streamName;
			
			if (targetIndex < actualIndex && autoSwitch) 
			{
				// This is a failure for the current stream, so let's tag it as such.
				incrementDSIFailedCount(actualIndex);
				
				// Keep track of when it failed so we don't try it again for 
				// another failedItemWaitPeriod milliseconds to improve the
				// user experience.
				failedDSI[actualIndex] = getTimer();
			}
		}

		/**
		 * Checks all the switching rules. If a switching rule returns -1, it is 
		 * recommending no change.  If a switching rule returns a number greater than
		 * -1 it is recommending a switch to that index. This method uses the lesser of 
		 * all the recommended indices that are greater than -1.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function checkRules(event:TimerEvent):void 
		{			
			if (switchingRules == null || switching)
			{				
				CONFIG::LOGGING
				{
					var currentSwitchDuration:int = getTimer() - switchingTimestamp;					
					if (switching && currentSwitchDuration > 5000)
					{							
						logger.warn("Switch not complete after {0} sec.", currentSwitchDuration / 1000);								
					}
				}
				return;
			}
			var bufferRatio:Number = netStream.bufferLength / netStream.bufferTime;
			var newIndex:int = int.MAX_VALUE;
			
			for (var i:int = 0; i < switchingRules.length; i++) 
			{
				var n:int =  switchingRules[i].getNewIndex();

				if (n != -1 && n < newIndex) 
				{
					newIndex = n;
				} 
			}
			
			if (	newIndex != -1
				&& 	newIndex != int.MAX_VALUE
				&&	newIndex != actualIndex
			   )
			{
				newIndex = Math.min(newIndex, maxAllowedIndex);
			}
			
			if (	newIndex != -1
				&& 	newIndex != int.MAX_VALUE
				&&	newIndex != actualIndex
				&&	!switching
				&&	newIndex <= maxAllowedIndex
				&&  canAutoSwitchNow(newIndex)
				&& (netStream.bufferTime == 0 || (newIndex < actualIndex && bufferRatio < 1) || (newIndex > actualIndex && bufferRatio > 1))
			   ) 
			{
				CONFIG::LOGGING
				{
					debug("checkRules() - Calling for switch to " + newIndex + " at " + dsResource.streamItems[newIndex].bitrate + " kbps");
				}
				executeSwitch(newIndex);
			}  
		}
		
		private function onNetStatus(event:NetStatusEvent):void
		{
			CONFIG::LOGGING
			{
				debug("onNetStatus() - event.info.code=" + event.info.code);
			}
			
			switch (event.info.code) 
			{
				case NetStreamCodes.NETSTREAM_PLAY_START:
					if (metrics.resource == null)
					{
						prepareForSwitching();
					}
					else if (autoSwitch && checkRulesTimer.running == false)
					{
						checkRulesTimer.start();
					}
					break;
				case NetStreamCodes.NETSTREAM_PLAY_TRANSITION:
					switching  = false;
					actualIndex = dsResource.indexFromName(event.info.details);
					metrics.currentIndex = actualIndex;
					lastTransitionIndex = actualIndex;
					break;
				case NetStreamCodes.NETSTREAM_PLAY_FAILED:
					switching  = false;
					break;
				case NetStreamCodes.NETSTREAM_SEEK_NOTIFY:
					switching  = false;
					if (lastTransitionIndex >= 0)
					{
						_currentIndex = lastTransitionIndex;
					}					
					break;
				case NetStreamCodes.NETSTREAM_PLAY_STOP:
					checkRulesTimer.stop();
					CONFIG::LOGGING
					{
						debug("onNetStatus() - Stopping rules since server has stopped sending data");
					}
					break;
			}			
		}
				
		private function onPlayStatus(info:Object):void
		{
			CONFIG::LOGGING
			{
				debug("onPlayStatus() - info.code=" + info.code);
			}
			
			switch (info.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_TRANSITION_COMPLETE:
					if (lastTransitionIndex >= 0)
					{
						_currentIndex = lastTransitionIndex;
						lastTransitionIndex = -1;
					}
					
					CONFIG::LOGGING
					{
						debug("onPlayStatus() - Transition complete to index: " + currentIndex + " at " + Math.round(dsResource.streamItems[currentIndex].bitrate) + " kbps");
					}

					break;
			}
		}
		
		/**
		 * Prepare the manager for switching.  Note that this doesn't necessarily
		 * mean a switch is imminent.
		 **/
		private function prepareForSwitching():void
		{
			initDSIFailedCounts();
			
			metrics.resource = dsResource;
			
			actualIndex = 0;
			lastTransitionIndex = -1;
			
			if ((dsResource.initialIndex >= 0) && (dsResource.initialIndex < dsResource.streamItems.length))
			{
				actualIndex = dsResource.initialIndex;
			}

			if (autoSwitch)
			{
				checkRulesTimer.start();
			}
			
			setThrottleLimits(dsResource.streamItems.length - 1);
			CONFIG::LOGGING
			{
				debug("prepareForSwitching() - Starting with stream index " + actualIndex + " at " + Math.round(dsResource.streamItems[actualIndex].bitrate) + " kbps");
			}
			metrics.currentIndex = actualIndex;
		}
		
		private function initDSIFailedCounts():void
		{
			if (dsiFailedCounts != null)
			{
				dsiFailedCounts.length = 0;
				dsiFailedCounts = null;
			} 			
			
			dsiFailedCounts = new Vector.<int>();
			for (var i:int = 0; i < dsResource.streamItems.length; i++)
			{
				dsiFailedCounts.push(0);
			}
		}
		
		private function incrementDSIFailedCount(index:int):void
		{
			dsiFailedCounts[index]++;
			
			// Start the timer that clears the failed counts if one of them
			// just went over the max failed count
			if (dsiFailedCounts[index] > DEFAULT_MAX_UP_SWITCHES_PER_STREAM_ITEM)
			{
				if (clearFailedCountsTimer == null)
				{
					clearFailedCountsTimer = new Timer(DEFAULT_CLEAR_FAILED_COUNTS_INTERVAL, 1);
					clearFailedCountsTimer.addEventListener(TimerEvent.TIMER, clearFailedCounts);
				}
				
				clearFailedCountsTimer.start();
			}
		}
		
		private function clearFailedCounts(event:TimerEvent):void
		{
			clearFailedCountsTimer.removeEventListener(TimerEvent.TIMER, clearFailedCounts);
			clearFailedCountsTimer = null;
			initDSIFailedCounts();
		}
				
		private function setThrottleLimits(index:int):void 
		{
			connection.call("setBandwidthLimit", null, _bandwidthLimit, _bandwidthLimit);
		}

		CONFIG::LOGGING
		{
		private function debug(...args):void
		{
			//trace(new Date().toTimeString() + ">>> NetStreamSwitchManager." + args);
			logger.debug(new Date().toTimeString() + ">>> NetStreamSwitchManager." + args);
		}
		}
				
		private var netStream:NetStream;
		private var dsResource:DynamicStreamingResource;
		private var switchingRules:Vector.<SwitchingRuleBase>;
		private var metrics:NetStreamMetricsBase;
		private var checkRulesTimer:Timer;
		private var clearFailedCountsTimer:Timer;
		private var actualIndex:int = -1;
		private var oldStreamName:String;
		private var switching:Boolean;
		private var switchingTimestamp:int;
		private var _currentIndex:int;
		private var lastTransitionIndex:int = -1;
		private var connection:NetConnection;
		private var dsiFailedCounts:Vector.<int>;		// This vector keeps track of the number of failures 
														// for each DynamicStreamingItem in the DynamicStreamingResource
		private var failedDSI:Dictionary;
		private var _bandwidthLimit:Number = 0;;
														
		private static const RULE_CHECK_INTERVAL:Number = 2500;	// Switching rule check interval in milliseconds
		private static const DEFAULT_MAX_UP_SWITCHES_PER_STREAM_ITEM:int = 3;
		private static const DEFAULT_WAIT_DURATION_AFTER_DOWN_SWITCH:int = 30000;
		private static const DEFAULT_CLEAR_FAILED_COUNTS_INTERVAL:Number = 300000;	// default of 5 minutes for clearing failed counts on stream items
		
		CONFIG::LOGGING
		{
		//	private static const logger:Logger = Log.getLogger("org.osmf.net.NetStreamSwitchManager");		
			protected var logger:StrobeLogger = Log.getLogger("StrobeMediaPlayback") as StrobeLogger;
		}
	}
}