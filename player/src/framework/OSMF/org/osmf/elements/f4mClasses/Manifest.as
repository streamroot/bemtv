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
	import __AS3__.vec.Vector;
	
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
		
	[ExcludeClass]
	
	/**
	 * @private
	 */ 
	public class Manifest
	{			
		/**
		 * The id element represents a unique identifier for the media. It is optional.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public var id:String;
		
		/**
		 * The label element represents a user-friendly description for the media. It is optional.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public var label:String;

		/**
		 * The lang element represents a language code identifier for the media. It is optional.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public var lang:String;

		/**
		 * The &lt;baseURL&gt; element contains the base URL for all relative (HTTP-based) URLs 
		 * in the manifest. It is optional. When specified, its value is prepended to all 
		 * relative URLs (i.e. those URLs that don't begin with "http://" or "https://" 
		 * within the manifest file. (Such URLs may include &lt;media&gt; URLs, &lt;bootstrapInfo&gt; 
		 * URLs, and &lt;drmMetadata&gt; URLs.) 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var baseURL:String;
				
		/**
		 * Indicate whether the media URL includes FMS application instance. This is only applicable to RTMP URLs.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var urlIncludesFMSApplicationInstance:Boolean = false;

		/**
		 * The &lt;duration&gt; element represents the duration of the media, in seconds. 
		 * It is assumed that all representations of the media have the same duration, 
		 * hence its placement under the document root. It is optional.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var duration:Number;
		
		/**
		 * The &lt;mimeType&gt; element represents the MIME type of the media file. It is assumed 
		 * that all representations of the media have the same MIME type, hence its 
		 * placement under the document root. It is optional.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var mimeType:String;
		
		/**
		 * The &lt;streamType&gt; element is a string representing the way in which the media is streamed.
		 * Valid values include "live", "recorded", and "liveOrRecorded". It is assumed that all representations 
		 * of the media have the same stream type, hence its placement under the document root. 
		 * It is optional.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public var streamType:String;
			
		/**
		 * Indicates the means by which content is delivered to the player.  Valid values include 
		 * "streaming" and "progressive". It is optional. If unspecified, then the delivery 
		 * type is inferred from the media protocol. For media with an RTMP protocol, 
		 * the default deliveryType is "streaming". For media with an HTTP protocol, the default 
		 * deliveryType is also "streaming". In the latter case, the &lt;bootstrapInfo&gt; field must be 
		 * present.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var deliveryType:String;
		
		/**
		 * Represents the date/time at which the media was first (or will first be) made available. 
		 * It is assumed that all representations of the media have the same start time, hence its 
		 * placement under the document root. The start time must conform to the "date-time" production 
		 * in RFC3339. It is optional.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var startTime:Date;
		
		/**
		 * The set of different bootstrap information objects associated with this manifest.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var bootstrapInfos:Vector.<BootstrapInfo> = new Vector.<BootstrapInfo>();
			
		/**
		 * The set of different |AddionalHeader objects associated with this manifest.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var drmAdditionalHeaders:Vector.<DRMAdditionalHeader> = new Vector.<DRMAdditionalHeader>();

		/**
		 * The set of different bitrate streams associated with this media.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var media:Vector.<Media> = new Vector.<Media>();

		/**
		 * The set of alternative streams associated with this media.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var alternativeMedia:Vector.<Media> = new Vector.<Media>();
		
		/**
		 * The dvrInfo element. It is needed to play DVR media.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var dvrInfo:DVRInfo = null;
	}
}