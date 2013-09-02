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
package org.osmf.elements.f4mClasses
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.utils.ByteArray;
	
	import org.osmf.events.ParseEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.MediaType;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.MulticastResource;
	import org.osmf.net.NetStreamUtils;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingItem;
	import org.osmf.net.StreamingItemType;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.net.StreamingXMLResource;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.utils.URL;

	[ExcludeClass]

	[Event(name="parseComplete", type="org.osmf.events.ParseEvent")]
	[Event(name="parseError", type="org.osmf.events.ParseEvent")]

	/**
	 * @private
	 **/
	public class ManifestParser extends EventDispatcher
	{
		/**
		 * Constructor.
		 */
		public function ManifestParser()
		{
			mediaParser = buildMediaParser();
			mediaParser.addEventListener(ParseEvent.PARSE_COMPLETE, onMediaLoadComplete, false, 0, true);
			mediaParser.addEventListener(ParseEvent.PARSE_ERROR, onAdditionalLoadError, false, 0, true);

			dvrInfoParser = buildDVRInfoParser();
			dvrInfoParser.addEventListener(ParseEvent.PARSE_COMPLETE, onDVRInfoLoadComplete, false, 0, true);
			dvrInfoParser.addEventListener(ParseEvent.PARSE_ERROR, onAdditionalLoadError, false, 0, true);

			drmAdditionalHeaderParser = buildDRMAdditionalHeaderParser();
			drmAdditionalHeaderParser.addEventListener(ParseEvent.PARSE_COMPLETE, onDRMAdditionalHeaderLoadComplete, false, 0, true);
			drmAdditionalHeaderParser.addEventListener(ParseEvent.PARSE_ERROR, onAdditionalLoadError, false, 0, true);

			bootstrapInfoParser = buildBootstrapInfoParser();
			bootstrapInfoParser.addEventListener(ParseEvent.PARSE_COMPLETE, onBootstrapInfoLoadComplete, false, 0, true);
			bootstrapInfoParser.addEventListener(ParseEvent.PARSE_ERROR, onAdditionalLoadError, false, 0, true);
		}

		/**
		 * Parses an F4M file.
		 *
		 * @param value The string xml of the F4M file.
		 * @param rootURL The rootURL of the resource.
		 * @param manifest The existing <code>Manifest</code> object to append to.
		 * 				   If not specified, a new <code>Manifest</code> is created.
		 */
		public function parse(value:String, rootURL:String = null, manifest:Manifest = null, idPrefix:String = ""):void
		{
			if (!value)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_VALUE_MISSING));
			}

			parsing = true;

			// If we weren't passed a manifest we need to build one.
			// Otherwise we'll use the one that was passed in and add to it.
			if (!manifest)
			{
				manifest = new Manifest();
			}

			// Now use whatever manifest we end up with.
			this.manifest = manifest;

			isMulticast = false;
			bitrateMissing = false;

			var root:XML = new XML(value);
			var nmsp:Namespace = root.namespace();

			if (root.nmsp::id.length() > 0)
			{
				manifest.id = root.nmsp::id.text();
			}

			if (root.nmsp::label.length() > 0)
			{
				manifest.label = root.nmsp::label.text();
			}

			if (root.nmsp::lang.length() > 0)
			{
				manifest.lang = root.nmsp::lang.text();
			}

			if (root.nmsp::duration.length() > 0)
			{
				manifest.duration = root.nmsp::duration.text();
			}

			if (root.nmsp::startTime.length() > 0)
			{
				manifest.startTime = DateUtil.parseW3CDTF(root.nmsp::startTime.text());
			}

			if (root.nmsp::mimeType.length() > 0)
			{
				manifest.mimeType = root.nmsp::mimeType.text();
			}

			if (root.nmsp::streamType.length() > 0)
			{
				manifest.streamType = root.nmsp::streamType.text();
			}

			if (root.nmsp::deliveryType.length() > 0)
			{
				manifest.deliveryType = root.nmsp::deliveryType.text();
			}

			if (root.nmsp::baseURL.length() > 0)
			{
				manifest.baseURL = root.nmsp::baseURL.text();
			}

			if (root.nmsp::urlIncludesFMSApplicationInstance.length() > 0)
			{
				manifest.urlIncludesFMSApplicationInstance = (root.nmsp::urlIncludesFMSApplicationInstance.text() == "true");
			}

			var baseURL:String = (manifest.baseURL != null) ? manifest.baseURL : rootURL;
			baseURL = URL.normalizeRootURL(baseURL);
			
			
			// DVRInfo
			for each (var dvrInfo:XML in root.nmsp::dvrInfo)
			{
				unfinishedLoads++;
				parseDVRInfo(dvrInfo, baseURL);
				break;
			}

			// Media	
			for each (var media:XML in root.nmsp::media)
			{
				unfinishedLoads++;
				parseMedia(media, baseURL, idPrefix);
			}

			// DRM Metadata	
			for each (var data:XML in root.nmsp::drmAdditionalHeader)
			{
				unfinishedLoads++;
				parseDRMAdditionalHeader(data, baseURL, idPrefix);
			}

			// Bootstrap
			bootstraps = new Vector.<BootstrapInfo>();
			for each (var info:XML in root.nmsp::bootstrapInfo)
			{
				unfinishedLoads++;
				parseBootstrapInfo(info, baseURL, idPrefix);
			}

			// Required if base URL is omitted from Manifest
			generateRTMPBaseURL(manifest);

			parsing = false;

			finishLoad(manifest);
		}

		/**
		 * Creates a <code>MediaResourceBase</code>.
		 *
		 * @param value
		 * @param manifestResource
		 * @return
		 */
		public function createResource(value:Manifest, manifestResource:MediaResourceBase):MediaResourceBase
		{
			var drmMetadata:Metadata = null;
			var httpMetadata:Metadata = null;
			var resource:StreamingURLResource;
			var media:Media;
			var serverBaseURLs:Vector.<String>;
			var url:String;
			var bootstrapInfoURLString:String;

			var manifestURL:URL;
			if (manifestResource is URLResource)
			{
				manifestURL = new URL((manifestResource as URLResource).url);
			}
			else
			{
				if (manifestResource is StreamingXMLResource)
				{
					manifestURL = new URL((manifestResource as StreamingXMLResource).url);
				}
			}
			var cleanedPath:String = "/" + manifestURL.path;
			cleanedPath = cleanedPath.substr(0, cleanedPath.lastIndexOf("/"));
			var manifestFolder:String = manifestURL.protocol + "://" + manifestURL.host + (manifestURL.port != "" ? ":" + manifestURL.port : "") + cleanedPath;

			// Single Stream/Progressive Resource
			if (value.media.length == 1)
			{
				media = value.media[0] as Media;
				url = media.url;

				var baseURLString:String = null;
				if (URL.isAbsoluteURL(url))
				{
					// The server base URL needs to be extracted from the media's
					// URL.  Note that we assume it's the same for all media.
					baseURLString = media.url.substr(0, media.url.lastIndexOf("/"));
				}
				else if (value.baseURL != null)
				{
					baseURLString = value.baseURL;
				}
				else
				{
					baseURLString = manifestFolder;
				}
				baseURLString = URL.normalizeRootURL(baseURLString);

				if (media.multicastGroupspec != null && media.multicastGroupspec.length > 0 && media.multicastStreamName != null && media.multicastStreamName.length > 0)
				{
					if (URL.isAbsoluteURL(url))
					{
						resource = new MulticastResource(url, streamType(value));
					}
					// Relative to Base URL
					else if (value.baseURL != null)
					{
						resource = new MulticastResource(URL.normalizeRootURL(value.baseURL) + URL.normalizeRelativeURL(url), streamType(value));
					}
					// Relative to F4M file  (no absolute or base urls or rtmp urls).
					else
					{
						resource = new MulticastResource(URL.normalizeRootURL(manifestFolder) + URL.normalizeRelativeURL(url), streamType(value));
					}
					MulticastResource(resource).groupspec = media.multicastGroupspec;
					MulticastResource(resource).streamName = media.multicastStreamName;
				}
				else if (URL.isAbsoluteURL(url))
				{
					resource = new StreamingURLResource(url, streamType(value));
				}
				// Relative to Base URL
				else if (value.baseURL != null)
				{
					resource = new StreamingURLResource(URL.normalizeRootURL(value.baseURL) + URL.normalizeRelativeURL(url), streamType(value));
				}
				// Relative to F4M file  (no absolute or base urls or rtmp urls).
				else
				{
					resource = new StreamingURLResource(URL.normalizeRootURL(manifestFolder) + URL.normalizeRelativeURL(url), streamType(value));
				}

				resource.urlIncludesFMSApplicationInstance = value.urlIncludesFMSApplicationInstance;

				if (media.bootstrapInfo != null)
				{
					serverBaseURLs = new Vector.<String>();
					serverBaseURLs.push(baseURLString);

					bootstrapInfoURLString = media.bootstrapInfo.url;
					if (media.bootstrapInfo.url != null && URL.isAbsoluteURL(media.bootstrapInfo.url) == false)
					{
						bootstrapInfoURLString = URL.normalizeRootURL(manifestFolder) + URL.normalizeRelativeURL(bootstrapInfoURLString);
						media.bootstrapInfo.url = bootstrapInfoURLString;
					}
					httpMetadata = new Metadata();
					httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY, media.bootstrapInfo);
					if (serverBaseURLs.length > 0)
					{
						httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_SERVER_BASE_URLS_KEY, serverBaseURLs);
					}
				}

				if (media.metadata != null)
				{
					if (httpMetadata == null)
					{
						httpMetadata = new Metadata();
					}
					httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_STREAM_METADATA_KEY, media.metadata);
				}

				if (media.xmp != null)
				{
					if (httpMetadata == null)
					{
						httpMetadata = new Metadata();
					}
					httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_XMP_METADATA_KEY, media.xmp);
				}

				if (media.drmAdditionalHeader != null)
				{
					drmMetadata = new Metadata();
					if (Media(value.media[0]).drmAdditionalHeader != null && Media(value.media[0]).drmAdditionalHeader.data != null)
					{
						drmMetadata.addValue(MetadataNamespaces.DRM_ADDITIONAL_HEADER_KEY, Media(value.media[0]).drmAdditionalHeader.data);

						resource.drmContentData = extractDRMMetadata(Media(value.media[0]).drmAdditionalHeader.data);
					}
				}

				if (httpMetadata != null)
				{
					resource.addMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA, httpMetadata);
				}
				if (drmMetadata != null)
				{
					resource.addMetadataValue(MetadataNamespaces.DRM_METADATA, drmMetadata);
				}
			}
			// Dynamic Streaming
			else if (value.media.length > 1)
			{
				var baseURL:String = value.baseURL != null ? value.baseURL : manifestFolder;
				baseURL = URL.normalizeRootURL(baseURL);
				serverBaseURLs = new Vector.<String>();
				serverBaseURLs.push(baseURL);

				// TODO: MBR streams can be absolute (with no baseURL) or relative (with a baseURL).
				// But we need to map them into the DynamicStreamingResource object model, which
				// assumes the latter.  For now, we only support the latter input, but we should
				// add support for the former (absolute URLs with no base URL).
				var dynResource:DynamicStreamingResource = new DynamicStreamingResource(baseURL, streamType(value));
				dynResource.urlIncludesFMSApplicationInstance = value.urlIncludesFMSApplicationInstance;

				var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();

				// Only put this on HTTPStreaming, not RTMPStreaming resources.   RTMP resources always get a generated base url.
				if (NetStreamUtils.isRTMPStream(baseURL) == false)
				{
					httpMetadata = new Metadata();
					dynResource.addMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA, httpMetadata);
					httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_SERVER_BASE_URLS_KEY, serverBaseURLs);
				}

				for each (media in value.media)
				{
					var stream:String;

					if (URL.isAbsoluteURL(media.url))
					{
						stream = NetStreamUtils.getStreamNameFromURL(media.url);
					}
					else
					{
						stream = media.url;
					}
					var item:DynamicStreamingItem = new DynamicStreamingItem(stream, media.bitrate, media.width, media.height);
					streamItems.push(item);
					if (media.drmAdditionalHeader != null)
					{
						if (dynResource.getMetadataValue(MetadataNamespaces.DRM_METADATA) == null)
						{
							drmMetadata = new Metadata();
							dynResource.addMetadataValue(MetadataNamespaces.DRM_METADATA, drmMetadata);
						}
						if (media.drmAdditionalHeader != null && media.drmAdditionalHeader.data != null)
						{
							drmMetadata.addValue(item.streamName, extractDRMMetadata(media.drmAdditionalHeader.data));
							drmMetadata.addValue(MetadataNamespaces.DRM_ADDITIONAL_HEADER_KEY + item.streamName, media.drmAdditionalHeader.data);
						}
					}

					if (media.bootstrapInfo != null)
					{
						bootstrapInfoURLString = media.bootstrapInfo.url ? media.bootstrapInfo.url : null;
						if (media.bootstrapInfo.url != null && URL.isAbsoluteURL(media.bootstrapInfo.url) == false)
						{
							bootstrapInfoURLString = URL.normalizeRootURL(manifestFolder) + URL.normalizeRelativeURL(bootstrapInfoURLString);
							media.bootstrapInfo.url = bootstrapInfoURLString;
						}
						if (httpMetadata != null)
						{
							httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY + item.streamName, media.bootstrapInfo);
						}
					}

					if (media.metadata != null)
					{
						if (httpMetadata != null)
						{
							httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_STREAM_METADATA_KEY + item.streamName, media.metadata);
						}
					}

					if (media.xmp != null)
					{
						if (httpMetadata != null)
						{
							httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_XMP_METADATA_KEY + item.streamName, media.xmp);
						}
					}
				}

				dynResource.streamItems = streamItems;

				resource = dynResource;
			}
			else if (value.baseURL == null)
			{
				// This is a parse error, we need an rtmp url
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_MEDIA_URL_MISSING));
			}
			else if (value.media.length == 0)
			{
				// This is a parse error, we need at least one media tag
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_MEDIA_MISSING));
			}

			if (value.mimeType != null)
			{
				resource.mediaType = MediaType.VIDEO;
				resource.mimeType = value.mimeType;
			}

			if (manifestResource is URLResource)
			{
				// Add subclip info from original resource
				var streamingManifestResource:StreamingURLResource = manifestResource as StreamingURLResource;
				if (streamingManifestResource != null)
				{
					resource.clipStartTime = streamingManifestResource.clipStartTime;
					resource.clipEndTime = streamingManifestResource.clipEndTime;
				}
			}
			else
			{
				if (manifestResource is StreamingXMLResource)
				{
					var streamingXMLManifestResource:StreamingXMLResource = manifestResource as StreamingXMLResource;
					resource.clipStartTime = streamingXMLManifestResource.clipStartTime;
					resource.clipEndTime = streamingXMLManifestResource.clipEndTime;
				}
			}

			// Add metadata to the created resource specifying the resource from
			// which it was derived.  This allows interested clients to determine
			// the origins of the resource.
			resource.addMetadataValue(MetadataNamespaces.DERIVED_RESOURCE_METADATA, manifestResource);

			addDVRInfo(value, resource);

			// we add alternative media only for HTTP Streaming
			if (NetStreamUtils.isRTMPStream(baseURL) == false)
			{
				addAlternativeMedia(value, resource, manifestFolder);
			}

			// Clear out any bootstraps we've been holding onto since we don't need them anymore.
			bootstraps = null;

			return resource;
		}

		/**
		 * Builds a parser to use for media nodes.
		 *
		 * @return
		 *
		 * @private
		 * In protected scope so that subclasses can change the parser.
		 */
		protected function buildMediaParser():BaseParser
		{
			return new MediaParser();
		}

		/**
		 * Builds a parser to use for DVR info nodes.
		 *
		 * @return
		 *
		 * @private
		 * In protected scope so that subclasses can change the parser.
		 */
		protected function buildDVRInfoParser():BaseParser
		{
			return new DVRInfoParser();
		}

		/**
		 * Builds a parser to use for DRM header nodes.
		 *
		 * @return
		 *
		 * @private
		 * In protected scope so that subclasses can change the parser.
		 */
		protected function buildDRMAdditionalHeaderParser():BaseParser
		{
			return new DRMAdditionalHeaderParser();
		}

		/**
		 * Builds a parser to use for bootstrap info nodes.
		 *
		 * @return
		 *
		 * @private
		 * In protected scope so that subclasses can change the parser.
		 */
		protected function buildBootstrapInfoParser():BaseParser
		{
			return new BootstrapInfoParser();
		}

		/**
		 * Checks a manifest to be sure that it is valid.
		 *
		 * @param manifest
		 * @param isMulticast
		 * @param bitrateMissing
		 */
		protected function validateManifest(manifest:Manifest, isMulticast:Boolean, bitrateMissing:Boolean):void
		{
			if (manifest.media.length > 1 && isMulticast)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.MULTICAST_NOT_SUPPORT_MBR));
			}

			if ((manifest.media.length + manifest.alternativeMedia.length) > 1 && bitrateMissing)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_BITRATE_MISSING));
			}

			if (isMulticast)
			{
				manifest.streamType = StreamType.LIVE;
			}
		}

		/**
		 * Completes the loading process.
		 *
		 * @param manifest
		 */
		protected function finishLoad(manifest:Manifest):void
		{
			if (parsing)
			{
				return;
			}

			if (unfinishedLoads > 0)
			{
				return;
			}

			if (!manifest)
			{
				return;
			}

			validateManifest(manifest, isMulticast, bitrateMissing);
			dispatchEvent(new ParseEvent(ParseEvent.PARSE_COMPLETE, false, false, manifest));
		}

		private function parseMedia(value:XML, baseURL:String, idPrefix:String = ""):void
		{
			mediaParser.parse(value.toXMLString(), baseURL, idPrefix);
		}

		private function parseDVRInfo(value:XML, baseURL:String):void
		{
			dvrInfoParser.parse(value.toXMLString(), baseURL);
		}

		private function parseDRMAdditionalHeader(value:XML, baseURL:String, idPrefix:String = ""):void
		{
			drmAdditionalHeaderParser.parse(value.toXMLString(), baseURL, idPrefix);
		}

		private function parseBootstrapInfo(value:XML, baseURL:String, idPrefix:String = ""):void
		{
			bootstrapInfoParser.parse(value.toXMLString(), baseURL, idPrefix);
		}

		/**
		 * @private
		 * Ensures that an RTMP based Manifest has the same server for all
		 * streaming items, and extracts the base URL from the streaming items
		 * if not specified.
		 */
		private function generateRTMPBaseURL(manifest:Manifest):void
		{
			if (manifest.baseURL == null)
			{
				for each (var media:Media in manifest.media)
				{
					if (NetStreamUtils.isRTMPStream(media.url))
					{
						manifest.baseURL = media.url;
						break;
					}
				}
			}
		}

		private function isSupportedType(type:String):Boolean
		{
			return (type == StreamingItemType.VIDEO || type == StreamingItemType.AUDIO);
		}

		private function extractDRMMetadata(data:ByteArray):ByteArray
		{
			var metadata:ByteArray = null;

			data.position = 0;
			data.objectEncoding = 0;

			try
			{
				var header:Object = data.readObject();
				var encryption:Object = data.readObject();
				var enc:Object = encryption["Encryption"];
				var params:Object = enc["Params"];
				var version:String = enc["Version"].toString();
				var keyInfo:Object = params["KeyInfo"];
				var keyInfoData:Object = null;
				
				switch(version)
				{
					case "2": // FAXS2 structure KeyInfo > FMRMS_METADATA > Metadata
						keyInfoData = keyInfo["FMRMS_METADATA"];
						break;
					
					case "3": // FAXS3 structure KeyInfo > Data > Metadata
						keyInfoData = keyInfo["Data"];
						break;
				}
				
				if (keyInfoData != null)
				{
					var drmMetadata:String = keyInfoData["Metadata"] as String;
					var decoder:Base64Decoder = new Base64Decoder();
					decoder.decode(drmMetadata);
					metadata = decoder.drain();
				}
			}
			catch (e:Error)
			{
				metadata = null;
			}

			return metadata;
		}

		private function addAlternativeMedia(manifest:Manifest, resource:StreamingURLResource, manifestFolder:String):void
		{
			if (manifest.alternativeMedia.length == 0)
			{
				return;
			}

			var httpMetadata:Metadata = resource.getMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA) as Metadata;
			if (httpMetadata == null)
			{
				httpMetadata = new Metadata();
				resource.addMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA, httpMetadata);
			}

			var drmMetadata:Metadata;
			var alternativeMediaItems:Vector.<StreamingItem> = new Vector.<StreamingItem>();
			for each (var media:Media in manifest.alternativeMedia)
			{
				var stream:String;

				if (URL.isAbsoluteURL(media.url))
				{
					stream = NetStreamUtils.getStreamNameFromURL(media.url);
				}
				else
				{
					stream = media.url;
				}

				var info:Object = new Object();
				info.label = media.label;
				info.language = media.language;
				var item:StreamingItem = new StreamingItem(media.type, stream, media.bitrate, info);
				alternativeMediaItems.push(item);

				if (media.drmAdditionalHeader != null)
				{
					if (resource.getMetadataValue(MetadataNamespaces.DRM_METADATA) == null)
					{
						drmMetadata = new Metadata();
						resource.addMetadataValue(MetadataNamespaces.DRM_METADATA, drmMetadata);
					}
					else
					{
						drmMetadata = resource.getMetadataValue(MetadataNamespaces.DRM_METADATA) as Metadata;
					}
					if (media.drmAdditionalHeader != null && media.drmAdditionalHeader.data != null)
					{
						drmMetadata.addValue(item.streamName, extractDRMMetadata(media.drmAdditionalHeader.data));
						drmMetadata.addValue(MetadataNamespaces.DRM_ADDITIONAL_HEADER_KEY + item.streamName, media.drmAdditionalHeader.data);
					}
				}

				if (media.bootstrapInfo != null)
				{
					var bootstrapInfoURLString:String = media.bootstrapInfo.url ? media.bootstrapInfo.url : null;
					if (media.bootstrapInfo.url != null && URL.isAbsoluteURL(media.bootstrapInfo.url) == false)
					{
						bootstrapInfoURLString = URL.normalizeRootURL(manifestFolder) + URL.normalizeRelativeURL(bootstrapInfoURLString);
						media.bootstrapInfo.url = bootstrapInfoURLString;
					}
					httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY + item.streamName, media.bootstrapInfo);
				}

				if (media.metadata != null)
				{
					httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_STREAM_METADATA_KEY + item.streamName, media.metadata);
				}

				if (media.xmp != null)
				{
					httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_XMP_METADATA_KEY + item.streamName, media.xmp);
				}
			}

			resource.alternativeAudioStreamItems = alternativeMediaItems;
		}

		private function addDVRInfo(manifest:Manifest, resource:StreamingURLResource):void
		{
			if (manifest.dvrInfo == null)
			{
				return;
			}

			var metadata:Metadata = new Metadata();
			metadata.addValue(MetadataNamespaces.HTTP_STREAMING_DVR_BEGIN_OFFSET_KEY, manifest.dvrInfo.beginOffset);
			metadata.addValue(MetadataNamespaces.HTTP_STREAMING_DVR_END_OFFSET_KEY, manifest.dvrInfo.endOffset);
			metadata.addValue(MetadataNamespaces.HTTP_STREAMING_DVR_WINDOW_DURATION_KEY, manifest.dvrInfo.windowDuration);
			metadata.addValue(MetadataNamespaces.HTTP_STREAMING_DVR_OFFLINE_KEY, manifest.dvrInfo.offline);
			metadata.addValue(MetadataNamespaces.HTTP_STREAMING_DVR_ID_KEY, manifest.dvrInfo.id);

			resource.addMetadataValue(MetadataNamespaces.DVR_METADATA, metadata);
		}

		private function streamType(value:Manifest):String
		{
			return (value.streamType == StreamType.LIVE && value.dvrInfo != null) ? StreamType.DVR : value.streamType;
		}

		private function onMediaLoadComplete(event:ParseEvent):void
		{
			var newMedia:Media = event.data as Media;

			if (newMedia)
			{
				if (newMedia.multicastGroupspec != null && newMedia.multicastGroupspec.length > 0)
				{
					isMulticast = true;
				}

				if (isSupportedType(newMedia.type))
				{
					if (newMedia.label == null)
					{
						newMedia.label = manifest.label;
					}
					if (newMedia.language == null)
					{
						newMedia.language = manifest.lang;
					}

					if (newMedia.alternate)
					{
						if (newMedia.type == StreamingItemType.AUDIO)
						{
							manifest.alternativeMedia.push(newMedia);
						}
					}
					else
					{
						manifest.media.push(newMedia);
					}
				}

				// Apply bootstrap if any exist.
				// This needs to be done just in case the media loads after the bootstraps.
				if (bootstraps && bootstraps.length > 0)
				{
					for each (var b:BootstrapInfo in bootstraps)
					{
						if (newMedia.bootstrapInfo == null)
						{
							newMedia.bootstrapInfo = b;
							break;
						}
						else if (newMedia.bootstrapInfo.id == b.id)
						{
							newMedia.bootstrapInfo = b;
							break;
						}
					}
				}

				bitrateMissing ||= isNaN(newMedia.bitrate);
			}

			onAdditionalLoadComplete(event);
		}

		private function onDVRInfoLoadComplete(event:ParseEvent):void
		{
			manifest.dvrInfo = event.data as DVRInfo;

			onAdditionalLoadComplete(event);
		}

		private function onDRMAdditionalHeaderLoadComplete(event:ParseEvent):void
		{
			var drmAdditionalHeader:DRMAdditionalHeader = event.data as DRMAdditionalHeader;

			manifest.drmAdditionalHeaders.push(drmAdditionalHeader);

			var allMedia:Vector.<Media> = manifest.media.concat(manifest.alternativeMedia);
			var m:Media;
			for each (m in allMedia)
			{
				if (m.drmAdditionalHeader != null && m.drmAdditionalHeader.id == drmAdditionalHeader.id)
				{
					m.drmAdditionalHeader = drmAdditionalHeader;
				}
			}

			onAdditionalLoadComplete(event);
		}

		private function onBootstrapInfoLoadComplete(event:ParseEvent):void
		{
			var bootstrapInfo:BootstrapInfo = event.data as BootstrapInfo;

			// Store off the bootstraps just in case the media loads later.
			bootstraps.push(bootstrapInfo);

			// Apply the bootstraps to any media that currently exists.
			var allMedia:Vector.<Media> = manifest.media.concat(manifest.alternativeMedia);
			var m:Media;
			for each (m in allMedia)
			{
				//No per media bootstrap. Apply it to all items.
				if (m.bootstrapInfo == null)
				{
					m.bootstrapInfo = bootstrapInfo;
				}
				else if (m.bootstrapInfo.id == bootstrapInfo.id)
				{
					m.bootstrapInfo = bootstrapInfo;
				}
			}

			onAdditionalLoadComplete(event);
		}

		private function onAdditionalLoadComplete(event:Event):void
		{
			unfinishedLoads--;

			if (unfinishedLoads == 0 && !parsing)
			{
				finishLoad(manifest);
			}
		}

		private function onAdditionalLoadError(event:Event):void
		{
			dispatchEvent(new ParseEvent(ParseEvent.PARSE_ERROR));
		}

		private var parsing:Boolean = false;

		private var unfinishedLoads:Number = 0;

		private var isMulticast:Boolean;

		private var bitrateMissing:Boolean;

		private var mediaParser:BaseParser;

		private var dvrInfoParser:BaseParser;

		private var drmAdditionalHeaderParser:BaseParser;

		private var bootstrapInfoParser:BaseParser;

		private var bootstraps:Vector.<BootstrapInfo>;

		private var manifest:Manifest;
	}
}