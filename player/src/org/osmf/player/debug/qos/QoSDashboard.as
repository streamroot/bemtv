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
	 * The QoS Dashboard groups all the QoS indicators.
	 */ 
	public class QoSDashboard extends IndicatorsBase
	{	
		public var duration:Number;
		public var currentTime:Number;		
		public var downloadRatio:Number;
		public var downloadKbps:Number;
		public var playbackKbps:Number;
		public var lsoDownloadKbps:Number;		
		public var memory:Number;		
		public var droppedFrames:uint;
		public var avgDroppedFPS:Number;
		
		public var streamType:String;
		
		public var buffer:BufferIndicators = new BufferIndicators();
		public var rendering:RenderingIndicators = new RenderingIndicators();
		public var ds:DynamicStreamingIndicators = new DynamicStreamingIndicators();
	
		// Protected
		//
		
		override protected function getOrderedFieldList():Array
		{
			return [
				"duration",
				"currentTime",
				"downloadRatio",
				"downloadKbps",
				"playbackKbps", 
				"lsoDownloadKbps",
				"memory",
				"droppedFrames",
				"avgDroppedFPS" 
			];
		}
		
	}
}