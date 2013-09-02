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
	import __AS3__.vec.Vector;
	
	import flash.utils.ByteArray;
	
	import org.osmf.media.URLResource;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * StreamingURLResource is a URLResource which is capable of being
	 * streamed.  It exposes some additional properties which are specific
	 * to streaming media.
	 * 
	 * <p>Note that it is possible for live and recorded streams to have
	 * identical URLs.  In such a case, the streamType property should be
	 * used to disambiguate live and recorded streams.</p>
	 * 
	 * @includeExample StreamingURLResourceExample.as -noswf
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class StreamingURLResource extends URLResource
	{
		/**
		 * Constructor.
		 * 
		 * @param url The URL of the resource. For details about how to format this
		 * URL for flv, mp4, and other file formats, see the Adobe® Flash® Media Server
		 * documentation link below.
		 * @see http://www.adobe.com/go/learn_OSMF_fms_url_format_en
		 * @param streamType The type of the stream. If null, defaults to
		 * StreamType.RECORDED.
		 * @param subclipStartTime Optional start time of the streaming
		 * resource.  When specified, the stream will be presented as a
		 * subclip, with playback beginning at the specified start time.
		 * @param subclipEndTime Optional end time of the streaming resource.
		 * When specified, the stream will be presented as a subclip, with
		 * playback ending at the specified end time.
		 * @param connectionArguments Optional set of arguments that will be
		 * supplied to NetConnection.connect when establishing a connection
		 * to the source of the stream.
		 * @param urlIncludesFMSApplicationInstance Indicates, for RTMP streaming
		 * URLs, whether the URL includes the FMS application instance or not.  If
		 * true, then the second part of the URL path is considered the instance
		 * name, such as <code>rtmp://host/app/foo/bar/stream</code>. In this case
		 * the instance name would be 'foo' and the stream would be 'bar/stream'.
		 * If false, then the second part of the URL path is considered to be the
		 * stream name, such as <code>rtmp://host/app/foo/bar/stream</code>. In this
		 * case there is no instance name and the stream would be 'foo/bar/stream'.
		 * The default is false.
		 * @param drmContentData Content metadata for DRM-encrypted content.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function StreamingURLResource
							( url:String
							, streamType:String = null
							, clipStartTime:Number = NaN
							, clipEndTime:Number = NaN
							, connectionArguments:Vector.<Object> = null
							, urlIncludesFMSApplicationInstance:Boolean = false
							, drmContentData:ByteArray = null							 
							)
		{
			_streamType = streamType || StreamType.RECORDED;
			_clipStartTime = clipStartTime;
			_clipEndTime = clipEndTime;
			_urlIncludesFMSApplicationInstance = urlIncludesFMSApplicationInstance;
			_drmContentData = drmContentData;
			
			_connectionArguments = connectionArguments;
			
			super(url);
		}

		/**
         * <p>The StreamType for this resource. The default value is <code>StreamType.RECORDED</code>.
		 * The StreamType class enumerates the valid stream types.</p>
		 * <p/>
         * <p>This property may return the following string values:</p> 
		 * <table class="innertable" width="640">
		 *   <tr>
		 *     <th>String value</th>
		 *     <th>Description</th>
		 *   </tr>
		 *   <tr>
		 * 	<td><code>StreamType.LIVE_OR_RECORDED</code></td>
		 * 	<td>The StreamingURLResource represents either a live or a recorded stream.</td>
		 *   </tr>
		 *   <tr>
		 * 	<td><code>StreamType.LIVE</code></td>
		 * 	<td>The StreamingURLResource represents a live stream.</td>
		 *   </tr>
		 *   <tr>
		 * 	<td><code>StreamType.RECORDED</code></td>
		 * 	<td>The StreamingURLResource represents a recorded stream.</td>
		 *   </tr>
		 *   <tr>
		 * 	<td><code>StreamType.DVR</code></td>
		 * 	<td>The StreamingURLResource represents a DVR stream.</td>
		 *   </tr>
		 * </table>
		 * 
		 * @see StreamType
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get streamType():String
		{
			return _streamType;
		}
		
		public function set streamType(value:String):void
		{
			_streamType = value;
		}
		
		/**
		 * Optional start time of the streaming resource.  When specified,
		 * the stream will be presented as a subclip, with playback beginning
		 * at the specified start time.  Note that clipStartTime is not
		 * currently supported for progressive videos.  The default is NaN,
		 * which is to start at the beginning.
		 **/ 
		public function get clipStartTime():Number
		{
			return _clipStartTime;
		}

		public function set clipStartTime(value:Number):void
		{
			_clipStartTime = value;
		}

		/**
		 * Optional end time of the streaming resource.  When specified,
		 * the stream will be presented as a subclip, with playback ending
		 * at the specified end time.  Note that clipEndTime is not
		 * currently supported for progressive videos.  The default is NaN,
		 * which is to play to the end.
		 **/ 
		public function get clipEndTime():Number
		{
			return _clipEndTime;
		}

		public function set clipEndTime(value:Number):void
		{
			_clipEndTime = value;
		}
		
		/**
		 * Optional set of arguments that will be supplied when making a
		 * connection to the source of the stream.
		 **/
		public function get connectionArguments():Vector.<Object>
		{
			return _connectionArguments;
		}

		public function set connectionArguments(value:Vector.<Object>):void
		{
			_connectionArguments = value;
		}
		
		/**
		 * Content metadata for DRM-encrypted content.
		 **/ 
		public function get drmContentData():ByteArray
		{
			return _drmContentData;
		}

		public function set drmContentData(value:ByteArray):void
		{
			_drmContentData = value;
		}

		/**
		 * Indicates, for RTMP streaming URLs, whether the URL includes the FMS
		 * application instance or not.  If true, then the second part of the URL
		 * path is considered the instance name, such as <code>rtmp://host/app/foo/bar/stream</code>.
		 * In this case the instance name would be 'foo' and the stream would be 'bar/stream'.
		 * If false, then the second part of the URL path is considered to be the
		 * stream name, such as <code>rtmp://host/app/foo/bar/stream</code>. In this
		 * case there is no instance name and the stream would be 'foo/bar/stream'.
		 * The default is false.
		 **/
		public function get urlIncludesFMSApplicationInstance():Boolean
		{
			return _urlIncludesFMSApplicationInstance;
		}
		
		public function set urlIncludesFMSApplicationInstance(value:Boolean):void
		{
			_urlIncludesFMSApplicationInstance = value;
		}
		
		/**
		 * Vector containing all alternative audio items associated with
		 * the current streaming resource. 
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		public function get alternativeAudioStreamItems():Vector.<StreamingItem>
		{
			if (_alternativeAudioStreamItems == null)
			{
				_alternativeAudioStreamItems = new Vector.<StreamingItem>();
			}
			return _alternativeAudioStreamItems;
		}
		public function set alternativeAudioStreamItems(value:Vector.<StreamingItem>):void
		{
			_alternativeAudioStreamItems = value;
		}
		
		/// Internals
		private var _streamType:String; // StreamType
		private var _clipStartTime:Number;
		private var _clipEndTime:Number;
		private var _connectionArguments:Vector.<Object>;
		private var _drmContentData:ByteArray;
		private var _urlIncludesFMSApplicationInstance:Boolean = false;

		private var _alternativeAudioStreamItems:Vector.<StreamingItem> = null;
	}
}
