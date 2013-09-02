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
	import flash.net.NetStreamPlayOptions;
	import flash.net.NetStreamPlayTransitions;
	
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.utils.OSMFStrings;

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The NetStreamPlayTrait class extends PlayTrait for NetStream-based playback.
	 * 
	 * @see flash.net.NetStream
	 */   
	public class NetStreamPlayTrait extends PlayTrait
	{
		/**
		 * 	Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function NetStreamPlayTrait(netStream:NetStream, resource:MediaResourceBase, reconnectStreams:Boolean, netConnection:NetConnection)
		{
			super();
			
			if (netStream == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));					
			}
			this.netStream = netStream;
			this.netConnection = netConnection;
			this.urlResource = resource as URLResource;
			this.multicastResource = resource as MulticastResource;
			this.reconnectStreams = reconnectStreams;
			
			// Note that we add the listener (and handler) with a high priority.
			// The reason for this is that we want to process any Play.Stop (and
			// Play.Complete) events first, so that we can update our playing
			// state before the NetStreamTimeTrait processes the event and
			// dispatches the COMPLETE event.  Clients who register for the
			// COMPLETE event will expect that the media is no longer playing.
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 1, true);
			NetClient(netStream.client).addHandler(NetStreamCodes.ON_PLAY_STATUS, onPlayStatus, 1);
		}
		
		/**
		 * @private
		 * Communicates a <code>playing</code> change to the media through the NetStream. 
		 * <p>For streaming media, parses the URL to extract the stream name.</p>
		 * @param newPlaying New <code>playing</code> value.
		 */								
		override protected function playStateChangeStart(newPlayState:String):void
		{
			if (newPlayState == PlayState.PLAYING)
			{
				var playArgs:Object;
				
				if (streamStarted)
				{
					if (multicastResource != null)
					{
						netStream.play(multicastResource.streamName, -1 , -1);
					}
					else
					{
						netStream.resume();
					}
				}
				else if (urlResource != null) 
				{
					// Map the resource to the NetStream.play/play2 arguments.
					var streamingResource:StreamingURLResource = urlResource as StreamingURLResource;
					var urlIncludesFMSApplicationInstance:Boolean = streamingResource ? streamingResource.urlIncludesFMSApplicationInstance : false;
					var streamName:String = NetStreamUtils.getStreamNameFromURL(urlResource.url, urlIncludesFMSApplicationInstance);
					
					playArgs = NetStreamUtils.getPlayArgsForResource(urlResource);
					
					var startTime:Number = playArgs.start;
					var len:Number = playArgs.len;
					
					var dsResource:DynamicStreamingResource = urlResource as DynamicStreamingResource;
					var nso:NetStreamPlayOptions;

					if (dsResource != null)
					{
						// Play the clip (or the requested portion of the clip).
						nso = new NetStreamPlayOptions();
						nso.start = startTime;
						nso.len = len;
						nso.streamName = dsResource.streamItems[dsResource.initialIndex].streamName;
						nso.transition = NetStreamPlayTransitions.RESET;
					
						doPlay2(nso);
					}
					else if (reconnectStreams && streamingResource != null &&
								NetStreamUtils.isRTMPStream(streamingResource.url))
					{
						nso = new NetStreamPlayOptions();
						nso.start = startTime;
						nso.len = len;
						nso.transition = NetStreamPlayTransitions.RESET;
						nso.streamName = streamName;
						
						doPlay2(nso);
					}
					else
					{
						if (multicastResource != null && multicastResource.groupspec != null && multicastResource.groupspec.length > 0)
						{
							doPlay(multicastResource.streamName, startTime, len);
						}
						else
						{
							// Play the clip (or the requested portion of the clip).
							doPlay(streamName, startTime, len);
						}
					}
				}
			}
			else // PAUSED || STOPPED
			{
				if (multicastResource != null)
				{
					netStream.play(false);
				}
				else
				{
					netStream.pause();
				}
			}
		}

		// Needed to detect when the stream didn't play:  i.e. complete or error cases.
		private function onNetStatus(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_FAILED:
				case NetStreamCodes.NETSTREAM_PLAY_FILESTRUCTUREINVALID:
				case NetStreamCodes.NETSTREAM_PLAY_STREAMNOTFOUND:
				case NetStreamCodes.NETSTREAM_PLAY_NOSUPPORTEDTRACKFOUND:				
				case NetStreamCodes.NETSTREAM_FAILED:
					// Pause the stream and reset our state, but don't
					// signal stop().  The MediaElement's netStatus
					// event handler will catch the error, and coerce
					// to a MediaError.
					netStream.pause();
					streamStarted = false;
					break;
				case NetStreamCodes.NETSTREAM_PLAY_STOP:
					// Fired when streaming connections buffer, but also when
					// progressive connections finish.  In the latter case, we
					// halt playback.
					if (urlResource != null && NetStreamUtils.isStreamingResource(urlResource) == false) 
					{
						// Explicitly stop to prevent the stream from restarting on seek();
						stop();
					}
					break;
			}
		}
		
		private function onPlayStatus(event:Object):void
		{
			switch (event.code)
			{
				// Fired when streaming connections finish.  Doesn't fire for
				// Progressive connections.  
				case NetStreamCodes.NETSTREAM_PLAY_COMPLETE:
					// Explicitly stop to prevent the stream from restarting on seek();
					stop();
					break;
			}
		}

		private function doPlay(...args):void
		{
			try
			{
				netStream.play.apply(this, args);
				
				streamStarted = true;
			}
			catch (error:Error)
			{
				streamStarted = false;
				stop();
				
				dispatchEvent
					( new MediaErrorEvent
						( MediaErrorEvent.MEDIA_ERROR
						, false
						, false
						, new MediaError(MediaErrorCodes.NETSTREAM_PLAY_FAILED)
						)
					);
			}
		}
		
		private function doPlay2(nspo:NetStreamPlayOptions):void
		{
			netStream.play2(nspo);
				
			streamStarted = true;
		}
		
		private static const NETCONNECTION_FAILURE_ERROR_CODE:int = 2154;
		
		private var streamStarted:Boolean;
		private var netStream:NetStream;
		private var netConnection:NetConnection;
		private var urlResource:URLResource;
		private var multicastResource:MulticastResource;
		private var reconnectStreams:Boolean;
	}
}
