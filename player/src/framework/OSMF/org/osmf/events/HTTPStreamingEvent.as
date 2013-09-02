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
package org.osmf.events
{
	import flash.events.Event;
	
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataMode;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
	
	[ExcludeClass]
	
	/**
	 * @private
	 *
	 * This is an event class for common stream events. The stream could be 
	 * http stream or any other types of stream.
	 * 
	 */ 
	public class HTTPStreamingEvent extends Event
	{
		/**
		 * Dispatched when a transition operation has been initiated.
		 */
		public static const TRANSITION:String = "transition";
		
		/**
		 * Dispatched when a transition operation has been completed.
		 */
		public static const TRANSITION_COMPLETE:String = "transitionComplete";
		
		/**
		 * Dispatched when the end of a fragment/chunk has been reached.
		 */
		public static const BEGIN_FRAGMENT:String = "beginFragment";

		/**
		 * Dispatched when the end of a fragment/chunk has been reached.
		 */
		public static const END_FRAGMENT:String = "endFragment";
		
		/**
		 * Dispatched when the downloading of a fragment has been reached.
		 */
		public static const DOWNLOAD_COMPLETE:String = "downloadComplete";
		
		/**
		 * Dispatched when an error occurs while downloading a fragment.
		 */
		public static const DOWNLOAD_ERROR:String = "downloadError";
		
		/**
		 * Dispatched when the duration of the current fragment/chunk has been calculated.
		 */
		public static const FRAGMENT_DURATION:String = "fragmentDuration";

		/**
		 * Dispatched when the file handler has encounter an error.
		 */
		public static const FILE_ERROR:String = "fileError";
		
		/**
		 * Dispatched when the index handler has encouter an error.
		 */
		public static const INDEX_ERROR:String = "indexError";
		
		/**
		 * Dispacthed when script data needs to be passed between streaming objects.
		 */
		public static const SCRIPT_DATA:String = "scriptData";

		/**
		 * Dispacthed when streaming objects needs initializations.
		 */
		public static const ACTION_NEEDED:String = "actionNeeded";

		/**
		 * Default constructor.
		 */
		public function HTTPStreamingEvent(
				type:String, 
				bubbles:Boolean = false, 
				cancelable:Boolean = false,
				fragmentDuration:Number = 0,
				scriptDataObject:FLVTagScriptDataObject = null,
				scriptDataMode:String = FLVTagScriptDataMode.NORMAL,
				url:String = null
				)
		{
			super(type, bubbles, cancelable);
			
			_fragmentDuration = fragmentDuration;
			_scriptDataObject = scriptDataObject;
			_scriptDataMode   = scriptDataMode;
			_url = url;
		}
		
		/**
		 * Fragment duration.
		 */
		public function get fragmentDuration():Number
		{
			return _fragmentDuration;
		}
		
		/**
		 * Script data object.
		 */
		public function get scriptDataObject():FLVTagScriptDataObject
		{
			return _scriptDataObject;
		}
		
		/**
		 * Script data mode.
		 */
		public function get scriptDataMode():String
		{
			return _scriptDataMode;
		}

		/**
		 * Associated url.
		 */
		public function get url():String
		{
			return _url;
		}
		
		/**
		 * Clones the event.
		 */
		override public function clone():Event
		{
			return new HTTPStreamingEvent(
							type, 
							bubbles, 
							cancelable, 
							fragmentDuration, 
							scriptDataObject, 
							scriptDataMode,
							_url
					);
		}
		
		/// Internals
		private var _fragmentDuration:Number;
		private var _scriptDataObject:FLVTagScriptDataObject;
		private var _scriptDataMode:String;
		private var _url:String;
	}
}