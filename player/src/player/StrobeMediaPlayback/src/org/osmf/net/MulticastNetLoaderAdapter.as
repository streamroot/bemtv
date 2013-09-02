/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/

package org.osmf.net
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.traits.LoadTrait;
	
	/**
	 * 
	 */
	public class MulticastNetLoaderAdapter extends MulticastNetLoader
	{
		public function MulticastNetLoaderAdapter(playbackOptimizationManager:PlaybackOptimizationManager, factory:NetConnectionFactoryBase = null)
		{
			this.playbackOptimizationManager = playbackOptimizationManager;
			super(factory);
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
			playbackOptimizationManager.optimizePlayback(connection, netStream, dsResource);
//			if (dsResource != null)
//			{
//				var metrics:RTMPNetStreamMetrics = new RTMPNetStreamMetrics(netStream);
//				var streamType:String = dsResource.getMetadataValue("streamType") as String;
//				return new StrobeNetStreamSwitchManager(connection, netStream, dsResource, metrics, getDefaultSwitchingRules(metrics, streamType));
//			}
			return null;
		}
		
		private var playbackOptimizationManager:PlaybackOptimizationManager;
	}
}