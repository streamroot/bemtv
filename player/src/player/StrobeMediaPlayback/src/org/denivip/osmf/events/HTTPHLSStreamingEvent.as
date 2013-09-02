/*****************************************************
 *  
 *  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
 *****************************************************/
package org.denivip.osmf.events
{
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.events.HTTPStreamingEventReason;
	import org.osmf.net.httpstreaming.HTTPStreamDownloader;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataMode;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
	
	/**
	 * @private
	 *
	 * This is an event class for common stream events. The stream could be 
	 * http stream or any other types of stream.
	 * 
	 */ 
	public class HTTPHLSStreamingEvent extends HTTPStreamingEvent
	{
		/**
		 * Discontinuity HLS event
		 */
		public static const DISCONTINUITY:String = "discontinuity";

		/**
		 * Default constructor.
		 */
		public function HTTPHLSStreamingEvent(
				type:String, 
				bubbles:Boolean = false, 
				cancelable:Boolean = false,
				fragmentDuration:Number = 0,
				scriptDataObject:FLVTagScriptDataObject = null,
				scriptDataMode:String = FLVTagScriptDataMode.NORMAL,
				url:String = null,
				bytesDownloaded:uint = 0,
				reason:String = HTTPStreamingEventReason.NORMAL,
				downloader:HTTPStreamDownloader = null
				)
		{
			super(type,
				bubbles,
				cancelable,
				fragmentDuration,
				scriptDataObject,
				scriptDataMode,
				url,
				bytesDownloaded,
				reason,
				downloader);
		}
	}
}
