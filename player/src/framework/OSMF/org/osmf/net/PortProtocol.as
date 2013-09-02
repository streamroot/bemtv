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
*  Contributor(s): Akamai Technologies
*  
*****************************************************/
package org.osmf.net
{
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * PortProtocol encapsulates a port-protocol pair.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class PortProtocol
	{
		/**
		 * The port.
		 **/
		public function get port():int
		{
			return _port;
		}
		
		public function set port(value:int):void
		{
			_port = value;
		}

		/**
		 * The protocol.
		 **/
		public function get protocol():String
		{
			return _protocol;
		}
		
		public function set protocol(value:String):void
		{
			_protocol = value;
		}
				
		private var _port:int;
		private var _protocol:String;
	}
}