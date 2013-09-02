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
*  Contributor(s): Akamai Technologies
*  
*****************************************************/

package org.osmf.netmocker
{
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.utils.Timer;
	
	import org.osmf.net.NetConnectionCodes;

	/**
	 * Utility class for intercepting NetStatusEvents.
	 **/
	internal class NetStatusEventInterceptor
	{
		/**
		 * Constructor.
		 **/
		public function NetStatusEventInterceptor(netStatusEventDispatcher:IEventDispatcher)
		{
			this.netStatusEventDispatcher = netStatusEventDispatcher;
			
			// Intercept all events dispatched from the target.
			netStatusEventDispatcher.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent, false, int.MAX_VALUE);
		}

		/**
		 * Dispatch a single NetStatusEvent on the event dispatcher object for
		 * which this class is intercepting events.
		 * 
		 * @param code The NetStatusEvent code for the event.
		 * @param level The NetStatusEvent level for the event.
		 * @param delay An optional delay (in milliseconds) before the event is
		 * to be dispatched.
		 * @param nc A NetConnection which should be connected to null just prior to dispatching the delayed event.
		 **/
		public function dispatchNetStatusEvent(code:String, level:String, delay:int=0, nc:NetConnection = null, params:Array = null, signalRedirect:Boolean = false, fmsVersion:String = null):void
		{
			// Once a CONNECT_CLOSED event is received, we want to prohibit the dispatching of any events which have been
			// been queued-up for delayed dispatching.
			switch (code)
			{
				case NetConnectionCodes.CONNECT_CLOSED:
					isClosed = true;
					break;
				default:
					isClosed = false;
					break;
			}
			dispatchNetStatusEvents([{"code":code, "level":level, "nc":nc, "params":params}], delay, signalRedirect, fmsVersion);
		}
		
		/**
		 * Dispatch multiple NetStatusEvents on the event dispatcher object for
		 * which this class is intercepting events.
		 * 
		 * @param objectInfos An Array containing the NetStatusEvent info
		 * object for each event.  Each Object in the Array should have a
		 * "code" property and a "level" property.
		 * @param delay An optional delay (in milliseconds) before the events
		 * are to be dispatched.
		 **/
		public function dispatchNetStatusEvents(objectInfos:Array, delay:int=0, signalRedirect:Boolean=false, fmsVersion:String=null):void
		{
			if (delay > 0)
			{
				var timer:Timer = new Timer(delay, 1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, onDelayTimerComplete);
				timer.start()
				
				function onDelayTimerComplete(event:TimerEvent):void
				{
					timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onDelayTimerComplete);
					doDispatchNetStatusEvents(objectInfos, signalRedirect, fmsVersion);
				}
			}
			else
			{
				doDispatchNetStatusEvents(objectInfos, signalRedirect, fmsVersion);
			}
		}
		
		// Internals
		//
		
		private function doDispatchNetStatusEvents(objectInfos:Array, signalRedirect:Boolean=false, fmsVersion:String=null):void
		{
			var detailsValue:String = "";
			
			for each (var objectInfo:Object in objectInfos)
			{
				// Check to see if a NetConnection reference has been passed. If it has,
				// then connect it to null.
				if (objectInfo["nc"] is NetConnection)
				{
					var mockNetConnection:MockNetConnection = objectInfo["nc"] as MockNetConnection;
					if (mockNetConnection && mockNetConnection.expectation == NetConnectionExpectation.CONNECT_WITH_PARAMS)
					{
						// TODO: Need a better way of passing params through, for now it's
						// hardcoded so as to cause the expectation to pass.
						mockNetConnection.connect(null, "a", "b");
					}				
					else if(mockNetConnection && mockNetConnection.expectation == NetConnectionExpectation.CONNECT_WITH_FMTA)
					{						
						mockNetConnection.connect.call(mockNetConnection ,null,  objectInfo["params"]);
					}
					else
					{
						(objectInfo["nc"] as NetConnection).connect(null);
					}
				}
				
				// Check to see if there is a "details" property on the object
				if (objectInfo.hasOwnProperty("details"))
				{
					detailsValue = objectInfo["details"];
				}
				
				var infoObj:Object = {"code":objectInfo["code"], "level":objectInfo["level"], "details":detailsValue, "mockEvent":true};
				
				if (signalRedirect)
				{
					infoObj.ex = new Object();
					infoObj.ex.code = 302;
					infoObj.ex.redirect = "rtmp://example.com/redirect";
				}
				
				if (fmsVersion)
				{
					infoObj.data = new Object();
					infoObj.data.version = fmsVersion;
				}
				
				// Because this class intercepts all NetStatusEvents, we add a
				// marker to the info object (called "mockEvent") so that we
				// can distinguish between real events (which we want to swallow)
				// and mock events (which we don't).
				netStatusEventDispatcher.dispatchEvent(new NetStatusEvent
					( NetStatusEvent.NET_STATUS
					, false
					, false
					, infoObj
					)
				);
			}
		}

		private function onNetStatusEvent(event:NetStatusEvent):void
		{
			// Distinguish between events which originate from the dispatcher
			// class (and which we swallow) and events which originate from
			// this class (and which we don't).
			//
			// If the CONNECT_CLOSED event has been sent, swallow all delayed dispatches
			// until another event type is sent. If this is the CONNECT_CLOSED event itself, let it through. 
			if (event.info.hasOwnProperty("mockEvent") == false || (isClosed && event.info.code != NetConnectionCodes.CONNECT_CLOSED))
			{
				event.stopImmediatePropagation();
			}
			else
			{
				// Remove the "mock" marker, its an implementation detail of
				// this class, not something a client needs to know about.
				delete event.info.mockEvent;
			}
		}
		
		private var isClosed:Boolean = false;
		private var netStatusEventDispatcher:IEventDispatcher;
	}
}