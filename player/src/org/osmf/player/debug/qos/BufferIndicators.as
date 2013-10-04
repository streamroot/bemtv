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

package org.osmf.player.debug.qos
{

	/**
	 * Stores the qos indicators related to Buffering. 
	 */ 
	public class BufferIndicators extends IndicatorsBase
	{
		public var percentage:Number = 0;
		public var time:Number = 0;
		public var length:Number = 0;
		public var eventCount:uint = 0;
		public var avgWaitDuration:Number = 0;
		public var totalWaitDuration:Number = 0;
		public var previousWaitDuration:Number = 0;		
		public var maxWaitDuration:Number = 0;
		
		override protected function getOrderedFieldList():Array
		{
			return [
				"percentage",
				"time",
				"length",
				"eventCount",
				"avgWaitDuration", 
				"totalWaitDuration", 
				"previousWaitDuration", 
				"maxWaitDuration"
			];
		}
	}
}