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
package org.osmf.metadata
{
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Contains the static constants for metadata namespaces used within OSMF.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public final class MetadataNamespaces
	{
		// Internal OSMF Namespaces
		//

		/**
		 * @private
		 **/
		public static const MEDIA_ELEMENT_METADATA:String				= "http://www.osmf.org/mediaElement/1.0";

		/**
		 * @private
		 **/
		public static const DERIVED_RESOURCE_METADATA:String			= "http://www.osmf.org/derivedResource/1.0";

		/**
		 * @private
		 **/
		public static const FMS_SERVER_VERSION_METADATA:String			= "http://www.osmf.org/fmsServerVersion/1.0";

		/**
		 * @private
		 * 
		 * Used by the layout system to log individual IDs of regions.  For debugging only.
		 **/
		public static const ELEMENT_ID:String	 						= "http://www.osmf.org/layout/elementId/1.0";

		/**
		 * @private
		 **/
		public static const LAYOUT_RENDERER_TYPE:String					= "http://www.osmf.org/layout/renderer_type/1.0";

		/**
		 * @private
		 **/
		public static const ABSOLUTE_LAYOUT_PARAMETERS:String			= "http://www.osmf.org/layout/absolute/1.0";

		/**
		 * @private
		 **/
		public static const RELATIVE_LAYOUT_PARAMETERS:String			= "http://www.osmf.org/layout/relative/1.0";

		/**
		 * @private
		 **/
		public static const ANCHOR_LAYOUT_PARAMETERS:String				= "http://www.osmf.org/layout/anchor/1.0";

		/**
		 * @private
		 **/
		public static const PADDING_LAYOUT_PARAMETERS:String 			= "http://www.osmf.org/layout/padding/1.0";

		/**
		 * @private
		 **/
		public static const LAYOUT_ATTRIBUTES:String 					= "http://www.osmf.org/layout/attributes/1.0";

		/**
		 * @private
		 **/
		public static const OVERLAY_LAYOUT_PARAMETERS:String 			= "http://www.osmf.org/layout/overlay/1.0";

		/**
		 * @private
		 **/
		public static const BOX_LAYOUT_ATTRIBUTES:String				= "http://www.osmf.org/layout/attributes/box/1.0";
		
		/**
		 * @private
		 **/
		public static const DRM_METADATA:String							= "http://www.osmf.org/drm/1.0";
		
		/**
		 * @private
		 **/
		public static const MULTICAST_INFO:String						= "http://www.osmf.org/multicast/info/1.0";
		
		/**
		 * @private
		 **/
		public static const MULTICAST_NET_LOADER:String						= "http://www.osmf.org/multicast/netloader/1.0";

		/**
		 * @private
		 **/
		public static const DVR_METADATA:String							= "http://www.osmf.org/dvr/1.0";

		/**
		 * @private
		 **/
		public static const DRM_ADDITIONAL_HEADER_KEY:String			= "DRMAdditionalHeader";

		/**
		 * @private
		 **/
		public static const HTTP_STREAMING_METADATA:String				= "http://www.osmf.org/httpstreaming/1.0";
		
		/**
		 * @private
		 **/
		public static const HTTP_STREAMING_BOOTSTRAP_KEY:String			= "bootstrap";

		/**
		 * @private
		 **/
		public static const HTTP_STREAMING_STREAM_METADATA_KEY:String 	= "streamMetadata";

		/**
		 * @private
		 **/
		public static const HTTP_STREAMING_XMP_METADATA_KEY:String 		= "xmpMetadata";

		/**
		 * @private
		 **/
		public static const HTTP_STREAMING_SERVER_BASE_URLS_KEY:String 	= "serverBaseUrls";

		/**
		 * @private
		 **/
		public static const HTTP_STREAMING_DVR_BEGIN_OFFSET_KEY:String 		= "beginOffset";

		/**
		 * @private
		 **/
		public static const HTTP_STREAMING_DVR_END_OFFSET_KEY:String 		= "endOffset";

		/**
		 * @private
		 **/
		public static const HTTP_STREAMING_DVR_WINDOW_DURATION_KEY:String 		= "windowDuration";

		/**
		 * @private
		 **/
		public static const HTTP_STREAMING_DVR_OFFLINE_KEY:String 			= "dvrOffline";

		/**
		 * @private
		 **/
		public static const HTTP_STREAMING_DVR_ID_KEY:String 					= "dvrId";
	}
}
