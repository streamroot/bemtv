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
	import flash.net.NetStream;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.TimeTrait;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The NetStreamTimeTrait class extends TimeTrait to expose NetStream's time properties.
	 * 
	 * @see flash.net.NetStream
	 */ 	
	public class NetStreamTimeTrait extends TimeTrait
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 		
		public function NetStreamTimeTrait(netStream:NetStream, resource:MediaResourceBase, defaultDuration:Number=NaN)
		{
			super();
			
			this.netStream = netStream;			
			NetClient(netStream.client).addHandler(NetStreamCodes.ON_META_DATA, onMetaData);
			NetClient(netStream.client).addHandler(NetStreamCodes.ON_PLAY_STATUS, onPlayStatus);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			this.resource = resource;
			
			if (isNaN(defaultDuration) == false)
			{
				setDuration(defaultDuration);
			}
			
			var streamResource:MulticastResource = resource as MulticastResource;
			if (streamResource != null && streamResource.groupspec != null && streamResource.groupspec.length > 0)
			{
				multicast = true;
				setDuration(Number.MAX_VALUE);
			}	
		}
		
		/**
		 * @private
		 */
		override public function get currentTime():Number
		{
			if (multicast)
			{
				return 0;
			}
			
			// If at the end of the video, make sure the duration matches the currentTime.  
			// Work around for FP-3724.  Only apply duration offset at the end - or else the seek(0) doesn't goto 0.
			if (durationOffset == (duration - (netStream.time - _audioDelay)))  
			{
				return netStream.time - _audioDelay + durationOffset;
			}
			else
			{
				return netStream.time - _audioDelay;
			}
		}
		
		private function onMetaData(value:Object):void
		{
			// Determine the start time and duration for the
			// resource.
			var playArgs:Object = NetStreamUtils.getPlayArgsForResource(resource);
			
			//Audio delay is sometimes passed along with the metadata.  The audio delay affects
			//all netsTream.time related calculations, including seek().
			_audioDelay = value.hasOwnProperty("audiodelay") ? value.audiodelay : 0;
			
			// Ensure our start time is non-negative, we only use it for
			// calculating the offset.
			var subclipStartTime:Number = Math.max(0, playArgs.start);
			
			// Ensure our duration is non-negative.
			var subclipDuration:Number = playArgs.len;
			if (subclipDuration == NetStreamUtils.PLAY_LEN_ARG_ALL)
			{
				subclipDuration = Number.MAX_VALUE;
			}
						
			// If startTime is unspecified, our duration is everything
			// up to the end of the subclip (or the entire duration, if
			// no subclip end is specified).  Take into account audio delay.
			setDuration(Math.min((value.duration - _audioDelay) - subclipStartTime, subclipDuration));
		}
		
		private function onPlayStatus(event:Object):void
		{			
			switch(event.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_COMPLETE:
					// For streaming, NetStream.Play.Complete means playback
					// has completed.  But this isn't fired for progressive.
					signalComplete();
			}
		}
						
		private function onNetStatus(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_STOP:
					// For progressive,	NetStream.Play.Stop means playback
					// has completed.  But this isn't fired for streaming.
					if (NetStreamUtils.isStreamingResource(resource) == false)
					{						
						signalComplete();
					}
					break;
				case NetStreamCodes.NETSTREAM_PLAY_UNPUBLISH_NOTIFY:
					// When a live stream is unpublished, we should signal that
					// the stream has stopped.
					signalComplete();
					break;
			}
		}
		
		/**
		 * We have to change the duration , given that audioDelay isn't enough to 
		 * fix that netStream.time has from the detected duration.  This isn't
		 * pre computable, since PLAY_STOP is fired at
		 * non-deterministic intervals when the video is near ending.
		 **/
		override protected function signalComplete():void
		{
			if ((netStream.time - _audioDelay) != duration)
			{
				durationOffset = duration - (netStream.time - _audioDelay);
			}
			super.signalComplete();
		}
		
		/**
		 * @private
		 **/
		internal function get audioDelay():Number
		{
			return _audioDelay;
		}
		
		private var durationOffset:Number = 0;
		private var _audioDelay:Number = 0;
		private var netStream:NetStream;
		private var resource:MediaResourceBase;
		private var multicast:Boolean = false;
	}
}