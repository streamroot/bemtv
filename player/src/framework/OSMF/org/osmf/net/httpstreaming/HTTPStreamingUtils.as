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
	import flash.utils.ByteArray;
	
	import org.osmf.elements.f4mClasses.BootstrapInfo;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FIndexInfo;
	import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FStreamInfo;
	import org.osmf.utils.URL;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Contains a set of HTTP streaming-related utility functions.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class HTTPStreamingUtils
	{
		/**
		 * This is a convenience function to create the Metadata object for HTTP streaming.
		 * Usually, either abstUrl or abstData is not null. 
		 * 
		 * @param abstUrl The URL that points to the bootstrap information.
		 * @param abstData The byte array that contains the bootstrap information
		 * @param serverBaseUrls The list of server base URLs.
		 * 
		 * @return The metadata.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function createHTTPStreamingMetadata(abstUrl:String, abstData:ByteArray, serverBaseUrls:Vector.<String>):Metadata
		{
			var metadata:Metadata = new Metadata();
			var bootstrap:BootstrapInfo = new BootstrapInfo();
			if (abstUrl != null && abstUrl.length > 0)
			{
				bootstrap.url = abstUrl;
			}
			bootstrap.data = abstData;
			metadata.addValue(MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY, bootstrap);
			
			if (serverBaseUrls != null && serverBaseUrls.length > 0)
			{
				metadata.addValue(MetadataNamespaces.HTTP_STREAMING_SERVER_BASE_URLS_KEY, serverBaseUrls);
			}
			return metadata;
		}

		/**
		 * Creates a HTTP Streaming resource derived from an original resource.
		 *  
		 * @return The HDS streaming resource.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 * 
		 */ 
		public static function createHTTPStreamingResource(resource:MediaResourceBase, streamName:String):MediaResourceBase
		{
			if (streamName == null)
			{
				return null;
			}
			
			var bootstrap:BootstrapInfo = null;
			var streamMetadata:Object;
			var xmpMetadata:ByteArray;
			var serverBaseURLs:Vector.<String>;

			var httpMetadata:Metadata = resource.getMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA) as Metadata;
			if (httpMetadata == null)
			{
				// XXX maybe we should throw an exception here?
				return null;
			}
			var resourceMetadata:Metadata = new Metadata();
			
			bootstrap = httpMetadata.getValue(MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY + streamName) as BootstrapInfo;
			if (bootstrap != null)
			{
				resourceMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY, bootstrap);
			}
			
			streamMetadata = httpMetadata.getValue(MetadataNamespaces.HTTP_STREAMING_STREAM_METADATA_KEY + streamName);
			if (streamMetadata != null)
			{
				resourceMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_STREAM_METADATA_KEY, streamMetadata);
			}
			
			xmpMetadata = httpMetadata.getValue(MetadataNamespaces.HTTP_STREAMING_XMP_METADATA_KEY + streamName) as ByteArray;
			if (xmpMetadata != null)
			{
				resourceMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_XMP_METADATA_KEY, xmpMetadata);
			}
			
			serverBaseURLs = httpMetadata.getValue(MetadataNamespaces.HTTP_STREAMING_SERVER_BASE_URLS_KEY) as Vector.<String>;
			if (serverBaseURLs != null)
			{
				resourceMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_SERVER_BASE_URLS_KEY,serverBaseURLs);
			}
			
			var baseUrl:String = "";
			if (serverBaseURLs != null && serverBaseURLs.length > 0)
			{
				baseUrl = serverBaseURLs[0].toString();
			}
			
			var streamWholeURL:String = streamName;
			
			if (!URL.isAbsoluteURL(streamWholeURL))
			{
				streamWholeURL = URL.normalizeRootURL(baseUrl) + URL.normalizeRelativeURL(streamWholeURL);
			}
			
			var httpResource:MediaResourceBase = new StreamingURLResource(streamWholeURL);
			httpResource.addMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA, resourceMetadata);
			return httpResource;
		}
		
		/**
		 * @private
		 **/
		public static function createF4FIndexInfo(resource:URLResource):HTTPStreamingF4FIndexInfo
		{
			var indexInfo:HTTPStreamingF4FIndexInfo = null;
			
			var httpMetadata:Metadata = resource.getMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA) as Metadata;
			var dvrMetadata:Metadata = resource.getMetadataValue(MetadataNamespaces.DVR_METADATA) as Metadata;
			if (httpMetadata != null)
			{
				var serverBaseURLs:Vector.<String>
					= httpMetadata.getValue(MetadataNamespaces.HTTP_STREAMING_SERVER_BASE_URLS_KEY) as Vector.<String>;
				var streamInfos:Vector.<HTTPStreamingF4FStreamInfo> = generateStreamInfos(resource);
				var dvrInfo:DVRInfo = generateDVRInfo(dvrMetadata);
				
				indexInfo =
					new HTTPStreamingF4FIndexInfo
						( 
						serverBaseURLs != null && serverBaseURLs.length > 0 ? serverBaseURLs[0] : null
						, streamInfos
						, dvrInfo
						);
			}
			
			return indexInfo;
		}
		
		public static function normalizeURL(url:String):String
		{
			var ret:String = "";
			var protocol:String = "";
			var temp:String;
			
			if (url.indexOf("http://") == 0)
			{
				protocol = "http://";
			}
			else if (url.indexOf("https://") == 0)
			{
				protocol = "https://";
			}
			
			if (protocol.length > 0)
			{
				temp = url.substr(protocol.length);
			}
			else
			{
				temp = url;
			}
			
			var items:Array = temp.split("/");
			var index:int = items.indexOf("..");
			while (index >= 0)
			{
				items.splice(index - 1, 2);
				index = items.indexOf("..");
			}				
			
			ret = protocol;
			if (items.length > 0)
			{
				for (var i:int = 0; i < items.length; i++)
				{
					if (i != 0)
					{
						ret += "/";
					}
					ret += items[i] as String;
				}
			}
			
			return ret;
		}
		
		private static function generateDVRInfo(metadata:Metadata):DVRInfo
		{
			if (metadata == null)
			{
				return null;
			}
			
			var dvrInfo:DVRInfo = new DVRInfo();
			dvrInfo.id = "";
			dvrInfo.beginOffset = NaN;
			dvrInfo.endOffset = NaN;
			dvrInfo.windowDuration = NaN;
			dvrInfo.offline = false;
			if (metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_ID_KEY) != null)
			{
				dvrInfo.id = metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_ID_KEY) as String;
			}
			if (metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_BEGIN_OFFSET_KEY) != null)
			{
				dvrInfo.beginOffset = metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_BEGIN_OFFSET_KEY) as uint;
			}
			if (metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_END_OFFSET_KEY) != null)
			{
				dvrInfo.endOffset = metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_END_OFFSET_KEY) as uint;
			}
			if (metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_WINDOW_DURATION_KEY) != null)
			{
				dvrInfo.windowDuration = metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_WINDOW_DURATION_KEY) as int;
			}
			if (metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_OFFLINE_KEY) != null)
			{
				dvrInfo.offline = metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_OFFLINE_KEY) as Boolean;
			}
			
			return dvrInfo;
		}
		
		private static function generateStreamInfos(resource:URLResource):Vector.<HTTPStreamingF4FStreamInfo>
		{
			var streamInfos:Vector.<HTTPStreamingF4FStreamInfo> = new Vector.<HTTPStreamingF4FStreamInfo>();
			
			var drmMetadata:Metadata 
				= resource.getMetadataValue(MetadataNamespaces.DRM_METADATA) as Metadata;
			var httpMetadata:Metadata
				= resource.getMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA) as Metadata;
			var additionalHeader:ByteArray = null;
			var bootstrap:BootstrapInfo = null;
			var dsResource:DynamicStreamingResource = resource as DynamicStreamingResource;
			var streamMetadata:Object;
			var xmpMetadata:ByteArray;
			if (dsResource != null)
			{
				for each (var streamItem:DynamicStreamingItem in dsResource.streamItems)
				{
					additionalHeader = null;
					bootstrap = null;
					streamMetadata = null;
					xmpMetadata = null;
					
					if (drmMetadata != null)
					{
						additionalHeader = drmMetadata.getValue(
							MetadataNamespaces.DRM_ADDITIONAL_HEADER_KEY + streamItem.streamName) as ByteArray;
					}
					if (httpMetadata != null)
					{
						bootstrap = httpMetadata.getValue(
							MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY + streamItem.streamName) as BootstrapInfo;
						streamMetadata = httpMetadata.getValue(
							MetadataNamespaces.HTTP_STREAMING_STREAM_METADATA_KEY + streamItem.streamName);
						xmpMetadata = httpMetadata.getValue(
							MetadataNamespaces.HTTP_STREAMING_XMP_METADATA_KEY + streamItem.streamName) as ByteArray;
					}
					streamInfos.push(new HTTPStreamingF4FStreamInfo(
						bootstrap, streamItem.streamName, streamItem.bitrate, additionalHeader, streamMetadata, xmpMetadata));
				}
			}
			else
			{
				if (drmMetadata != null)
				{
					additionalHeader 
						= drmMetadata.getValue(MetadataNamespaces.DRM_ADDITIONAL_HEADER_KEY) as ByteArray;
				}
				if (httpMetadata != null)
				{
					bootstrap = httpMetadata.getValue(
						MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY) as BootstrapInfo;
					streamMetadata = httpMetadata.getValue(
						MetadataNamespaces.HTTP_STREAMING_STREAM_METADATA_KEY);
					xmpMetadata = httpMetadata.getValue(
						MetadataNamespaces.HTTP_STREAMING_XMP_METADATA_KEY) as ByteArray;
				}
				
				var streamName:String = resource.url;
				streamInfos.push(new HTTPStreamingF4FStreamInfo(bootstrap, streamName, NaN, additionalHeader, streamMetadata, xmpMetadata));
			}
			
			return streamInfos;
		}
	}
}