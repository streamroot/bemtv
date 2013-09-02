/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved.
* 
*  Contributor: Adobe Systems Inc.
*  
*****************************************************/
package org.osmf.net.rtmpstreaming
{
	import __AS3__.vec.Vector;
	
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamPlayOptions;
	import flash.net.NetStreamPlayTransitions;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.NetConnectionFactoryBase;
	import org.osmf.net.NetLoader;
	import org.osmf.net.NetStreamSwitchManager;
	import org.osmf.net.NetStreamSwitchManagerBase;
	import org.osmf.net.NetStreamLoadTrait;	
	import org.osmf.net.NetStreamUtils;
	import org.osmf.net.SwitchingRuleBase;
	
	/**
	 * RTMPDynamicStreamingNetLoader is a NetLoader that provides dynamic stream
	 * switching functionality for RTMP streams. It does this by creating a
	 * NetStreamSwitchManager for each LoadTrait that is loaded through this
	 * object.
	 * 
	 * <p>This class is "backwards compatible", meaning if it is not handed an
	 * RTMP DynamicStreamingResource then it will call the base class
	 * implementation for the <code>load</code> and <code>unload</code> methods.</p>
	 * 
	 * @includeExample RTMPDynamicStreamingNetLoaderExample.as -noswf
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class RTMPDynamicStreamingNetLoader extends NetLoader
	{
		/**
		 * Constructor.
		 * 
		 * @param factory the NetConnectionFactoryBase instance to use for managing NetConnections.
		 * If factory is null, a NetConnectionFactory will be created and used. Since the
		 * NetConnectionFactory class facilitates connection sharing, this is an easy way of
		 * enabling global sharing, by creating a single NetConnectionFactory instance within
		 * the player and then handing it to all RTMPDynamicStreamingNetLoader instances.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function RTMPDynamicStreamingNetLoader(factory:NetConnectionFactoryBase=null)
		{
			super(factory);
		}
		
		/**
		 * @private
		 */
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			// We can handle DynamicStreamingResources, or anything the base class
			// can handle.
			var dsResource:DynamicStreamingResource = resource as DynamicStreamingResource;
			return 		(	dsResource != null
						&& 	NetStreamUtils.isRTMPStream(dsResource.host)
						)
					||  super.canHandleResource(resource);
		}
				
		/**
		 * @private
		 * 
		 * Overridden to allow the creation of a NetStreamSwitchManager object.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override protected function createNetStreamSwitchManager(connection:NetConnection, netStream:NetStream, dsResource:DynamicStreamingResource):NetStreamSwitchManagerBase
		{
			// Only generate the switching manager if the resource is truly
			// switchable.
			if (dsResource != null)
			{
				var metrics:RTMPNetStreamMetrics = new RTMPNetStreamMetrics(netStream);
				return new NetStreamSwitchManager(connection, netStream, dsResource, metrics, getDefaultSwitchingRules(metrics));
			}
			return null;
		}
		
		CONFIG::FLASH_10_1	
		{				
			/**
			 * @private
			 * 
			 * Overridden to reconnect to the stream that was last playing.
			 **/
			override protected function reconnectStream(loadTrait:NetStreamLoadTrait):void
			{
				var dsResource:DynamicStreamingResource = loadTrait.resource as DynamicStreamingResource;
				if (dsResource == null)
				{
					super.reconnectStream(loadTrait);
				}
				else
				{
					var nsPlayOptions:NetStreamPlayOptions = new NetStreamPlayOptions();
					 
					loadTrait.netStream.attach(loadTrait.connection);
					nsPlayOptions.transition = NetStreamPlayTransitions.RESUME;
					
					var currentStreamItem:DynamicStreamingItem = dsResource.streamItems[loadTrait.switchManager.currentIndex]; 
					var streamName:String = currentStreamItem.streamName;
					
					nsPlayOptions.streamName = streamName; 			
					loadTrait.netStream.play2(nsPlayOptions);
				}
			}
		}
						
		private function getDefaultSwitchingRules(metrics:RTMPNetStreamMetrics):Vector.<SwitchingRuleBase>
		{
			var rules:Vector.<SwitchingRuleBase> = new Vector.<SwitchingRuleBase>();
			rules.push(new SufficientBandwidthRule(metrics));
			rules.push(new InsufficientBandwidthRule(metrics));
			rules.push(new DroppedFramesRule(metrics));
			rules.push(new InsufficientBufferRule(metrics));
			return rules;
		}
		
	}
}
