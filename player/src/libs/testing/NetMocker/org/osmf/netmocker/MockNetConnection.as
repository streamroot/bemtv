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
	import flash.errors.IOError;
	import flash.errors.IllegalOperationError;
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	import org.osmf.media.URLResource;
	import org.osmf.net.NetConnectionCodes;
	
	/**
	 * NetConnection which can be used for mocking the connection to FMS (or
	 * to a progressive piece of content).  Intercepts all calls to the base
	 * NetConnection (thus preventing any network activity), and dispatches
	 * the appropriate events based on a predefined expectation.
	 * 
	 * Clients should set the <code>expectation</code> property before
	 * interacting with the NetConnection, and then listen for the events that
	 * they would expect to get when interacting with a real NetConnection.
	 **/
	public class MockNetConnection extends NetConnection
	{
		/**
		 * Constructor.
		 **/
		public function MockNetConnection()
		{
			_expectation = NetConnectionExpectation.VALID_CONNECTION;
		
			// Intercept all NetStatusEvents dispatched from the base class.
			eventInterceptor = new NetStatusEventInterceptor(this);
		}
				
		/**
		 * The client's expectation for how this NetConnection will
		 * behave after connect() is called.
		 **/ 
		public function set expectation(value:NetConnectionExpectation):void
		{
			this._expectation = value;
		}
		
		public function get expectation():NetConnectionExpectation
		{
			return _expectation;
		}

		/**
		 * The client's expectation for the version of the FMS server from which
		 * the NetConnection originates.  Format should be "3,5,3" (i.e. comma
		 * separated).
		 **/ 
		public function set expectedFMSVersion(value:String):void
		{
			this._expectedFMSVersion = value;
		}
		
		public function get expectedFMSVersion():String
		{
			return _expectedFMSVersion;
		}

		// Overrides
		//
		
		override public function addHeader(operation:String, mustUnderstand:Boolean=false, param:Object=null):void
		{
			// Swallow.
			trace("MockNetConnection.addHeader");
		}
		
		override public function call(command:String, responder:Responder, ...parameters):void
		{
			// Swallow.
			//trace("MockNetConnection.call(" + command + ")");
		}
		
		override public function close():void
		{
			super.close();
			eventInterceptor.dispatchNetStatusEvent(NetConnectionCodes.CONNECT_CLOSED, LEVEL_STATUS);
		}
		
		override public function connect(command:String, ...parameters):void
		{
			switch (_expectation)
			{
				case NetConnectionExpectation.VALID_CONNECTION:
					connectToValidServer(command);
					break;
				case NetConnectionExpectation.CONNECT_WITH_PARAMS:
					if (parameters.length > 0)
					{
						connectToValidServer(command);
					}
					else
					{
						throwIOError();
					}
					break;
				case NetConnectionExpectation.CONNECT_WITH_FMTA:
					if ((parameters.length > 0) &&
						hasFMTA(parameters) )
					{
						connectToValidServer(command, parameters);
					}
					else
					{
						throwIOError();
					}					
					break;
				case NetConnectionExpectation.INVALID_FMS_SERVER:
					connectToInvalidServer();
					break;
				case NetConnectionExpectation.REJECTED_CONNECTION:
					connectToRejectingServer();
					break;
				case NetConnectionExpectation.INVALID_FMS_APPLICATION:
					connectToInvalidApplication();
					break;
				case NetConnectionExpectation.IO_ERROR:
					throwIOError();
					break;
				case NetConnectionExpectation.ARGUMENT_ERROR:
					throwArgumentError();
					break;
				case NetConnectionExpectation.SECURITY_ERROR:
					throwSecurityError();
					break;
				case NetConnectionExpectation.CONNECT_WITH_REDIRECT:
					performRedirect();
					break;
				default:
					throw new IllegalOperationError();
			}
		}

		// Internals
		//
		
		private function hasFMTA(parameters:Array):Boolean
		{
			var asAdobeSeen:Boolean = false;
			var teConnectSeen:Boolean = false;
			
			for each( var item:String in parameters)
			{
				if (asAdobe.test(item))
				{
					asAdobeSeen = true;
				}
				if (teConnect.test(item))
				{
					teConnectSeen = true;
				}				
			}
			return asAdobeSeen && teConnectSeen;
		}
		
		private function connectToValidServer(command:String, params:Array = null):void
		{
			if (command == null)
			{
				// Progressive
				// Connect to null, so that NetStreams can use this NetConnection.
				super.connect(null);
				eventInterceptor.dispatchNetStatusEvent(NetConnectionCodes.CONNECT_SUCCESS, LEVEL_STATUS, 0, null, null, false, expectedFMSVersion);
			}
			else
			{
				// Streaming
				// Pass a reference to this NetConnection, so that the connection can be established just prior
				// to dispatching the delayed event.
				eventInterceptor.dispatchNetStatusEvent(NetConnectionCodes.CONNECT_SUCCESS, LEVEL_STATUS, EVENT_DELAY, this, params, false, expectedFMSVersion);
			}
		}

		private function performRedirect():void
		{
			_expectation = NetConnectionExpectation.VALID_CONNECTION;
			
			eventInterceptor.dispatchNetStatusEvent(NetConnectionCodes.CONNECT_REJECTED, LEVEL_ERROR, EVENT_DELAY, null, null, true);
		}

		private function connectToInvalidServer():void
		{
			eventInterceptor.dispatchNetStatusEvent(NetConnectionCodes.CONNECT_FAILED, LEVEL_ERROR, EVENT_DELAY);
		}

		private function connectToRejectingServer():void
		{
			var infos:Array =
					[ {"code":NetConnectionCodes.CONNECT_REJECTED, 	"level":LEVEL_ERROR}
					, {"code":NetConnectionCodes.CONNECT_CLOSED, 	"level":LEVEL_STATUS}
					];
			eventInterceptor.dispatchNetStatusEvents(infos, EVENT_DELAY);
		}

		private function connectToInvalidApplication():void
		{
			var infos:Array =
					[ {"code":NetConnectionCodes.CONNECT_INVALIDAPP, 	"level":LEVEL_ERROR}
					, {"code":NetConnectionCodes.CONNECT_CLOSED, 		"level":LEVEL_STATUS}
					];
			eventInterceptor.dispatchNetStatusEvents(infos, EVENT_DELAY);
		}
		
		private function throwIOError():void
		{
			throw new IOError(IO_MESSAGE);
		}
		
		private function throwArgumentError():void
		{
			throw new ArgumentError(ARGUMENT_MESSAGE);
		}
		
		private function throwSecurityError():void
		{
			throw new SecurityError(SECURITY_MESSAGE);
		}
		
		private var _resource:URLResource;
		
		private static const asAdobe:RegExp = /as=adobe/;
		private static const teConnect:RegExp = /te=connect/;
		
		
		private static const EVENT_DELAY:int = 100;
		
		private static const LEVEL_STATUS:String = "status";
		private static const LEVEL_ERROR:String = "error";
		private static const IO_MESSAGE:String = "io_message";
		private static const ARGUMENT_MESSAGE:String = "argument_message";
		private static const SECURITY_MESSAGE:String = "security_message";
		
		
		private var eventInterceptor:NetStatusEventInterceptor;
		private var _expectation:NetConnectionExpectation;
		private var _expectedFMSVersion:String;
	}
}