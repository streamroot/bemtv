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
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The NetConnectionCodes class provides static constants for event types
	 * that a NetConnection dispatches as NetStatusEvents.
	 * @see flash.net.NetConnection
	 * @see flash.events.NetStatusEvent    
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */ 
	public final class NetConnectionCodes
	{
		/** 
		 * "status"	The connection was closed successfully.	
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const CONNECT_CLOSED:String = "NetConnection.Connect.Closed"; 	
		
		/**			
		 * "error"	The connection attempt failed.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public static const CONNECT_FAILED:String = "NetConnection.Connect.Failed"		
		
		/**
		 * "status"	The connection attempt succeeded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public static const CONNECT_SUCCESS:String = "NetConnection.Connect.Success";		
		
		/**
		 * "error"	The connection attempt did not have permission to access the application.			
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const CONNECT_REJECTED:String = "NetConnection.Connect.Rejected";		
				
		/** 
		 * "error"	The application name specified during connect is invalid.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const CONNECT_INVALIDAPP:String = "NetConnection.Connect.InvalidApp";	

		/** 
		 * "error"	The connection has been idle for too long.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const CONNECT_IDLE_TIME_OUT:String = "NetConnection.Connect.IdleTimeOut";	
}
}