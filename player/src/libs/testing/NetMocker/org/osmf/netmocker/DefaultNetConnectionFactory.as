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
	import flash.net.NetConnection;
	
	import org.osmf.net.NetConnectionFactory;
	
	public class DefaultNetConnectionFactory extends NetConnectionFactory
	{
		public function DefaultNetConnectionFactory(allowNetConnectionSharing:Boolean=true)
		{
			_netConnectionExpectation = NetConnectionExpectation.VALID_CONNECTION;
			
			super(allowNetConnectionSharing);
		}
		
		/**
		 * The client's expectation for how this object's NetConnection will
		 * behave after connect() is called.
		 **/ 
		public function set netConnectionExpectation(value:NetConnectionExpectation):void
		{
			this._netConnectionExpectation = value;
		}
		
		public function get netConnectionExpectation():NetConnectionExpectation
		{
			return _netConnectionExpectation;
		}

		/**
		 * The client's expectation for the version of the FMS server from which
		 * the NetConnection originates.  Format should be "3,5,3" (i.e. comma
		 * separated).
		 **/ 
		public function set netConnectionExpectedFMSVersion(value:String):void
		{
			this._netConnectionExpectedFMSVersion = value;
		}
		
		public function get netConnectionExpectedFMSVersion():String
		{
			return _netConnectionExpectedFMSVersion;
		}

	    /**
	     * @inheritDoc
	     **/
	    override protected function createNetConnection():NetConnection
	    {
			var mockNetConnection:MockNetConnection = new MockNetConnection();
			if (netConnectionExpectation != null)
			{
				mockNetConnection.expectation = this.netConnectionExpectation;
			}
			if (netConnectionExpectedFMSVersion != null)
			{
				mockNetConnection.expectedFMSVersion = this.netConnectionExpectedFMSVersion;
			}
			return mockNetConnection;
	    }
	    
	    private var _netConnectionExpectation:NetConnectionExpectation;
		private var _netConnectionExpectedFMSVersion:String;
	}
}