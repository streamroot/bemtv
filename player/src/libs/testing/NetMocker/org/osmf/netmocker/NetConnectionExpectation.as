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
package org.osmf.netmocker
{
	/**
	 * Enumeration of expected behavior when using a NetConnection.
	 **/
	public class NetConnectionExpectation
	{
		/** Expect the connection to succeed. */
		public static const VALID_CONNECTION:NetConnectionExpectation = new NetConnectionExpectation("validConnection");

		/** Expect the connection to have parameters. */
		public static const CONNECT_WITH_PARAMS:NetConnectionExpectation = new NetConnectionExpectation("connectWithParams");
		
		/** Expect the connection to fail due to an invalid server name */
		public static const INVALID_FMS_SERVER:NetConnectionExpectation = new NetConnectionExpectation("invalidFMSServer");

		/** Expect the connection to fail due to the request being rejected on a valid server. */
		public static const REJECTED_CONNECTION:NetConnectionExpectation = new NetConnectionExpectation("rejectedConnection");
		
		/** Expect the connection to fail due to an invalid application on a valid server. */
		public static const INVALID_FMS_APPLICATION:NetConnectionExpectation = new NetConnectionExpectation("invalidFMSApplication");
		
		/** Expect the connection to throw an IO Error*/
		public static const IO_ERROR:NetConnectionExpectation = new NetConnectionExpectation("IOerror");
		
		/** Expect the connection to throw an IO Error*/
		public static const ARGUMENT_ERROR:NetConnectionExpectation = new NetConnectionExpectation("argumentError");
		
		/** Expect the connection to throw an IO Error*/
		public static const SECURITY_ERROR:NetConnectionExpectation = new NetConnectionExpectation("securityError");
		
		/** Expect the connect with FMTA parameters*/
		public static const CONNECT_WITH_FMTA:NetConnectionExpectation = new NetConnectionExpectation("connectWithFMTA");

		/** Expect the connection to undergo an RTMP redirect (302)*/
		public static const CONNECT_WITH_REDIRECT:NetConnectionExpectation = new NetConnectionExpectation("connectWithRedirect");

		/**
		 * @private
		 **/
		public function NetConnectionExpectation(name:String)
		{
			this.name = name;
		}
		
		public function toString():String
		{
			return name;
		}
		private var name:String;
	}
}