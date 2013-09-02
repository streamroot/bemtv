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

package org.osmf.player.chrome.utils
{
	import flash.net.URLRequest;
	import flash.net.URLStream;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.player.metadata.ResourceMetadata;

	/**
	 * MediaElement utility functions 
	 */ 
	public class MediaElementUtils
	{
		/**
		 * Returns the top MediaElement by traversing the proxiedElement parent chain.
		 */ 		
		public static function getMediaElementParentOfType(media:MediaElement, type:Class):MediaElement
		{
			if (media is type)
			{
				return  media;
			}  				
			else if (media.hasOwnProperty("proxiedElement") && (media["proxiedElement"] != null))
			{	
				// WORARROUND: Use duck-typing since we need to check both
				// ProxyElement and ProxyElementEx which expose proxiedElement property.
				return getMediaElementParentOfType(media["proxiedElement"], type);
			}			
			return null;
		}
		
		/**
		 * Returns the highest level Resource of a Specific type by traversing the proxiedElement parent chain.
		 */ 		
		public static function getResourceFromParentOfType(media:MediaElement, type:Class):MediaResourceBase
		{
			// If the current element is a proxy element, go up
			var result:MediaResourceBase = null;
			if (media.hasOwnProperty("proxiedElement") && (media["proxiedElement"] != null))
			{				
				result = getResourceFromParentOfType(media["proxiedElement"], type);
			}			
			
			// If we didn't get any result from a higher level proxy
			// and the current media is of the needed type, return it.
			if (result == null && media.resource is type)
			{
				result = media.resource;
			}
			
			return result;
		}
		
		public static function getStreamType(media:MediaElement):String
		{
			if (media == null)
			{
				return null;
			}
			
			var streamingURLResource:StreamingURLResource = getResourceFromParentOfType(media, StreamingURLResource) as StreamingURLResource;			
			if (streamingURLResource != null)
			{
				return streamingURLResource.streamType;						
			}
			return null;			
		}
		
		/**
		 * Collects the metadata from the proxy chain. 
		 * Resource fields that are found higher in the proxy chain overwrite the ones
		 * found lower. 
		 */ 
		public static function collectResourceMetadata(mediaElement:MediaElement, resourceMetadata:ResourceMetadata):void
		{
			if (mediaElement == null) 
			{
				return;
			}
			
			var resource:MediaResourceBase = mediaElement.resource;
			if (resource is URLResource)
			{
				resourceMetadata.url = (resource as URLResource).url;
			}
			
			if (resource is StreamingURLResource)
			{
				resourceMetadata.streamType = (resource as StreamingURLResource).streamType;
			}
			
			if (resource is DynamicStreamingResource)
			{
				resourceMetadata.host = (resource as DynamicStreamingResource).host;
				resourceMetadata.streamItems = (resource as DynamicStreamingResource).streamItems;
				resourceMetadata.initialIndex = (resource as DynamicStreamingResource).initialIndex;
			}
			
			if (mediaElement is ProxyElement)
			{				
				collectResourceMetadata((mediaElement as ProxyElement).proxiedElement, resourceMetadata);
			}	
		}
	}
}