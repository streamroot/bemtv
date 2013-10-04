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
	 * Stores the qos indicators related to DynamicStreaming. 
	 */ 
	public class DynamicStreamingIndicators extends IndicatorsBase
	{	
		public var index:uint;
		public var numDynamicStreams:uint;
		public var currentBitrate:uint;
		public var previousSwitchDuration:Number;
		public var totalSwitchDuration:Number = 0;
		public var dsSwitchEventCount:uint;
		public var avgSwitchDuration:Number;
		public var currentVerticalResolution:Number;
		public var bestVerticalResolution:Number;
		public var bestHorizontatalResolution:Number;
		
		public var targetIndex:int;
		public var targetBitrate:Number;
		override protected function getOrderedFieldList():Array
		{
			return [
				"index",
				"numDynamicStreams",
				"currentBitrate",
				"previousSwitchDuration",
				"totalSwitchDuration", 
				"dsSwitchEventCount", 
				"avgSwitchDuration", 
				"currentVerticalResolution",
				"bestVerticalResolution",
				"bestHorizontatalResolution"
			];
		}
	}
}