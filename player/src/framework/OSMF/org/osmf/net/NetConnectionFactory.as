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
	CONFIG::LOGGING 
	{	
		import org.osmf.logging.Logger;
	}
	
	import __AS3__.vec.Vector;
	
	import flash.net.NetConnection;
	import flash.utils.Dictionary;
	
	import org.osmf.events.NetConnectionFactoryEvent;
	import org.osmf.media.URLResource;
	import org.osmf.utils.URL;
	
	/**
	 * The NetConnectionFactory class is used to generate connected NetConnection
	 * instances and to manage sharing of these instances.  The NetConnectionFactory
	 * can also handle port/protocol negotiation.
	 * 
	 * <p>NetConnectionFactory is stateless. Multiple parallel create() requests
	 * may be made. A hash of the resource URL is used as a key to determine
	 * which NetConnections may be shared.</p>
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class NetConnectionFactory extends NetConnectionFactoryBase
	{
		/**
		 * Constructor.
		 * 
		 * @param shareNetConnections Boolean specifying whether created NetConnections
		 * may be shared or not.  The default is true.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function NetConnectionFactory(shareNetConnections:Boolean=true)
		{
			super();
			
			this.shareNetConnections = shareNetConnections;
		}
		
		/**
		 * @private
		 **/
		public function get timeout():Number
		{
			return _timeout;
		}
		
		public function set timeout(value:Number):void
		{
			_timeout = value;
		}
		
		/**
		 * @private
		 * 
		 * Interval in milliseconds between consecutive NetConnection attempts.
		 * The default is 200 ms.
		 * 
		 * This method is currently undocumented, use at your own risk.
		 **/
		public function get connectionAttemptInterval():Number
		{
			return _connectionAttemptInterval;
		}

		public function set connectionAttemptInterval(value:Number):void
		{
			_connectionAttemptInterval = value;
		}

		/**
		 * @private
		 * 
		 * Begins the process of creating a new NetConnection.  The method creates two dictionaries to help it 
		 * manage previously shared connections as well as pending connections. Only if a NetConnection is not shareable
		 * and not pending is a new connection sequence initiated via a new NetNegotiator instance.
		 * <p/>
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override public function create(resource:URLResource):void
		{
			var key:String = createNetConnectionKey(resource);
			
			// The first time this method is called, we create our dictionaries.
			if (connectionDictionary == null)
			{
				connectionDictionary = new Dictionary();
				keyDictionary = new Dictionary();
				pendingDictionary = new Dictionary();
			}
			var sharedConnection:SharedConnection = connectionDictionary[key] as SharedConnection;
			var connectionsUnderway:Vector.<URLResource> = pendingDictionary[key] as Vector.<URLResource>;
			
			// Check to see if we already have this connection ready to be shared.
			if (sharedConnection != null && shareNetConnections)
			{
				CONFIG::LOGGING
				{
					logger.info("Reusing shared NetConnection: " + sharedConnection.netConnection.uri);
				}

				sharedConnection.count++;
				dispatchEvent
					( new NetConnectionFactoryEvent
						( NetConnectionFactoryEvent.CREATION_COMPLETE
						, false
						, false
						, sharedConnection.netConnection
						, resource
						)
					);
			} 
			// Check to see if there is already a connection attempt pending on this resource.
			else if (connectionsUnderway != null)
			{
				// Add this resource to the vector of resources to be notified once the
				// connection has either succeeded or failed.
				connectionsUnderway.push(resource);
			}
			// If no connection is shareable or pending, then initiate a new connection attempt.
			else
			{
				// Add this connection to the list of pending connections
				var pendingConnections:Vector.<URLResource> = new Vector.<URLResource>();
				pendingConnections.push(resource);
				pendingDictionary[key] = pendingConnections;
				
				// Set up our URLs and NetConnections
				var urlIncludesFMSApplicationInstance:Boolean = resource is StreamingURLResource ? StreamingURLResource(resource).urlIncludesFMSApplicationInstance : false 
				var netConnectionURLs:Vector.<String> = createNetConnectionURLs(resource.url, urlIncludesFMSApplicationInstance);
				var netConnections:Vector.<NetConnection> = new Vector.<NetConnection>();
				for (var j:int = 0; j < netConnectionURLs.length; j++)
				{
					netConnections.push(createNetConnection());
				} 
				
				// Perform the connection attempt
				var negotiator:NetNegotiator = new NetNegotiator(_connectionAttemptInterval, _timeout);
				negotiator.addEventListener(NetConnectionFactoryEvent.CREATION_COMPLETE, onConnected);
				negotiator.addEventListener(NetConnectionFactoryEvent.CREATION_ERROR, onConnectionFailed);
				negotiator.createNetConnection(resource, netConnectionURLs, netConnections);
				
				function onConnected(event:NetConnectionFactoryEvent):void
				{
					CONFIG::LOGGING 
					{	
						logger.info("NetConnection established with: " + event.netConnection.uri);
					}

					negotiator.removeEventListener(NetConnectionFactoryEvent.CREATION_COMPLETE, onConnected);
					negotiator.removeEventListener(NetConnectionFactoryEvent.CREATION_ERROR, onConnectionFailed);
					
					var pendingEvents:Vector.<NetConnectionFactoryEvent> = new Vector.<NetConnectionFactoryEvent>();
					
					// Dispatch an event for each pending LoadTrait.
					var pendingConnections:Vector.<URLResource> = pendingDictionary[key];
					for (var i:Number = 0; i < pendingConnections.length; i++)
					{
						var pendingResource:URLResource = pendingConnections[i] as URLResource;
						if (shareNetConnections)
						{
							var alreadyShared:SharedConnection = connectionDictionary[key] as SharedConnection;
							if (alreadyShared != null)
							{
								alreadyShared.count++;
							}
							else
							{
								var obj:SharedConnection = new SharedConnection();
								obj.count = 1;
								obj.netConnection = event.netConnection;
								connectionDictionary[key] = obj;
								keyDictionary[obj.netConnection] = key;
							}
						} 
						
						// We don't dispatch immediately, but add it to a queue.  It's important
						// that we delete the key first, since this event could trigger a subsequent
						// request.
						pendingEvents.push
							( new NetConnectionFactoryEvent
								( NetConnectionFactoryEvent.CREATION_COMPLETE
								, false
								, false
								, event.netConnection
								, pendingResource
								)
							);
					}
					
					delete pendingDictionary[key];
					
					// Now we're safe, dispatch the events.
					for each (var pendingEvent:NetConnectionFactoryEvent in pendingEvents)
					{
						dispatchEvent(pendingEvent);
					}
				}
				
				function onConnectionFailed(event:NetConnectionFactoryEvent):void
				{
					CONFIG::LOGGING 
					{
						var fmsURL:FMSURL = new FMSURL(resource.url);
						logger.info("NetConnection failed for: " + fmsURL.protocol + "://" + fmsURL.host + (fmsURL.port.length > 0 ? ":" + fmsURL.port : "" ) + "/" + fmsURL.appName + (fmsURL.useInstance ? "/" + fmsURL.instanceName:""));
					}

					negotiator.removeEventListener(NetConnectionFactoryEvent.CREATION_COMPLETE, onConnected);
					negotiator.removeEventListener(NetConnectionFactoryEvent.CREATION_ERROR, onConnectionFailed);
		
					// Dispatch an event for each pending resource.
					var pendingConnections:Vector.<URLResource> = pendingDictionary[key];
					for each (var pendingResource:URLResource in pendingConnections)
					{
						dispatchEvent
							( new NetConnectionFactoryEvent
								( NetConnectionFactoryEvent.CREATION_ERROR
								, false
								, false
								, null
								, pendingResource
								, event.mediaError
								)
							);
					}
					delete pendingDictionary[key];
				}
			}
		}
		
		/**
		 * @private
		 * 
		 * Manages the closing of a shared NetConnection. NetConnections
		 * are only physically closed after the last sharer has requested a close().
		 * 
		 * @param netConnection The NetConnection to close.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override public function closeNetConnection(netConnection:NetConnection):void
		{
			if (shareNetConnections)
			{
				var key:String = keyDictionary[netConnection] as String;
				if (key != null)
				{
					var obj:SharedConnection = connectionDictionary[key] as SharedConnection;
					obj.count--;
					if (obj.count == 0)
					{
						netConnection.close();
						
						delete connectionDictionary[key];
						delete keyDictionary[netConnection];
					}
				}
			}
			else
			{
				super.closeNetConnection(netConnection);
			}
		}
				
		// Protected
		//
		
		/**
		 * Generates a key to uniquely identify each connection.  This key is used
		 * to determine whether a particularly URLResource can share an existing
		 * NetConnection.  If the keys for two URLResources are identical, then
		 * they can share the same NetConnection.
		 * 
		 * By default, this method returns a String consisting of the protocol,
		 * host, port, and FMS application name. 
		 * 
		 * @param resource a URLResource
		 * @return a String hash that uniquely identifies the NetConnection
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function createNetConnectionKey(resource:URLResource):String
		{
			var fmsURL:FMSURL = new FMSURL(resource.url);
			return fmsURL.protocol + fmsURL.host + fmsURL.port + fmsURL.appName + fmsURL.instanceName;
		}
		
		/**
		 *  The factory function for creating a NetConnection.
		 *
		 *  @return An unconnected NetConnection.
	     * 	@see flash.net.NetConnection
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function createNetConnection():NetConnection
		{
			return new NetConnection();
		}

		/**
		 * Assembles a vector of URLs that should be used during the connection
		 * attempt.  The default protocols attempted when a "rtmp" connection is
		 * specified are "rtmp", "rtmps", and "rtmpt". When a "rtmpe" connection
		 * is requested, both "rtmpe" and "rtmpte" protocols are attempted. When
		 * "rtmps","rtmpt" or "rtmpte" are requested, only those protocols are
		 * attempted.  The default ports are 1935, 443 and 80. If a specific port
		 * is specified in the URL, then only that port is used.
		 * 
		 * Subclasses can override this method to change this default behavior.
		 * 
		 * @param url The URL to be loaded.
		 * @param urlIncludesFMSApplicationInstance Indicates whether the URL includes
		 * the FMS application instance name.  See StreamingURLResource for more info.
		 **/
		protected function createNetConnectionURLs(url:String, urlIncludesFMSApplicationInstance:Boolean=false):Vector.<String>
		{
			var urls:Vector.<String> = new Vector.<String>();
			
			var portProtocols:Vector.<PortProtocol> = buildPortProtocolSequence(url);
			for each (var portProtocol:PortProtocol in portProtocols)
			{
				urls.push(buildConnectionAddress(url, urlIncludesFMSApplicationInstance, portProtocol));
			}
			
			return urls;
		}
		
		// Internals
		//
				
		/** 
		 * Assembles a vector of PortProtocol Objects to be used during the connection attempt.
		 * 
		 * @param url the URL to be loaded
		 * @returns a Vector of PortProtocol objects. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function buildPortProtocolSequence(url:String):Vector.<PortProtocol>
		{
			var portProtocols:Vector.<PortProtocol> = new Vector.<PortProtocol>;
			
			var theURL:URL = new URL(url);
			
			var allowedPorts:String = (theURL.port == "") ? DEFAULT_PORTS: theURL.port;
			var allowedProtocols:String = "";
			switch (theURL.protocol)
			{
				case PROTOCOL_RTMP:
					allowedProtocols = DEFAULT_PROTOCOLS_FOR_RTMP;
					break;
				case PROTOCOL_RTMPE:
					allowedProtocols = DEFAULT_PROTOCOLS_FOR_RTMPE;
					break;
				case PROTOCOL_RTMPS:
				case PROTOCOL_RTMPT:
				case PROTOCOL_RTMPTE:
					allowedProtocols = theURL.protocol;
					break;
			}
			var portArray:Array = allowedPorts.split(",");
			var protocolArray:Array = allowedProtocols.split(",");
			for (var i:int = 0; i < protocolArray.length; i++)
			{
				for (var j:int = 0; j < portArray.length; j++)
				{
					var attempt:PortProtocol = new PortProtocol();
					attempt.protocol = protocolArray[i];
					attempt.port = portArray[j];
					portProtocols.push(attempt);
				}
			} 
			return portProtocols;
		}
		
		/**
		 * Assembles a connection address. 
		 * 
		 * @param url The URL to be loaded.
		 * @param urlIncludesFMSApplicationInstance Indicates whether the URL includes
		 * the FMS application instance name.  See StreamingURLResource for more info.
		 * @param portProtocol The port and protocol being used for the connection.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function buildConnectionAddress(url:String, urlIncludesFMSApplicationInstance:Boolean, portProtocol:PortProtocol):String
		{
			var fmsURL:FMSURL = new FMSURL(url, urlIncludesFMSApplicationInstance);
			var addr:String = portProtocol.protocol + "://" + fmsURL.host + ":" + portProtocol.port + "/" + fmsURL.appName + (fmsURL.useInstance ? "/" + fmsURL.instanceName:"");
			
			// Pass along any query string params
			if (fmsURL.query != null && fmsURL.query != "")
			{
				addr += "?" + fmsURL.query;
			}
			
			return addr;
		}
						
		private var shareNetConnections:Boolean;
		private var negotiator:NetNegotiator;
		private var connectionDictionary:Dictionary;
		private var keyDictionary:Dictionary;
		private var pendingDictionary:Dictionary;
		private var _connectionAttemptInterval:Number = DEFAULT_CONNECTION_ATTEMPT_INTERVAL;
		private var _timeout:Number = DEFAULT_TIMEOUT;
		
		private static const DEFAULT_TIMEOUT:Number = 10000;
		private static const DEFAULT_PORTS:String = "1935,443,80";
		private static const DEFAULT_PROTOCOLS_FOR_RTMP:String = "rtmp,rtmpt,rtmps"
		private static const DEFAULT_PROTOCOLS_FOR_RTMPE:String = "rtmpe,rtmpte";
		private static const DEFAULT_CONNECTION_ATTEMPT_INTERVAL:Number = 200;

		private static const PROTOCOL_RTMP:String = "rtmp";
		private static const PROTOCOL_RTMPS:String = "rtmps";
		private static const PROTOCOL_RTMPT:String = "rtmpt";
		private static const PROTOCOL_RTMPE:String = "rtmpe";
		private static const PROTOCOL_RTMPTE:String = "rtmpte";
		private static const PROTOCOL_HTTP:String = "http";
		private static const PROTOCOL_HTTPS:String = "https";
		private static const PROTOCOL_FILE:String = "file";
		private static const PROTOCOL_EMPTY:String = "";
		private static const MP3_EXTENSION:String = ".mp3";

		CONFIG::LOGGING
		private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.net.NetConnectionFactory");
	}
}

import flash.net.NetConnection;

/**
 * Utility class for structuring shared connection data.
 *
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion OSMF 1.0
 */
class SharedConnection
{
	public var count:Number;
	public var netConnection:NetConnection;
}

