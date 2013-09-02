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
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamPlayOptions;
	import flash.net.NetStreamPlayTransitions;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.NetConnectionFactoryEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.MediaType;
	import org.osmf.media.MediaTypeUtil;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.utils.URL;
	CONFIG::LOGGING
	{			
		import org.osmf.logging.Log;
	}
	

	/**
	 * The NetLoader class extends LoaderBase to provide
	 * loading support to the AudioElement and VideoElement classes.
	 * <p>Supports both streaming and progressive media resources.
	 * If the resource URL is RTMP, connects to an RTMP server by invoking a NetConnectionFactoryBase. 
	 * NetConnections may be shared between LoadTrait instances.
	 * If the resource URL is HTTP, performs a <code>connect(null)</code>
	 * for progressive downloads.</p>
	 * The NetLoader supports Flash Media Token Authentication,  
	 * for passing authentication tokens through the NetConnection.
	 *
	 * @includeExample NetLoaderExample.as -noswf
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class NetLoader extends LoaderBase
	{
		/**
		 * Constructor.
		 * 
		 * @param factory The NetConnectionFactoryBase instance to use for managing NetConnections.
		 * If factory is null, a NetConnectionFactory will be created and used. Since the
		 * NetConnectionFactory class facilitates connection sharing, this is an easy way of
		 * enabling global sharing, by creating a single NetConnectionFactory instance within
		 * the player and then handing it to all NetLoader instances.
		 * 
		 * @param reconnectStreams Indicates whether stream reconnect is enabled. Both Flash
		 * Player 10.1 and Flash Media Server 3.5.3 are required.
		 *   
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function NetLoader(factory:NetConnectionFactoryBase=null)
		{
			super();

			CONFIG::FLASH_10_1	
			{
				_reconnectTimeout = STREAM_RECONNECT_TIMEOUT;
			}
			
			netConnectionFactory = factory || new NetConnectionFactory();
			netConnectionFactory.addEventListener(NetConnectionFactoryEvent.CREATION_COMPLETE, onCreationComplete);
			netConnectionFactory.addEventListener(NetConnectionFactoryEvent.CREATION_ERROR, onCreationError);
		}

		CONFIG::FLASH_10_1	
		{
			/**
			 * The stream reconnect timeout in milliseconds.
			 * 
			 * <p>The NetLoader will give up trying to reconnect the stream
			 * if a successful reconnect does not occur within this time
			 * period. The default is 120 seconds. For unpaused streams, the
			 * timeout period begins when the buffer empties and therefore a
			 * value of zero seconds is valid, meaning after the buffer empties, 
			 * don't try to reconnect.  For paused streams, the timeout period
			 * begins immediately.</p>
			 * 
			 * @throws ArgumentError If value param is less than zero.
			 **/		
			public function get reconnectTimeout():Number
			{
				return _reconnectTimeout;
			}
			
			public function set reconnectTimeout(value:Number):void
			{
				if (value < 0)
				{
					throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
				}
				
				_reconnectTimeout = value;
			}	
						
			/**
			 * @private
			 *
			 * Allow derived classes to change the value of reconnectStreams.
			 * 
			**/ 
			protected function setReconnectStreams(value:Boolean):void
			{
				_reconnectStreams = value;
			}
			
			/**
			 * @private
			 * 
			 * Indicates whether stream reconnect is enabled.
			 **/
			public function get reconnectStreams():Boolean
			{
				return _reconnectStreams;
			}
		}				
		
		/**
		 * @private
		 * 
		 * The NetLoader returns true for URLResources which support the media and mime-types
		 * (or file extensions) for streaming audio and streaming or progressive video, or
		 * implement one of the following schemes: http, https, file, rtmp, rtmpt, rtmps,
		 * rtmpe or rtmpte.
		 * 
		 * @param resource The URL of the source media.
		 * @return Returns <code>true</code> for URLResources which it can load
		**/
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			var rt:int = MediaTypeUtil.checkMetadataMatchWithResource(resource, MEDIA_TYPES_SUPPORTED, MIME_TYPES_SUPPORTED);
			if (rt != MediaTypeUtil.METADATA_MATCH_UNKNOWN)
			{
				return rt == MediaTypeUtil.METADATA_MATCH_FOUND;
			}			

			/*
			 * The rules for URL checking are outlined below:
			 * 
			 * If the URL is null or empty, we assume being unable to handle the resource
			 * If the URL has no protocol, we check for file extensions
			 * If the URL has protocol, we have to make a distinction between progressive and stream
			 * 		If the protocol is progressive (file, http, https), we check for file extension
			 *		If the protocol is stream (the rtmp family), we assume that we can handle the resource
			 *
			 * We assume being unable to handle the resource for conditions not mentioned above
			 */
			var res:URLResource = resource as URLResource;
			var extensionPattern:RegExp = new RegExp("\.flv$|\.f4v$|\.mov$|\.mp4$|\.mp4v$|\.m4v$|\.3gp$|\.3gpp2$|\.3g2$", "i");
			var url:URL = res != null ? new URL(res.url) : null;
			if (url == null || url.rawUrl == null || url.rawUrl.length <= 0)
			{
				return false;
			}
			if (url.protocol == "")
			{
				return extensionPattern.test(url.path);
			}
			if (NetStreamUtils.isRTMPStream(url.rawUrl))
			{
				return true;
			}
			if (url.protocol.search(/file$|http$|https$/i) != -1)
			{
				return (url.path == null ||
						url.path.length <= 0 ||
						url.extension.length == 0 ||
						extensionPattern.test(url.path));
			}
			
			return false;
		}
		
		/**
		 *
		 * The factory function for creating a NetStream.
		 * 
		 * @param connection The NetConnection to associate with the new NetStream.
		 * @param resource The resource whose content will be played in the NetStream.
		 * 
		 * @return A new NetStream associated with the NetConnection.
		**/
		protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream
		{
			var ns:NetStream = new NetStream(connection);
			
			var streamingResource:StreamingURLResource = resource as StreamingURLResource;
			if (streamingResource != null && streamingResource.streamType == StreamType.LIVE && ns.bufferTime == 0)
			{
				// Live streams typically start with a buffer time of zero, which is
				// problematic in stream reconnection scenarios.  So we ensure that
				// the default is similar to non-live cases (0.1).  See FM-1037.
				//
				// Note that this may need to be removed once we provide framework
				// level support for custom buffering strategies.
				ns.bufferTime = 0.1;
			}
			
			return ns;
		}

		/**
		 * The factory function for creating a NetStreamSwitchManagerBase.
		 * 
		 * @param connection The NetConnection that's associated with the NetStreamSwitchManagerBase.
		 * @param netStream The NetStream upon which the NetStreamSwitchManagerBase will operate.
		 * @param dsResource The resource upon which the NetStreamSwitchManagerBase will operate.
		 * 
		 * @return The NetStreamSwitchManagerBase for the NetStream, null if multi-bitrate switching
		 * is not enabled for the NetStream.
		 **/
 		protected function createNetStreamSwitchManager(connection:NetConnection, netStream:NetStream, dsResource:DynamicStreamingResource):NetStreamSwitchManagerBase
		{
			return null;
		}
				
		/**
		 * @private
		 * 
		 * Subclass stub that can be used to do special processing just upfront
		 * the loader finishing loading. Also, the overriding method must 
		 * call the updateLoadTrait method at the end.
		 *  
		 * @param loadTrait
		 */		
		protected function processFinishLoading(loadTrait:NetStreamLoadTrait):void
		{	
			updateLoadTrait(loadTrait, LoadState.READY);
		}

		/**
		 * @private
		 * 
		 * Validates the LoadTrait to verify that this class can in fact load it. Examines the protocol
		 * associated with the LoadTrait's resource. If the protocol is HTTP, calls the <code>startLoadingHTTP()</code>
		 * method. If the protocol is RTMP-based, calls the  <code>startLoadingRTMP()</code> method. If the URL protocol is invalid,
		 * dispatches a mediaErroEvent against the LoadTrait and updates the LoadTrait's state to LoadState.LOAD_ERROR.
	     *
	     * @param loadTrait LoadTrait requesting this load operation.
	     * @see org.osmf.traits.LoadTrait
	     * @see org.osmf.traits.LoadState
	     * @see org.osmf.events.MediaErrorEvent
		**/
		override protected function executeLoad(loadTrait:LoadTrait):void
		{	
			updateLoadTrait(loadTrait, LoadState.LOADING);
			var url:URL = new URL((loadTrait.resource as URLResource).url);
			switch (url.protocol)
			{
				case PROTOCOL_RTMP:
				case PROTOCOL_RTMPS:
				case PROTOCOL_RTMPT:
				case PROTOCOL_RTMPE:
				case PROTOCOL_RTMPTE:
				case PROTOCOL_RTMFP:
					startLoadingRTMP(loadTrait);
					break;
				case PROTOCOL_HTTP:
				case PROTOCOL_HTTPS:
				case PROTOCOL_FILE:
				case PROTOCOL_EMPTY: 
					startLoadingHTTP(loadTrait);
					break;
				default:
					updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
					loadTrait.dispatchEvent
						( new MediaErrorEvent
							( MediaErrorEvent.MEDIA_ERROR
							, false
							, false
							, new MediaError(MediaErrorCodes.URL_SCHEME_INVALID)
							)
						);
					break;
			}
		}
		
		/**
		 * @private
		 * 
	     * Unloads the media after validating the unload operation against the LoadTrait.
	     * Closes the NetStream defined within the NetStreamLoadTrait object,
	     * as well as the NetConnection defined within the trait object.  Dispatches the
	     * loadStateChange event with every state change.
	     * 
	     * @throws IllegalOperationError if the parameter is <code>null</code>.
	     * @param loadTrait LoadTrait to be unloaded.
	     * @see org.osmf.loaders.LoaderBase#event:loadStateChange	
		**/
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			updateLoadTrait(loadTrait, LoadState.UNLOADING); 
			
			var netLoadTrait:NetStreamLoadTrait = loadTrait as NetStreamLoadTrait;			
			if (netLoadTrait != null)
			{
				if (netLoadTrait.netStream != null)
				{
					netLoadTrait.netStream.close();
				}
				
				if (netLoadTrait.netConnectionFactory != null)
				{
					netLoadTrait.netConnectionFactory.closeNetConnection(netLoadTrait.connection);
				}
				else if (netLoadTrait.connection != null)
				{
					netLoadTrait.connection.close();
				}
			}
			
			if (oldConnectionURLs != null)
			{
				delete oldConnectionURLs[loadTrait.resource];
			}
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED); 				
		}
		
		CONFIG::FLASH_10_1	
		{						
			/**
			 * Called when the stream reconnect logic needs to create a new
			 * NetConnection object. Override to create a custom NetConnection
			 * object.
			 * 
			 * @private
			 **/
			protected function createReconnectNetConnection():NetConnection
			{
				return new NetConnection();
			}

			/**
			 * Attempts to reconnect the specified NetConnection to the specified
			 * URL.
			 * 
			 * <p>Clients can override this method to provide custom <code>NetConnection</code>
			 * behavior when using the stream reconnect feature. For example, if you
			 * wanted to provide client-side load balancing in your player, you could create
			 * a custom <code>NetLoader</code> class and override this method to use an
			 * alternate URI.</p>
			 * 
			 * @param netConnection The new <code>NetConnection</code> created by the stream reconnect logic.
			 * @param resource The <code>URLResource</code> that was originally used to play the media.
			 **/
			protected function reconnect(netConnection:NetConnection, resource:URLResource):void
			{
				var connectionURL:String = oldConnectionURLs[resource] as String;
				
				if (connectionURL != null && connectionURL.length > 0 && netConnection != null)
				{
					netConnection.connect(connectionURL);
				}
			}
			
			/**
			 * Override this method to provide custom reconnect behavior.
			 * 
			 * @private
			 **/
			protected function reconnectStream(loadTrait:NetStreamLoadTrait):void
			{
				var nsPlayOptions:NetStreamPlayOptions = new NetStreamPlayOptions();
				 
				loadTrait.netStream.attach(loadTrait.connection);
				
				nsPlayOptions.transition = NetStreamPlayTransitions.RESUME;
				
				var resource:URLResource = loadTrait.resource as URLResource;
				var urlIncludesFMSApplicationInstance:Boolean = 
						(resource as StreamingURLResource) != null ? (resource as StreamingURLResource).urlIncludesFMSApplicationInstance : false;
				var streamName:String = NetStreamUtils.getStreamNameFromURL(resource.url, urlIncludesFMSApplicationInstance);
				
				nsPlayOptions.streamName = streamName;
				loadTrait.netStream.play2(nsPlayOptions);
			}
		}
						
		/**
		 *  Establishes a new NetStream on the connected NetConnection and signals that loading is complete.
		 *
		 *  @private
		**/
		private function finishLoading(connection:NetConnection, loadTrait:LoadTrait, factory:NetConnectionFactoryBase = null):void
		{
			var netLoadTrait:NetStreamLoadTrait = loadTrait as NetStreamLoadTrait;
			if (netLoadTrait != null)
			{
				netLoadTrait.connection = connection;
				var netStream:NetStream = createNetStream(connection, netLoadTrait.resource as URLResource);				
				netStream.client = new NetClient();
				netLoadTrait.netStream = netStream;
				netLoadTrait.switchManager = createNetStreamSwitchManager(connection, netStream, netLoadTrait.resource as DynamicStreamingResource);
				netLoadTrait.netConnectionFactory = factory;
				
				CONFIG::FLASH_10_1	
				{				
					// Set up stream reconnect logic
					if (	_reconnectStreams
						&&	netLoadTrait.resource is URLResource
						&&  supportsStreamReconnect(netLoadTrait.resource as URLResource))
					{
						setupStreamReconnect(netLoadTrait);
					}				
				}
				
				processFinishLoading(loadTrait as NetStreamLoadTrait);
			}
		}
		
		private function supportsStreamReconnect(resource:URLResource):Boolean
		{
			var result:Boolean = true;

			// It must be an RTMP stream...
			if (NetStreamUtils.isRTMPStream(resource.url))
			{
				var fmsVersion:String = resource.getMetadataValue(MetadataNamespaces.FMS_SERVER_VERSION_METADATA) as String;
				if (fmsVersion != null && fmsVersion.length > 0)
				{
					// And if a version is available, it must be at least 3.5.3.
					var versionParts:Array = fmsVersion.split(",");
					if (versionParts.length >= 3)
					{
						var majorVersion:int = versionParts[0];
						var minorVersion:int = versionParts[1];
						var subMinorVersion:int = versionParts[2];
						
						if (	majorVersion < 3
							||	(majorVersion == 3 && minorVersion < 5)
							||	(majorVersion == 3 && minorVersion == 5 && subMinorVersion < 3)
						)
						{
							result = false;
							
							CONFIG::LOGGING
							{
								logger.info(STREAM_RECONNECT_LOGGING_PREFIX+"Stream Reconnect not supported by this version of FMS");
							}
						}
					}
				}
			}
			else
			{
				result = false;
			}

			return result;
		}

		CONFIG::FLASH_10_1	
		{
			/**
			 * Sets up the stream reconnect logic. In the event of a dropped connection or a client
			 * switching from a wired to a wireless network connection for example, this method
			 * will use the <code>NetStream.attach()</code> method to attach the same 
			 * <code>NetStream</code> object to a reconnected <code>NetConnection</code> object.
			 * <p/>
			 * This feature requires Flash Player 10.1 and Flash Media Server 3.5.3. If the Flash 
			 * Player version is less than 10.1 or the Flash Media Server version is less than 
			 * 3.5.3, the stream closes when the connection drops.
			 * <p/>
			 * When a <code>NetConnection</code> closes due to a network change, the stream keeps 
			 * playing using the existing buffer. Meanwhile, this method attempts to 
			 * reconnect to the server and resumes playing the stream.
			 **/
			private function setupStreamReconnect(loadTrait:NetStreamLoadTrait):void
			{
				var netConnection:NetConnection = loadTrait.connection;
				var reconnectTimer:Timer = new Timer(STREAM_RECONNECT_TIMER_INTERVAL, 1);
				var timeoutTimer:Timer;
				oldConnectionURLs[loadTrait.resource] = netConnection.uri;
				var streamIsPaused:Boolean = false;
				var bufferIsEmpty:Boolean = false;
				var reconnectHasTimedOut:Boolean = false;
				var fmsIdleTimeoutReached:Boolean = false;
				
				setupNetConnectionListeners();
				setupNetStreamListeners();
				setupReconnectTimer();
				setupTimeoutTimer();
				
				function setupReconnectTimer(add:Boolean=true):void
				{
					if (add)
					{
						reconnectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onReconnectTimer);
					}
					else
					{
						reconnectTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onReconnectTimer);
						reconnectTimer = null;
					}
				}
				
				function setupTimeoutTimer(add:Boolean=true):void
				{
					if (add)
					{
						if (_reconnectTimeout > 0 )
						{
							timeoutTimer = new Timer(_reconnectTimeout, 1);
							timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeoutTimer);
						}
					}
					else
					{
						if (timeoutTimer != null)
						{
							timeoutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimeoutTimer);
							timeoutTimer = null;
						}
					}
				}
				
				function setupNetConnectionListeners(add:Boolean=true):void
				{
					if (add)
					{
						netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);				
					}
					else
					{
						netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);				
					}
				}
				
				function setupNetStreamListeners(add:Boolean=true):void
				{
					if (loadTrait.netStream != null)
					{
						if (add)
						{
							loadTrait.netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
						}
						else
						{
							loadTrait.netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
						}
					}
				}
				
				function onNetStatus(event:NetStatusEvent):void
				{
					CONFIG::LOGGING
					{			
						logger.info(STREAM_RECONNECT_LOGGING_PREFIX+"onNetStatus: " +event.info.code);
					}
					
					switch(event.info.code)
					{
						case NetConnectionCodes.CONNECT_SUCCESS:
							CONFIG::LOGGING
							{
								if (event.info.data && event.info.data.version)
								{
									logger.info(STREAM_RECONNECT_LOGGING_PREFIX+"FMS version "+event.info.data.version);
								}
							}
							var oldConnection:NetConnection = loadTrait.connection;
							loadTrait.connection = netConnection;
							oldConnectionURLs[loadTrait.resource] = netConnection.uri;
							
							// Stop the timeout timer
							if (timeoutTimer != null)
							{
								timeoutTimer.stop();
							}
							
							reconnectStream(loadTrait);
							
							// Close the old connection
							CONFIG::LOGGING
							{			
								logger.debug(STREAM_RECONNECT_LOGGING_PREFIX+"closing the old (bad) NetConnection");
							}							
							if (loadTrait.netConnectionFactory != null)
							{
								loadTrait.netConnectionFactory.closeNetConnection(oldConnection);
							}
							else
							{
								oldConnection.close();
							}
							break;
						case NetConnectionCodes.CONNECT_IDLE_TIME_OUT:
							fmsIdleTimeoutReached = true;
							break;
						case NetConnectionCodes.CONNECT_CLOSED:
						case NetConnectionCodes.CONNECT_FAILED:
							CONFIG::LOGGING
							{	
								if (loadTrait.netStream != null)
								{
									logger.debug(STREAM_RECONNECT_LOGGING_PREFIX+"connection failed, bufferLength is "+loadTrait.netStream.bufferLength);
								}
								else
								{
									logger.debug(STREAM_RECONNECT_LOGGING_PREFIX+"connection failed, bufferLength is zero");
								}
							}
							if (loadTrait.loadState == LoadState.READY && !reconnectHasTimedOut && !fmsIdleTimeoutReached) 
							{
								reconnectTimer.start();
								
								// If our buffer is empty when the connection closes, then
								// we must start the timeout Timer now, since we won't get
								// a Buffer.Empty event later (FM-1076).  Note that we check
								// for this in two ways, since bufferLength might not be
								// zero when we get the Buffer.Empty event.
								if (bufferIsEmpty || loadTrait.netStream.bufferLength == 0 || streamIsPaused)
								{
									if (timeoutTimer != null)
									{
										timeoutTimer.start();
									}
									else
									{
										reconnectHasTimedOut = true;
										
										// Clean up
										setupReconnectTimer(false);
										setupNetConnectionListeners(false);
										setupNetStreamListeners(false);
										setupTimeoutTimer(false);
									}
								}
							}
							else
							{
								// Clean up
								setupReconnectTimer(false);
								setupNetConnectionListeners(false);
								setupNetStreamListeners(false);
								setupTimeoutTimer(false);
							}
							break;
						case NetStreamCodes.NETSTREAM_PAUSE_NOTIFY:
							streamIsPaused = true;
							break;
						case NetStreamCodes.NETSTREAM_UNPAUSE_NOTIFY:
							streamIsPaused = false;
							break;
						case NetStreamCodes.NETSTREAM_BUFFER_EMPTY:
							CONFIG::LOGGING
							{			
								logger.debug(STREAM_RECONNECT_LOGGING_PREFIX+"buffer empty, netConnection.connected="+netConnection.connected);
							}
							if (!netConnection.connected)
							{
								// Start the timeout timer
								if (timeoutTimer != null)
								{
									timeoutTimer.start();
								}
								else
								{
									reconnectHasTimedOut = true;
								}
							}
							else
							{
								bufferIsEmpty = true;
							}
							break;
						case NetStreamCodes.NETSTREAM_BUFFER_FULL:
							bufferIsEmpty = false;
							break;
					}
				}
				
				function onTimeoutTimer(event:TimerEvent):void
				{
					CONFIG::LOGGING
					{			
						logger.debug(STREAM_RECONNECT_LOGGING_PREFIX+"reconnect timer timed out...");
					}
					reconnectHasTimedOut = true;	
				}
				
				function onReconnectTimer(event:TimerEvent):void
				{
					if (reconnectHasTimedOut)
					{
						return;
					}
					
					if (netConnection === loadTrait.connection)
					{
						setupNetConnectionListeners(false);
						
						CONFIG::LOGGING
						{
							logger.debug(STREAM_RECONNECT_LOGGING_PREFIX+"About to create a new NetConnection...");
						}

						netConnection = createReconnectNetConnection();
						netConnection.client = new NetClient();						
						setupNetConnectionListeners();
					}
					
					CONFIG::LOGGING
					{
						logger.info(STREAM_RECONNECT_LOGGING_PREFIX+"Calling reconnectNetConnection to try to reconnect...");
					}

					reconnect(netConnection, loadTrait.resource as URLResource);
				}
			}
		}
				
		/**
		 * Initiates the process of creating a connected NetConnection
		 * 
		 * @private
		 */
		private function startLoadingRTMP(loadTrait:LoadTrait):void
		{
			addPendingLoad(loadTrait);
			
			netConnectionFactory.create(loadTrait.resource as URLResource);
		}
		
		/**
		 * Called once the NetConnectionFactoryBase has successfully created a NetConnection
		 * 
		 * @private
		 */
		private function onCreationComplete(event:NetConnectionFactoryEvent):void
		{
			/**
			 * Originally, it calls finishLoading right away. However, there are circumstances (such as multicast)
			 * that a subclass of NetLoader may want to do some processing before calling finishLoading.
			 * So, we add the protected processCreationComplete function as an intermediary. 
			 */
			processCreationComplete
				( event.netConnection
				, findAndRemovePendingLoad(event.resource)
				, event.currentTarget as NetConnectionFactoryBase
				);
		}
		
		/**
		 * @private
		 * 
		 * This function is meant to be overridden if a subclass needs to conduct some processing before
		 * entering the final phase of loading. For instance, in multicast, the subclass may want to create
		 * a NetGroup before finishing the load.
		 * 
		 * @param connection
		 * @param loadTrait
		 * @param factory
		 */
		protected function processCreationComplete(connection:NetConnection, loadTrait:LoadTrait, factory:NetConnectionFactoryBase = null):void
		{
			finishLoading(connection, loadTrait, factory);
		}
		
		/**
		 * Called once the NetConnectionFactoryBase has failed to create a NetConnection
		 * TBD - error dispatched at lower level.
		 * 
		 * @private
		 */
		private function onCreationError(event:NetConnectionFactoryEvent):void
		{
			var loadTrait:LoadTrait = findAndRemovePendingLoad(event.resource);
			if (loadTrait != null)
			{
				loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, event.mediaError));
				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
			}
		}
		
		/**
		 * Initiates a HTTP connection.
		 * 
		 * @private
		 * 
		 */
		private function startLoadingHTTP(loadTrait:LoadTrait):void
		{
			var connection:NetConnection = new NetConnection();
			connection.client = new NetClient();
			connection.connect(null);
			finishLoading(connection, loadTrait);
		}
		
		private function addPendingLoad(loadTrait:LoadTrait):void
		{
			// It's an edge case, but we don't want to assume that we'll never
			// have two LoadTraits that use the same URLResource, so we have to
			// maintain an Array.
			if (pendingLoads[loadTrait.resource] == null)
			{
				pendingLoads[loadTrait.resource] = [loadTrait];
			}
			else
			{
				pendingLoads[loadTrait.resource].push(loadTrait);
			}
		}
		
		private function findAndRemovePendingLoad(resource:URLResource):LoadTrait
		{
			var loadTrait:LoadTrait = null;
			
			var pendingLoadsArray:Array = pendingLoads[resource];
			if (pendingLoadsArray != null)
			{
				if (pendingLoadsArray.length == 1)
				{
					loadTrait = pendingLoadsArray[0] as LoadTrait;
					delete pendingLoads[resource];
				}
				else
				{
					for (var i:int = 0; i < pendingLoadsArray.length; i++)
					{
						loadTrait = pendingLoadsArray[i];
						if (loadTrait.resource == resource)
						{
							pendingLoadsArray.splice(i, 1);
							break;
						}
					}
				}
			}

			return loadTrait;
		}

		private var netConnectionFactory:NetConnectionFactoryBase;
		private var pendingLoads:Dictionary = new Dictionary();
		private var oldConnectionURLs:Dictionary = new Dictionary();
		
		CONFIG::FLASH_10_1	
		{					
			private var _reconnectStreams:Boolean = true;
			private var _reconnectTimeout:Number;
		}
		
		private static const PROTOCOL_RTMP:String = "rtmp";
		private static const PROTOCOL_RTMPS:String = "rtmps";
		private static const PROTOCOL_RTMPT:String = "rtmpt";
		private static const PROTOCOL_RTMPE:String = "rtmpe";
		private static const PROTOCOL_RTMPTE:String = "rtmpte";
		private static const PROTOCOL_RTMFP:String = "rtmfp";
		private static const PROTOCOL_HTTP:String = "http";
		private static const PROTOCOL_HTTPS:String = "https";
		private static const PROTOCOL_FILE:String = "file";
		private static const PROTOCOL_EMPTY:String = "";
				
		private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.VIDEO]);
		private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>
		([
			"video/x-flv", 
			"video/x-f4v", 
			"video/mp4", 
			"video/mp4v-es", 
			"video/x-m4v", 
			"video/3gpp", 
			"video/3gpp2", 
			"video/quicktime", 
		]);
		
		CONFIG::FLASH_10_1	
		{				
			private static const STREAM_RECONNECT_TIMEOUT:Number = 120000;		// in milliseconds
			private static const STREAM_RECONNECT_TIMER_INTERVAL:int = 1000;	// in milliseconds
		}

		CONFIG::LOGGING
		{
			private static const STREAM_RECONNECT_LOGGING_PREFIX:String = "Stream reconnect: ";
		}

		CONFIG::LOGGING private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.net.NetLoader");
				
	}
}
