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
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	CONFIG::FLASH_10_1	
	{					
		import flash.net.NetGroup;
	}
	import flash.net.NetStream;
	import flash.utils.Dictionary;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.utils.OSMFStrings;
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
	}
	
	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class NetStreamLoadTrait extends LoadTrait
	{
		public function NetStreamLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
		{
			traits = new Dictionary();
			
			super(loader, resource);
			
			isStreamingResource = NetStreamUtils.isStreamingResource(resource);
		}
		
		/**
		 * The connected NetConnection, used for streaming audio and video.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */

	    public function get connection():NetConnection
	    {	   	
	   		return _connection;
	   	}
	   	
	   	public function set connection(value:NetConnection):void
	   	{
	   		CONFIG::LOGGING
	   		{
	   			if (_connection != null)
	   			{
	   				_connection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatusForLogging);
		   		}
		   	}
		   	
	   		_connection = value;

	   		CONFIG::LOGGING
	   		{
	   			if (_connection != null)
	   			{
	   				_connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusForLogging, false, 0, true);
		   		}
	   		}
	   	}
	   
        /**
		 * The NetStream associated with the NetConnection, used
         * for streaming audio and video.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
	    public function get netStream():NetStream
	    {	   	
	   		return _netStream;
	   	}
	   	
	   	public function set netStream(value:NetStream):void
	   	{
	   		CONFIG::LOGGING
	   		{
	   			if (_netStream != null)
	   			{
	   				_netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatusForLogging);
		   		}
		   	}

	   		_netStream = value;

	   		CONFIG::LOGGING
	   		{
	   			if (_netStream != null)
	   			{
	   				_netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusForLogging, false, 0, true);
		   		}
	   		}
	   	}

        /**
		 * The NetGroup to join for multicast. This property is only valid when the stream is a multicast stream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		CONFIG::FLASH_10_1	
		{						 
		    public function get netGroup():NetGroup
		    {	   	
		   		return _netGroup;
		   	}
		   	
		   	public function set netGroup(value:NetGroup):void
		   	{
		   		CONFIG::LOGGING
		   		{
		   			if (_netGroup != null)
		   			{
		   				_netGroup.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatusForLogging);
			   		}
			   	}

		   		_netGroup = value;

		   		CONFIG::LOGGING
		   		{
		   			if (_netGroup != null)
		   			{
		   				_netGroup.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusForLogging, false, 0, true);
			   		}
		   		}
		   	}
		}

        /**
		 * Manager class for switching between different MBR renditions using
		 * a NetStream.  Null if MBR switching is not enabled for the NetStream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
	    public function get switchManager():NetStreamSwitchManagerBase
	    {	   	
	   		return _switchManager;
	   	}
	   	
	   	public function set switchManager(value:NetStreamSwitchManagerBase):void
	   	{
	   		_switchManager = value;
	   	}
	   	
	   	/**
	   	 * @private
	   	 * 
	   	 * Stores the given trait on the object. Only one trait object
	   	 * can be stored per trait type. The last set trait is returned
	   	 * by <code>getTrait</code>.
	   	 * 
	   	 * @param trait The trait object to store.
	   	 * @throws IllegalOperationError if the specified trait is null.
	   	 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	   	 */
	   	public function setTrait(trait:MediaTraitBase):void
	   	{
	   		if (trait == null)
	   		{
	   			throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
	   		}
	   		
	   		traits[trait.traitType] = trait;
	   	}
	   	
	   	/**
	   	 * @private
	   	 * 
	   	 * Returns the stored trait object for the given trait type, if any.
	   	 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
	   	 */
	   	public function getTrait(traitType:String):MediaTraitBase
	   	{
	   		return traits[traitType];
	   	}
	   	
	   	/**
		 * The NetConnectionFactoryBase associated with the NetConnection.
		 * If a NetConnectionFactory is used and the NetConnection is shared,
		 * then the NetConnection should be closed by calling
		 * closeNetConnectionByResource() on the NetConnectionFactory instance
		 * rather than on the NetConnection itself.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
	    public function get netConnectionFactory():NetConnectionFactoryBase
	    {	   	
	   		return _netConnectionFactory;
	   	}
	   	
	   	public function set netConnectionFactory(value:NetConnectionFactoryBase):void
	   	{
	   		_netConnectionFactory = value;
	   	}
	   	
	   	/**
	   	 * @private
	   	 **/
		override protected function loadStateChangeStart(newState:String):void
		{
			if (newState == LoadState.READY)
			{
				if (	!isStreamingResource
					 && (  netStream.bytesTotal <= 0
					 	|| netStream.bytesTotal == uint.MAX_VALUE
					 	)
				   )
				{
					netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				}
			}
			else if (newState == LoadState.UNINITIALIZED)
			{
				netStream = null;
				dispatchEvent(new LoadEvent(LoadEvent.BYTES_LOADED_CHANGE, false, false, null, bytesLoaded));
				dispatchEvent(new LoadEvent(LoadEvent.BYTES_TOTAL_CHANGE, false, false, null, bytesTotal));	
			}
		}
		
		/**
		 * @private
		 */
		override public function get bytesLoaded():Number
		{
			return isStreamingResource ? NaN : (netStream != null ? netStream.bytesLoaded : NaN);
		}
		
		/**
		 * @private
		 */
		override public function get bytesTotal():Number
		{
			return isStreamingResource ? NaN : (netStream != null ? netStream.bytesTotal : NaN);
		}
		
		// Internals
		//
		
		private function onNetStatus(event:NetStatusEvent):void
		{
			if (netStream != null && netStream.bytesTotal > 0)
			{
				dispatchEvent
					( new LoadEvent
						( LoadEvent.BYTES_TOTAL_CHANGE
						, false
						, false
						, null
						, netStream.bytesTotal
						)
					);
					
				netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			}
		}
		
		CONFIG::LOGGING
		{
			private function onNetStatusForLogging(event:NetStatusEvent):void
			{
				logger.info(event.info.code);
			}
		}	 

	   	private var _connection:NetConnection;
	   	private var _switchManager:NetStreamSwitchManagerBase;
	   	private var traits:Dictionary;
	   	private var _netConnectionFactory:NetConnectionFactoryBase;

		private var isStreamingResource:Boolean;
		private var _netStream:NetStream;
		CONFIG::FLASH_10_1	
		{						 		
			private var _netGroup:NetGroup;
		}
		
		CONFIG::LOGGING private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.net.NetStreamLoadTrait");
	}
}