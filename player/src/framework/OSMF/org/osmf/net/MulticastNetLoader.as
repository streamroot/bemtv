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
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	
	CONFIG::FLASH_10_1
	{
	import flash.net.NetGroup;
	}

	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}

	/**
	 * Extends NetLoader to provide
	 * loading support for multicast video playback using RTMFP protocol.
	 * 
	 * <p> MulticastNetLoader expects the media resource to be a StreamingURLResource,
	 * in which groupspec and streamName are specified.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.5
	 */
	public class MulticastNetLoader extends NetLoader
	{
		/**
		 * @private
		 * @inheritDoc
		**/
		public function MulticastNetLoader(factory:NetConnectionFactoryBase=null)
		{
			var newFactory:NetConnectionFactory;
			if (factory == null)
			{
				
				newFactory = new NetConnectionFactory();
				newFactory.timeout = 60000;
			}
			super((factory != null)? factory: newFactory);
		}
		
		/**
		 * @private
		 * 
		 * MulticastNetLoader returns true if the resource is an instance of StreamingURLResource with
		 * both groupspec and streamName set.
		 * 
		 * @param resource The URL of the source media.
		 * @return Returns <code>true</code> for resouces of type StreamingURLResource.
		 * @inheritDoc
		**/
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			var rs:MulticastResource = resource as MulticastResource;

            return rs != null && 
				rs.groupspec != null && 
				rs.groupspec.length > 0 && 
				rs.streamName != null && 
				rs.streamName.length > 0;
        }

		/**
		 * @private
		 * @inheritDoc
		**/
		override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream
		{
			
			var rs:MulticastResource = resource as MulticastResource;

			CONFIG::LOGGING	
			{
				logger.info("Creating multicast NetStream with groupspec " + rs.groupspec);
			}

			var ns:NetStream = new NetStream(connection, rs.groupspec);
			CONFIG::LOGGING	
			{
				if (ns != null)
				{
					logger.info("Multicast NetStream created.");
				}
			}
			
			return ns;
		}
		
		/**
		 *  Things become a little complex here. For multicast, the first time user will encounter a
		 *  pop up dialog box for Peer Assited Network setting. The user may choose either to allow and deny.
		 *  Also, the user may choose to remember the decision. If the user chooses to "allow", the client 
		 *  can proceed to receive multicast contents. Otherwise, the client cannot proceed. 
		 * 
		 *  In terms of OSMF and Flex classes, OSMF should not proceed until it receives either 
		 *  "NetGroup.Connect.Success" or "NetStream.Connect.Success". Otherwise, multicast will not work and
		 *  any attempt to access net stream or net group will incur exception (RTE). 
		 *
		 *  Therefore, the code here takes this scenario into consideration and wait for the "NetGroup.Connect.Success"
		 *  before it proceeds.
		 *
		 *  @private
		**/
		CONFIG::FLASH_10_1	
		{						 
			override protected function processCreationComplete(connection:NetConnection, loadTrait:LoadTrait, factory:NetConnectionFactoryBase = null):void
			{
				var netLoadTrait:NetStreamLoadTrait = loadTrait as NetStreamLoadTrait;
				var multicastResource:MulticastResource = netLoadTrait.resource as MulticastResource;
				connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				var netGroup:NetGroup = new NetGroup(connection, multicastResource.groupspec);
				
				function onNetStatus(event:NetStatusEvent):void
				{
					switch(event.info.code)
					{
						case "NetGroup.Connect.Success":
							connection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
							netLoadTrait.netGroup = netGroup;
							doProcessCreationComplete(connection, loadTrait, factory);
							break;
						
						case "NetGroup.Connect.Failed":
						case "NetGroup.Connect.Rejected":
							connection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
							updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
							break;
					}
				}
			}
		}
		
		/**
		 * Help the enclosed onNetStatus function to call super.processCreationComplete.
		 * 
		 *  @private
		 */
		private function doProcessCreationComplete(connection:NetConnection, loadTrait:LoadTrait, factory:NetConnectionFactoryBase = null):void
		{
			super.processCreationComplete(connection, loadTrait, factory);			
		}
		
		CONFIG::LOGGING
		{
			private static var logger:Logger = org.osmf.logging.Log.getLogger("org.osmf.net.multicast.MulticastNetLoader");
		}	
	}
}
