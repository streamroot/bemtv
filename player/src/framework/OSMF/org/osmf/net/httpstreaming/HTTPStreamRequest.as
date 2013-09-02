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
package org.osmf.net.httpstreaming
{
	import flash.net.URLRequest;
	
	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class HTTPStreamRequest
	{
		/**
		 * Constructor.
		 * 
		 * quality of -1 means "same as was requested"
		 * truncateAt of -1 means "don't truncate" 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function HTTPStreamRequest(url:String = null, quality:int = -1, truncateAt:Number = -1, retryAfter:Number = -1, unpublishNotify:Boolean = false)
		{
			super();
			
			if (url)
			{
				_urlRequest = new URLRequest(HTTPStreamingUtils.normalizeURL(url));
			}
			else
			{
				_urlRequest = null;
			}
			
			_quality = quality;
			_truncateAt = truncateAt;
			_retryAfter = retryAfter;
			_unpublishNotify = unpublishNotify;
		}
		
		public function get urlRequest():URLRequest
		{
			return _urlRequest;
		}
		
		public function get retryAfter():Number
		{
			return _retryAfter;
		}
		
		public function get unpublishNotify():Boolean
		{
			return _unpublishNotify;
		}

		public function toString():String
		{
			return  "[url=" + (urlRequest != null ? urlRequest.url : "null") +
				    ", quality = " + _quality +
				    ", truncateAt = " + _truncateAt.toString() + 
					", retryAfter = " + _retryAfter.toString() + 
					", unpublishNotify = " + unpublishNotify +
					"]";
					
		}
		private var _urlRequest:URLRequest;
		private var _quality:int;
		private var _truncateAt:Number;
		private var _retryAfter:Number;
		private var _unpublishNotify:Boolean;
	}
}