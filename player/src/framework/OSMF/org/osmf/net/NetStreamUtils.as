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
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.utils.URL;
	
	CONFIG::FLASH_10_1
	{
	import org.osmf.metadata.MetadataNamespaces;
	}
	
	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class NetStreamUtils
	{
		/**
		 * Returns the stream name to be passed to NetStream for a given URL,
		 * the empty string if no such stream name can be extracted.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function getStreamNameFromURL(url:String, urlIncludesFMSApplicationInstance:Boolean=false):String
		{
			var streamName:String = "";
			
			// The stream name varies based on RTMP vs. progressive.
			if (url != null)
			{
				if (isRTMPStream(url))
				{
					var fmsURL:FMSURL = new FMSURL(url, urlIncludesFMSApplicationInstance);
	
					streamName = fmsURL.streamName;
	
					// Add optional query parameters to the stream name.
					if (fmsURL.query != null && fmsURL.query != "")
					{
						 streamName += "?" + fmsURL.query;
					}
				}
				else
				{
					streamName = url;
				}
			}
			
			return streamName;
		}
		
		/**
		 * Returns true if the given resource represents a streaming resource, false otherwise.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function isStreamingResource(resource:MediaResourceBase):Boolean
		{
			var result:Boolean = false;
			
			if (resource != null)
			{
				var urlResource:URLResource = resource as URLResource;
				if (urlResource != null)
				{
					result = NetStreamUtils.isRTMPStream(urlResource.url);
					
 					CONFIG::FLASH_10_1
					{
					if (result == false)
					{
						result = urlResource.getMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA) != null;
					}
					}
 				}
			}
			
			return result;
		}

		/**
		 * Returns true if the given URL represents an RTMP stream, false otherwise.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function isRTMPStream(url:String):Boolean
		{
			var result:Boolean = false;
			
			if (url != null)
			{
				var theURL:URL = new URL(url);
				var protocol:String = theURL.protocol;
				if (protocol != null && protocol.length > 0)
				{
					result = (protocol.search(/^rtmp$|rtmp[tse]$|rtmpte$/i) != -1);
				}
			}
			
			return result;
		}
				
		/**
		 * Returns the stream type of the given resource.
		 * 
		 * @returns One of the stream types defined in org.osmf.net.StreamType
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function getStreamType(resource:MediaResourceBase):String
		{
			// Default to RECORDED.
			var streamType:String = StreamType.RECORDED;
			
			var streamingURLResource:StreamingURLResource = resource as StreamingURLResource;

			if (streamingURLResource != null)
			{
				streamType = streamingURLResource.streamType;
			}

			return streamType;
		}
		
		/**
		 * Returns the value of the "start" and "len" arguments for
		 * NetStream.play, based on the specified resource.  Checks for
		 * live vs. recorded, subclips, etc.  The results are returned
		 * in an untyped Object where the start value maps to "start"
		 * and the len value maps to "len".
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function getPlayArgsForResource(resource:MediaResourceBase):Object
		{
			var startArg:Number = PLAY_START_ARG_ANY;
			var lenArg:Number = PLAY_LEN_ARG_ALL;
			
			// Check for live vs. recorded.
			switch (getStreamType(resource))
			{
				case StreamType.LIVE_OR_RECORDED:
					startArg = PLAY_START_ARG_ANY;
					break;
				case StreamType.LIVE:
					startArg = PLAY_START_ARG_LIVE;
					break;
				case StreamType.RECORDED:
					startArg = PLAY_START_ARG_RECORDED;
					break;
			}
			
			// Check for subclip metadata (which is ignored for live).
			if 	(	startArg != PLAY_START_ARG_LIVE
				&&	resource != null
				)
			{
				var streamingResource:StreamingURLResource = resource as StreamingURLResource;
				if (streamingResource != null && isStreamingResource(streamingResource))
				{
					if (!isNaN(streamingResource.clipStartTime))
					{
						startArg = streamingResource.clipStartTime;
					}
					if (!isNaN(streamingResource.clipEndTime))
					{
						// The presence of any subclip info means that our startArg
						// should be non-negative.
						startArg = Math.max(0, startArg);
						
						// Disallow negative durations.
						lenArg = Math.max(0, streamingResource.clipEndTime - startArg);
					}
				}
			}
			
			return {start:startArg, len:lenArg};
		}
		
		// Consts for the NetStream.play() method
		public static const PLAY_START_ARG_ANY:int = -2;
		public static const PLAY_START_ARG_LIVE:int = -1;
		public static const PLAY_START_ARG_RECORDED:int = 0;
		public static const PLAY_LEN_ARG_ALL:int = -1;
	}
}