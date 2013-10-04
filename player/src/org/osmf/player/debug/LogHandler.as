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

package org.osmf.player.debug
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	
	import org.osmf.logging.Log;
	import org.osmf.player.chrome.configuration.ConfigurationUtils;
	import org.osmf.player.debug.qos.IndicatorsBase;
	import org.osmf.player.debug.qos.QoSDashboard;

	/**
	 * The base defining the LogHandler behaviour.
	 * 
	 * By default it implements an ExternalInterface logging.
	 */ 
	public class LogHandler
	{		
		public var qos:QoSDashboard = new QoSDashboard();
		
		public function LogHandler(ignoreEmptyValues:Boolean = true)
		{
			this.ignoreEmptyValues = ignoreEmptyValues;
			timer = new Timer(MIN_UPDATE_INTERVAL);			
			timer.addEventListener(TimerEvent.TIMER, handleData);
			timer.start();	
		}
		
		public function handleProperty(composedKey:String, value:Object):void
		{			
			if (ignoreEmptyValues && value == null)
			{
				return;
			}
			if (value is Number || value is int || value is uint)
			{
				if (ignoreEmptyValues && value == 0)
				{
					return;
				}
				value = format(value);					
			}
			
			if (!qosIndicators.hasOwnProperty(composedKey))
			{
				qosProperties.push(composedKey);
				qosPropertiesSorted = false;	
			}
			
			if (qosIndicators[composedKey] != value)
			{	
				qosIndicators[composedKey] = value;
				changedQOSIndicators[composedKey] = value;
			}
		}
		
		public function handleLogMessage(logMessage:LogMessage):void
		{			
			logMessages.unshift(logMessage);
			if (logMessages.length > MAX_LOG_COUNT)
			{
				logMessages.pop();
			}
		}
		
		protected function handleData(event:Event = null):void
		{
			try
			{
				var jss:String = "";
				
				for each(var k:String in qos.getFields())
				{
					if (qos[k] is IndicatorsBase)
					{
						var indicators:IndicatorsBase = qos[k] as IndicatorsBase;
						for each(var ck:String in indicators.getFields())
						{
							jss += k+ "__"+ck + "==" + format(indicators[ck]);
							jss += LINE_SEPARATOR;
						}
					}
					else					
					{				
						jss += "KeyStats__"+k + "==" + format(qos[k]);
						jss += LINE_SEPARATOR;
					}
				}
				if (!qosPropertiesSorted)
				{
					qosProperties.sort();
					qosPropertiesSorted = true;
				}
				for each(var composedkey:String in qosProperties)
				{
					if (changedQOSIndicators.hasOwnProperty(composedkey))
					{
						jss += composedkey + "==" + format(changedQOSIndicators[composedkey]);
						jss += LINE_SEPARATOR;
					}
				}			
				if (jss.length > 0)
				{
					ExternalInterface.call("org.osmf.player.debug.track", jss);
				}
				changedQOSIndicators = new Object();
				
				if (logMessages.length > 0)
				{
					var logs:String = "";
					for each (var logMessage:LogMessage in logMessages)
					{
						logs += logMessage.toString();
						logs += LINE_SEPARATOR;
					}
					ExternalInterface.call(
						"org.osmf.player.debug.logs", 
						logs
					);	
					logMessages = new Vector.<LogMessage>();
				}
			}
			catch(_:Error)
			{
			}
		}

		// Internals
		//
		private function format(value:Object):Object
		{
			if (value is Number)
			{
				if (value > int.MAX_VALUE)
				{
					value = value.toPrecision(2);
				}
				else
				{
					if (value == int(value))
					{
						value = int(value);
					}
					else
					{
						value = value.toFixed(2);
					}
				}
			}
			return value;
		}
		
		private var ignoreEmptyValues:Boolean;
		private var timer:Timer;
		private var logCount:uint = 0;
		protected var qosIndicators:Object = new Object();
		protected var changedQOSIndicators:Object = new Object();
		protected var logMessages:Vector.<LogMessage> = new Vector.<LogMessage>();
		protected var qosProperties:Array = new Array();
		protected var qosPropertiesSorted:Boolean = true;

		private const MIN_UPDATE_INTERVAL:uint = 1000;
		private const MAX_LOG_COUNT:uint = 1000;
		private const LINE_SEPARATOR:String = "###";

	}
}