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
package org.osmf.net.httpstreaming.f4f
{
	import __AS3__.vec.Vector;
	
	import flash.utils.ByteArray;
	
	import org.osmf.net.httpstreaming.HTTPStreamingIndexInfoBase;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Info object which is used to initialize the F4F index.
	 */
	public class HTTPStreamingF4FIndexInfo extends HTTPStreamingIndexInfoBase
	{
		public function HTTPStreamingF4FIndexInfo
			(
			 serverBaseURL:String=null
			, streamInfos:Vector.<HTTPStreamingF4FStreamInfo>=null
			, dvrInfo:DVRInfo = null
			)
		{
			super();
			
			_serverBaseURL = serverBaseURL;
			_streamInfos = streamInfos;
			_dvrInfo = dvrInfo;
		}

		public function get serverBaseURL():String
		{
			return _serverBaseURL;
		}

		public function get streamInfos():Vector.<HTTPStreamingF4FStreamInfo>
		{
			return _streamInfos;
		}
		
		public function get dvrInfo():DVRInfo
		{
			return _dvrInfo;
		}
		
		private var _serverBaseURL:String;
		private var _dvrInfo:DVRInfo;
		private var _streamInfos:Vector.<HTTPStreamingF4FStreamInfo>;
	}
}