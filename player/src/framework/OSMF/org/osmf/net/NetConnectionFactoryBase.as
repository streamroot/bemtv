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
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
	
	import org.osmf.events.NetConnectionFactoryEvent;
	import org.osmf.media.URLResource;
	import org.osmf.utils.OSMFStrings;

	/**
	 * Dispatched when the factory has successfully created and connected a NetConnection.
	 *
	 * @eventType org.osmf.events.NetConnectionFactoryEvent.CREATION_COMPLETE
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="creationComplete", type="org.osmf.events.NetConnectionFactoryEvent")]
	
	/**
	 * Dispatched when the factory has failed to create and connect a NetConnection.
	 *
	 * @eventType org.osmf.events.NetConnectionFactoryEvent.CREATION_ERROR
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="creationError", type="org.osmf.events.NetConnectionFactoryEvent")]
	
	/**
	 * The NetConnectionFactoryBase is a base class for objects that need to
	 * create and connect a NetConnection.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class NetConnectionFactoryBase extends EventDispatcher
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function NetConnectionFactoryBase()
		{
			super();
		}

		/**
		 * Begins the process of creating a new NetConnection and establishing the connection.
		 * Because the connection process may be asynchronous, this method does not return a
		 * result.  Instead, once the NetConnection is created and the connection either
		 * succeeds or fails, a NetConnectionFactoryEvent will be dispatched.
		 * 
		 * <p>Subclasses must override this method.</p>
		 * 
		 * @param resource The URLResource that requires the NetConnection.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function create(resource:URLResource):void
		{
			throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.FUNCTION_MUST_BE_OVERRIDDEN));
		}
		
		/**
		 * Closes the given NetConnection.  The client of a NetConnectionFactoryBase
		 * should use this method to close NetConnections (as opposed to NetConnection.close)
		 * because some NetConnectionFactoryBase subclasses might want fine-grained control
		 * over the lifetime of the NetConnections they create.
		 * 
		 * @param resource The NetConnection to close.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function closeNetConnection(netConnection:NetConnection):void
		{
			netConnection.close();
		}
	}
}