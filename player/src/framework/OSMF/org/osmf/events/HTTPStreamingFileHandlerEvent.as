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
*****************************************************/
package org.osmf.events
{
	import flash.events.Event;
	
	import org.osmf.net.httpstreaming.f4f.AdobeBootstrapBox;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataMode;

	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class HTTPStreamingFileHandlerEvent extends HTTPStreamingEvent
	{
		/**
		 * Dispatched when the file handler detects a bootstrap box inside 
		 * stream.
		 */
		public static const NOTIFY_BOOTSTRAP_BOX:String = "notifyBootstrapBox";
		
		/**
		 * Default constructor.
		 */
		public function HTTPStreamingFileHandlerEvent(
				type:String, 
				bubbles:Boolean = false, 
				cancelable:Boolean = false, 
				fragmentDuration:Number = 0,
				scriptDataObject:FLVTagScriptDataObject = null,
				scriptDataMode:String = FLVTagScriptDataMode.NORMAL,
				abst:AdobeBootstrapBox = null)	
		{
			super(type, bubbles, cancelable, fragmentDuration, scriptDataObject, scriptDataMode);
			
			_abst = abst;
		}

		/**
		 * Bootstrap information.
		 */		
		public function get bootstrapBox():AdobeBootstrapBox
		{
			return _abst;
		}
		
		/**
		 * Clones the event.
		 */
		override public function clone():Event
		{
			return new HTTPStreamingFileHandlerEvent(
							type, 
							bubbles, 
							cancelable, 
							fragmentDuration, 
							scriptDataObject, 
							scriptDataMode, 
							bootstrapBox 
						);
		}
				
		// Internal
		private var _abst:AdobeBootstrapBox;
	}
}