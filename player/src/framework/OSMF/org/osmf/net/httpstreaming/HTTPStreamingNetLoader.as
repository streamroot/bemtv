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
package org.osmf.net.httpstreaming
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.NetLoader;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.net.NetStreamSwitchManagerBase;
	import org.osmf.net.SwitchingRuleBase;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.net.httpstreaming.dvr.HTTPStreamingDVRCastDVRTrait;
	import org.osmf.net.httpstreaming.dvr.HTTPStreamingDVRCastTimeTrait;
	import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FFactory;
	import org.osmf.net.rtmpstreaming.DroppedFramesRule;
	import org.osmf.traits.LoadState;

	/**
	 * HTTPStreamingNetLoader is a NetLoader that can load HTTP streams.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class HTTPStreamingNetLoader extends NetLoader
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function HTTPStreamingNetLoader()
		{
			// Connection sharing and custom NetConnectionFactory classes are
			// irrelevant for HTTP streaming connections, hence we don't allow
			// the client to pass those params in.
			super();
		}
		
		/**
		 * @private
		 */
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			return (resource.getMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA) as Metadata) != null;
		}
		
		/**
		 * @private
		 */
		override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream
		{
			var factory:HTTPStreamingFactory = createHTTPStreamingFactory();
			var httpNetStream:HTTPNetStream = new HTTPNetStream(connection, factory, resource);
			return httpNetStream;
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
				var metrics:HTTPNetStreamMetrics = new HTTPNetStreamMetrics(netStream as HTTPNetStream);
				return new HTTPStreamingSwitchManager(connection, netStream, dsResource, metrics, getDefaultSwitchingRules(metrics));
			}
			return null;
		}
		
		/**
		 * @private
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		override protected function processFinishLoading(loadTrait:NetStreamLoadTrait):void
		{
			var resource:URLResource = loadTrait.resource as URLResource;
			
			if (!dvrMetadataPresent(resource))
			{
				updateLoadTrait(loadTrait, LoadState.READY);
				
				return;
			}

			var netStream:HTTPNetStream = loadTrait.netStream as HTTPNetStream;
			netStream.addEventListener(DVRStreamInfoEvent.DVRSTREAMINFO, onDVRStreamInfo);
			netStream.DVRGetStreamInfo(null);
			function onDVRStreamInfo(event:DVRStreamInfoEvent):void
			{
				netStream.removeEventListener(DVRStreamInfoEvent.DVRSTREAMINFO, onDVRStreamInfo);
				
				loadTrait.setTrait(new HTTPStreamingDVRCastDVRTrait(loadTrait.connection, netStream, event.info as DVRInfo));
				loadTrait.setTrait(new HTTPStreamingDVRCastTimeTrait(loadTrait.connection, netStream, event.info as DVRInfo));
				updateLoadTrait(loadTrait, LoadState.READY);
			}
		}
		
		/**
		 * @private
		 * 
		 * Override this method to use a different factory object with HTTPNetStream objects.
		 */
		protected function createHTTPStreamingFactory():HTTPStreamingFactory
		{
			return new HTTPStreamingF4FFactory();
		}
		
		//
		// Internal
		//

		private function dvrMetadataPresent(resource:URLResource):Boolean
		{
			var metadata:Metadata = resource.getMetadataValue(MetadataNamespaces.DVR_METADATA) as Metadata;
			
			return (metadata != null);
		}
		
		private function getDefaultSwitchingRules(metrics:HTTPNetStreamMetrics):Vector.<SwitchingRuleBase>
		{
			var rules:Vector.<SwitchingRuleBase> = new Vector.<SwitchingRuleBase>();
			rules.push(new DownloadRatioRule(metrics, false));
			rules.push(new DroppedFramesRule(metrics));
			return rules;
		}
	}
}