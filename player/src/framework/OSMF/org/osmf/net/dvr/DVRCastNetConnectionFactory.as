/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.net.dvr
{
	import __AS3__.vec.Vector;
	
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.Dictionary;
	
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.NetConnectionFactoryEvent;
	import org.osmf.media.URLResource;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.NetConnectionFactory;
	import org.osmf.net.NetConnectionFactoryBase;
	import org.osmf.net.NetStreamUtils;
	import org.osmf.net.StreamingURLResource;

	[ExcludeClass]

	/**
	 * @private
	 */	
	public class DVRCastNetConnectionFactory extends NetConnectionFactoryBase
	{
		/**
		 * Constructor.
		 **/
		public function DVRCastNetConnectionFactory(factory:NetConnectionFactoryBase = null)
		{
			subscribedStreams = new Dictionary();
			
			innerFactory = factory || new NetConnectionFactory();
			
			innerFactory.addEventListener
				( NetConnectionFactoryEvent.CREATION_COMPLETE
				, onCreationComplete
				);
				
			innerFactory.addEventListener
				( NetConnectionFactoryEvent.CREATION_ERROR
				, onCreationError
				);
			
			super();
		}

		/**
		 * @private
		 **/
		override public function create(resource:URLResource):void
		{
			innerFactory.create(resource);
		}
		
		/**
		 * @private
		 **/
		override public function closeNetConnection(netConnection:NetConnection):void
		{
			var streamName:String = subscribedStreams[netConnection];
			if (streamName != null)
			{
				netConnection.call
					( DVRCastConstants.RPC_UNSUBSCRIBE
					, null
					, streamName
					);	 
				
				delete subscribedStreams[netConnection];
			}
			
			innerFactory.closeNetConnection(netConnection);
		}
		
		// Internals
		//

		private function onCreationComplete(event:NetConnectionFactoryEvent):void
		{
			var urlResource:URLResource = event.resource as URLResource;
			var netConnection:NetConnection = event.netConnection;
			var streamNames:Vector.<String> = new Vector.<String>();
			var totalRpcSubscribeInvocation:int = 0;
			
			// Capture this event, whithold it from the outside world until
			// we have succeeded subscribing to the DVRCast stream:
			event.stopImmediatePropagation();
			
			var streamingResource:StreamingURLResource = urlResource as StreamingURLResource;
			
			var urlIncludesFMSApplicationInstance:Boolean
				= streamingResource
					? streamingResource.urlIncludesFMSApplicationInstance
					: false;
			
			var dynamicResource:DynamicStreamingResource = streamingResource as DynamicStreamingResource;
			if (dynamicResource != null)
			{
				var items:Vector.<DynamicStreamingItem> = dynamicResource.streamItems;
				totalRpcSubscribeInvocation = items.length;
				for (var i:int = 0; i < items.length; i++)
				{
					streamNames.push(items[i].streamName);
				}
			}	
			else
			{	
				totalRpcSubscribeInvocation = 1;
				streamNames.push(NetStreamUtils.getStreamNameFromURL(urlResource.url, urlIncludesFMSApplicationInstance));
			}
			
			var responder:Responder 
				= new TestableResponder
					( onStreamSubscriptionResult
					, onServerCallError
					);
			
			for (i = 0; i < streamNames.length; i++)
			{
				event.netConnection.call(DVRCastConstants.RPC_SUBSCRIBE, responder, streamNames[i]);
			}
			
			function onStreamSubscriptionResult(result:Object):void
			{
				totalRpcSubscribeInvocation--;
				if (totalRpcSubscribeInvocation <= 0)
				{	
					var streamInfoRetriever:DVRCastStreamInfoRetriever
						= new DVRCastStreamInfoRetriever
							( netConnection
							, streamNames[0]
							);
					
					streamInfoRetriever.addEventListener(Event.COMPLETE, onStreamInfoRetrieverComplete);
					streamInfoRetriever.retrieve();
				}
			}
			
			function onStreamInfoRetrieverComplete(event:Event):void
			{
				var streamInfoRetriever:DVRCastStreamInfoRetriever = event.target as DVRCastStreamInfoRetriever;
				
				// Remove the completion listener:
				removeEventListener(NetConnectionFactoryEvent.CREATION_COMPLETE, onCreationComplete);
				
				if (streamInfoRetriever.streamInfo != null)
				{				
					if (streamInfoRetriever.streamInfo.offline == true)
					{
						// The content is offline, signal this as a media error:
						dispatchEvent
							( new NetConnectionFactoryEvent
								( NetConnectionFactoryEvent.CREATION_ERROR 
								, false
								, false
								, netConnection
								, urlResource
								, new MediaError(MediaErrorCodes.DVRCAST_CONTENT_OFFLINE)
								)
							);
							
						// Unsubscribe:
						for (i = 0; i < streamNames.length; i++)
						{
							netConnection.call(DVRCastConstants.RPC_UNSUBSCRIBE, null, streamNames[i]);
						}
						netConnection = null;
					}
					else
					{
						// Instantiate a new recording info object:
						var recordingInfo:DVRCastRecordingInfo = new DVRCastRecordingInfo();
						recordingInfo.startDuration = streamInfoRetriever.streamInfo.currentLength;
						recordingInfo.startOffset = calculateOffset(streamInfoRetriever.streamInfo);
						recordingInfo.startTime = new Date();
						
						// Add the stream info and recording info to the resource as metadata:
						streamingResource.addMetadataValue(DVRCastConstants.STREAM_INFO_KEY, streamInfoRetriever.streamInfo);
						streamingResource.addMetadataValue(DVRCastConstants.RECORDING_INFO_KEY, recordingInfo);
						
						// Store the subscribed stream with the connection instance:
						subscribedStreams[netConnection] = streamNames[0];
							
						// Now that we're done, signal completion, so the VideoElement will
						// continue its loading process:
						dispatchEvent
							( new NetConnectionFactoryEvent
								( NetConnectionFactoryEvent.CREATION_COMPLETE 
								, false
								, false
								, netConnection
								, urlResource
								)
							);
					}
				}
				else
				{
					onServerCallError(streamInfoRetriever.error);
				}
			}
			
			function onServerCallError(error:Object):void
			{
				dispatchEvent
					( new NetConnectionFactoryEvent
						( NetConnectionFactoryEvent.CREATION_ERROR
						, false
						, false
						, netConnection
						, urlResource
						, new MediaError(MediaErrorCodes.DVRCAST_SUBSCRIBE_FAILED, error ? error.message : "")
						)
					);
			}	
		}
		
		private function onCreationError(event:NetConnectionFactoryEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		private function calculateOffset(streamInfo:DVRCastStreamInfo):Number
		{
			return DVRUtils.calculateOffset(streamInfo.beginOffset, streamInfo.endOffset, streamInfo.currentLength);
		}
		
		private var innerFactory:NetConnectionFactoryBase;
		private var subscribedStreams:Dictionary;
	}
}