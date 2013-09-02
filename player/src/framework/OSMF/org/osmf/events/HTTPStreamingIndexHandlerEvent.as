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
	import flash.net.URLRequest;
	
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataMode;
	
	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class HTTPStreamingIndexHandlerEvent extends HTTPStreamingEvent
	{
		/**
		 * Dispatched when the index is ready and processed.
		 */
		public static const INDEX_READY:String = "indexReady";
		
		/**
		 * Dispatched when the rates become available.
		 */
		public static const RATES_READY:String = "ratesReady";
		
		/**
		 * Dispatched when the index handler needs to reload the index file.
		 */
		public static const REQUEST_LOAD_INDEX:String = "requestLoadIndex";

		/**
		 * Default constructor.
		 */
		public function HTTPStreamingIndexHandlerEvent(
				type:String, 
				bubbles:Boolean=false, 
				cancelable:Boolean=false,
				live:Boolean = false,
				offset:Number = NaN,
				streamNames:Array = null, 
				rates:Array = null, 
				request:URLRequest = null,
				requestContext:Object = null,
				binaryData:Boolean = true,
				fragmentDuration:Number = 0,
				scriptDataObject:FLVTagScriptDataObject = null,
				scriptDataMode:String = FLVTagScriptDataMode.NORMAL
				)
		{
			super(type, bubbles, cancelable, fragmentDuration, scriptDataObject, scriptDataMode);
			
			_live = live;
			_offset = offset;
			_streamNames = streamNames;
			_rates = rates;
			_request = request;
			_requestContext = requestContext;
			_binaryData = binaryData;
		}
		
		public function get live():Boolean
		{
			return _live;
		}

		public function get offset():Number
		{
			return _offset;
		}
		
		public function get streamNames():Array
		{
			return _streamNames;
		}
		
		public function get rates():Array
		{
			return _rates;
		}

		public function get request():URLRequest
		{
			return _request;
		}

		public function get requestContext():Object
		{
			return _requestContext;
		}
		
		public function get binaryData():Boolean
		{
			return _binaryData;
		}
		
		override public function clone():Event
		{
			return new HTTPStreamingIndexHandlerEvent
				( type
				, bubbles
				, cancelable
				, live
				, offset
				, streamNames
				, rates
				, request
				, requestContext
				, binaryData
				, fragmentDuration
				, scriptDataObject
				, scriptDataMode
				);
		}
		
		/// Internal
		private var _streamNames:Array;
		private var _rates:Array;
		private var _request:URLRequest;
		private var _requestContext:Object;
		private var _binaryData:Boolean;
		private var _live:Boolean;
		private var _offset:Number;
	}
}