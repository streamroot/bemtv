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
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.events.*;
	import org.osmf.media.URLResource;
	import org.osmf.net.httpstreaming.*;
	import org.osmf.net.rtmpstreaming.DroppedFramesRule;
	import org.osmf.net.httpstreaming.f4f.*;
	/**
	 * PlaybackOptimization adapter for RTMPDynamicStreamingNetLoader. 
	 */ 
	public class HTTPStreamingNetLoaderAdapter extends HTTPStreamingNetLoader
	{
		/**
		 * Constructor.
		 */ 
		public function HTTPStreamingNetLoaderAdapter(playbackOptimizationManager:PlaybackOptimizationManager)
		{
			this.playbackOptimizationManager = playbackOptimizationManager;
			super();			
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
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);	
			return super.createNetStreamSwitchManager(connection, netStream, dsResource);			
		}
		
		// Internals
		//		
		private function onNetStatus(event:NetStatusEvent):void
		{
			var netStream:NetStream = event.currentTarget as NetStream;
			if (event.info.code == NetStreamCodes.NETSTREAM_BUFFER_EMPTY)
			{
				if (netStream.bufferTime >= 2.0)
				{
					netStream.bufferTime += 1.0;
				}
				else
				{
					netStream.bufferTime = 2.0;
				}						
			}
		}			
	
		private var playbackOptimizationManager:PlaybackOptimizationManager;
	}
}