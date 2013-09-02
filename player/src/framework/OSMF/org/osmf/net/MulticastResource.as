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
package org.osmf.net
{
	import flash.utils.ByteArray;
	
	/**
	 * MulticastResource is a StreamingURLResource which is capable of carrying multicast
	 * streaming information. It exposes properties of groupspec and streamName, necessary
	 * to make a multicast connection and create multicast stream.
	 * 
	 * @includeExample MulticastPlayer
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class MulticastResource extends StreamingURLResource
	{
		public function MulticastResource(
			url:String, 
			groupspec:String=null, 
			streamName:String=null,
			connectionArguments:Vector.<Object>=null, 
			urlIncludesFMSApplicationInstance:Boolean=false, 
			drmContentData:ByteArray=null)
		{
			super(url, StreamType.LIVE, NaN, NaN, connectionArguments, urlIncludesFMSApplicationInstance, drmContentData);

			_groupspec = groupspec;
			_streamName = streamName;
		}
		
		/**
		 * The group spec string for multicasting.
		 **/
		public function get groupspec():String
		{
			return _groupspec;
		}
		
		public function set groupspec(value:String):void
		{
			_groupspec = value;
		}
		
		/**
		 * The stream name string for multicasting.
		 **/
		public function get streamName():String
		{
			return _streamName;
		}
		
		public function set streamName(value:String):void
		{
			_streamName = value;
		}
		
		//
		// internal
		//
		private var _groupspec:String;
		private var _streamName:String;
	}
}