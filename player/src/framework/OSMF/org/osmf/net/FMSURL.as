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
*  Contributor(s): Akamai Technologies
*  
*****************************************************/
package org.osmf.net
{
	import __AS3__.vec.Vector;
	
	import org.osmf.utils.URL;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Parses a URL into properties specific to Flash Media Server.
	 * 
	 * @see URL
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class FMSURL extends URL
	{						
		/**
		 * Set the URL this class will work with.
		 * 
		 * @param url The URL this class will use to provide FMS-specific information such as app name and instance name.
		 * @param useInstance If true, then the second part of the URL path is considered the instance name,
		 * such as <code>rtmp://host/app/foo/bar/stream</code>. In this case the instance name would be 'foo' and the stream would
		 * be 'bar/stream'.
		 * If false, then the second part of the URL path is considered to be the stream name, 
		 * such as <code>rtmp://host/app/foo/bar/stream</code>. In this case there is no instance name and the stream would 
		 * be 'foo/bar/stream'.
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function FMSURL(url:String, useInstance:Boolean=false)
		{
			super(url);
			_useInstance = useInstance;
			_appName = "";
			_instanceName = "";
			_streamName = "";
			_fileFormat = "";
			
			parsePath();
			parseQuery();
		}
		
		/**
		 * Whether a named instance is being used within the URI
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get useInstance():Boolean
		{
			return _useInstance;
		}
				
		/**
		 * The FMS application name.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get appName():String
		{
			return _appName;
		}
		
		/** 
		 * The FMS instance name.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get instanceName():String
		{
			return _instanceName;
		}
		
		/**
		 * The FMS stream name.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get streamName():String
		{
			return _streamName;
		}
		
		/**
		 * The file format of the streaming media.  Corresponds to one of the 
		 * public constants defined in this class, such as MP4_STREAM, 
		 * or the blank stream for flv media streams.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get fileFormat():String
		{
			return _fileFormat;
		}
		
		/**
		 * The vector of edges.
		 * 
		 * @see FMSHost
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get edges():Vector.<FMSHost>
		{
			return _edges;
		}
		
		/**
		 * The vector of origins.
		 * 
		 * @see FMSHost
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get origins():Vector.<FMSHost>
		{
			return _origins;
		}
				
		/** 
		 * Parse the path in the URL object into FMS specific properties.
		 * The path is everything after the host but before any query string parameters, with no leading or trailing slashes.
		 * <p> 
		 * For example, in this URL: <code>"http://host.com:80/foo/bar/index.html?a=1&#38;b=2"</code>
		 * path would be <code>"foo/bar/index.html"</code></p>		
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function parsePath():void
		{
			if ((path == null) || (path.length == 0)) 
			{
				// Check the query string for a stream name since the path is empty
				_streamName = getParamValue(QUERY_STRING_STREAM);
				// Check the query string for stream type since the path is empty
				_fileFormat = getParamValue(QUERY_STRING_STREAMTYPE);
				return;
			}

 			var pattern:RegExp = /(\/)/;
 			var result:Array = path.split(pattern);
 			
 			if (result != null)
 			{
	 			_appName = result[APPNAME_START_INDEX];
	 			_instanceName = "";
	 			_streamName = "";
	 			
	 			// If "_definst_" is in the path and in the right place, we'll assume everything after that is the stream
		 		var definstPattern:RegExp = new RegExp("^.*\/" + DEFAULT_INSTANCE_NAME, "i");  
		 			
	 			if (path.search(definstPattern) > -1)
	 			{
	 				_useInstance = true;
	 			}
	 			
	 			var streamStartNdx:uint = STREAMNAME_START_INDEX;

	 			if (_useInstance) 
	 			{
	 				_instanceName = result[INSTANCENAME_START_INDEX];
	 			}
	 			else
	 			{
	 				streamStartNdx = INSTANCENAME_START_INDEX;
	 			}
	 			
	 			for (var i:int = streamStartNdx; i < result.length; i++)
	 			{
	 				_streamName += result[i];
	 			}
	 			
	 			// If no streamName found in the path, check the query string
	 			if (_streamName == null || _streamName == "")
	 			{
					_streamName = getParamValue(QUERY_STRING_STREAM);
				}
	 			
	 			if (_streamName.search(/^mp4:/i) > -1)
	 			{
	 				_fileFormat = MP4_STREAM;
	 			}
	 			else if (_streamName.search(/^mp3:/i) > -1)
	 			{
	 				_fileFormat = MP3_STREAM;
	 			}
	 			else if (_streamName.search(/^id3:/i) > -1)
	 			{
	 				_fileFormat = ID3_STREAM;
	 			}
	 			
	 			// If no stream type found check the query string
	 			if (_fileFormat == null || _fileFormat == "")
	 			{
	 				_fileFormat = getParamValue(QUERY_STRING_STREAMTYPE);
	 			}					 		
 			}		
			
			/*
			 * At this point, the parser may have parsed the FMS URL incorrectly. The following 
			 * is a detailed description:
			 *
			 * RTMP URL has the format as this: RTMP://server<:port>/applicationName/<applicationInstance>/streamName
			 *
			 * where port and applicationInstance are optional. 
			 *  
			 * To make matters more complicated, applicationName and applicationInstance can contain slashes.
			 * For instance, applicationName_part1/applicationName_part2/applicationName_part3.
			 * Since there is no hint about the boundary between applicationName and applicationInstance, a string
			 * such as string_segment_1/string_segment_2/string_segment_3 is to up arbitrary interpretations. 
			 * 
			 * The issue depicted above should not matter too much since both applicationName and applicationInstance 
			 * are part of the RTMP connection string. However, it becomes an issue because a erroneous parsing 
			 * will lead to a malformatted streamName. 
			 *
			 * For instance we have the following URL: 
			 *   rtmp://server/applicationName_part1/applicationName_part2/applicationInstance/mp4:video.f4v
			 *
			 * Up to this point, the parse will consider: 
			 *   applicationName = "applicationName_part1"
			 *   applicationInstance = "applicationName_part2"
			 *   streamName = "applicationInstance/mp4:video.f4v"
			 *
			 * mp4, as well as mp3 and id3, is the prefix of streamName. These prefixes can provide hints
			 * of where the streamName starts. As a result, whatever in front of the prefix should be considered
			 * part of applicationInstance. One may argument that the portion of the streamName might technically be 
			 * part of the applicationName if applicationInstance is absent. The argument is right, but again there 
			 * is not enough information to make a perfect decision. Furthermore, as mentioned before,
			 * it is more important to figure out the port of the streamName actually belongs to the connection string
			 * rather than pin point which part of the connection string. 
			 * 
			 * The following code adjusts the erroneously parsed streamName as described above. One caveat is that 
			 * this adjustment of parsing will fail when dealing with flv files since there is no prefix for it. 
			 */
			var mp4PrefixStart:int = _streamName.indexOf("/mp4:");
			var mp3PrefixStart:int = _streamName.indexOf("/mp3:");
			var id3PrefixStart:int = _streamName.indexOf("/id3:");
			var prefixStart:int = -1;
			if (mp4PrefixStart > 0)
			{
				prefixStart = mp4PrefixStart;
			}
			else if (mp3PrefixStart > 0)
			{
				prefixStart = mp3PrefixStart;
			}
			else if (id3PrefixStart > 0)
			{
				prefixStart = id3PrefixStart;
			}
			if (useInstance && prefixStart > 0)
			{
				_instanceName += "/";
				_instanceName += _streamName.substr(0, prefixStart);
				_streamName = streamName.substr(prefixStart + 1);
			} 
		}
		
		/**
		 * Parse the query string for origin/edge info.
		 * A sample FMS URI with origin/edge info in the query string might look like this:
		 * "rtmp://edge1/?rtmp://edge2/?rtmp://origin/app/inst/mp4:foldera/folder/b/myfile.mp4"
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function parseQuery():void
		{
			// If there is no query string or there are no protocols in the query string, there is nothing to do
			if (query == null || query.length == 0 || (query.search(/:\//) == -1))
			{
				return;
			}
			
			var edgeOriginURIs:Array = query.split("?");
			
			// Remove the items that don't have a protocol
			for (var ndx:int = 0; ndx < edgeOriginURIs.length; ndx++)
			{
		 		var tempIndex:int = edgeOriginURIs[ndx].toString().search(/:\//);
		 		if (tempIndex == -1)
		 		{
		 			edgeOriginURIs.splice(ndx, 1);
		 		}
			}
			
			var hasEdge:Boolean = false;
			var originIndex:int = 0;				
					
			// if it splits into more than one item, we assume it has an edge and the last one is the origin
			if (edgeOriginURIs.length >= 2) {
				hasEdge = true;
				originIndex = edgeOriginURIs.length -1;
			} 
			
			var tempSN:String = "";  // temporary server name
			var tempPN:String = "";	// temporary port number
			var colonIndex:int = 0;
			var slashIndex:int = 0;
			var startIndex:int = 0;
			var endIndex:int = 0;
			
			for (var i:int = 0; i < edgeOriginURIs.length; i++)
			{
		 				 		
		 		var tempNdex:int = edgeOriginURIs[i].toString().search(/:\//);
		 				 		
		 		startIndex = tempNdex + 2;
		
				if (edgeOriginURIs[i].charAt(startIndex) == '/') 
				{
					// if not local URI (i.e. rtmp:/app/) then move index up
					startIndex++;
				}
				
				// get server (and maybe port)
				colonIndex = edgeOriginURIs[i].indexOf(":", startIndex);
				slashIndex = edgeOriginURIs[i].indexOf("/", startIndex);
				
				if (slashIndex < 0 && colonIndex < 0) 
				{
					tempSN = edgeOriginURIs[i].slice(startIndex);
				} 
				else if (colonIndex >= 0 && colonIndex < slashIndex) 
				{
					endIndex = colonIndex;
					tempSN = edgeOriginURIs[i].slice(startIndex, endIndex);
					startIndex = endIndex + 1;
					endIndex = slashIndex;
					tempPN = edgeOriginURIs[i].slice(startIndex, endIndex);
				} 
				else if (edgeOriginURIs[i].indexOf("://") != -1) 
				{
					endIndex = slashIndex;
					tempSN = edgeOriginURIs[i].slice(startIndex, endIndex);
				} 
				else 
				{
					endIndex = edgeOriginURIs[i].indexOf("/");
					tempSN = "localhost";
				}
				
				// if it's the origin, we need to push the origin and get the app and stream name
				if (i == originIndex)
				{
					if (_origins == null)
					{
						_origins = new Vector.<FMSHost>;
					}
					_origins.push(new FMSHost(tempSN, tempPN));
					
					var tempFMSURL:FMSURL = new FMSURL(edgeOriginURIs[i], _useInstance);
					
					if (_appName == "")
					{
						_appName = tempFMSURL.appName;
					}
					
					if (_useInstance && _instanceName == "")
					{
						_instanceName = tempFMSURL.instanceName;
					}
					
					if (_streamName == "")
					{
						_streamName = tempFMSURL.streamName;
					}					
				} 
				else if((edgeOriginURIs[i] != query) && hasEdge) 
				{
					if (_edges == null)
					{
						_edges = new Vector.<FMSHost>;
					}
					_edges.push(new FMSHost(tempSN, tempPN));
				}
			}
		}
		
		private var _useInstance:Boolean;
		private var _appName:String;
		private var _instanceName:String;
		private var _streamName:String;
		private var _fileFormat:String;
		private var _origins:Vector.<FMSHost>;
		private var _edges:Vector.<FMSHost>;
		
		private static const APPNAME_START_INDEX:uint = 0;
		private static const INSTANCENAME_START_INDEX:uint = 2;
		private static const STREAMNAME_START_INDEX:uint = 4;
		
		private static const DEFAULT_INSTANCE_NAME:String = "_definst_";
		
		public static const MP4_STREAM:String = "mp4";
		public static const MP3_STREAM:String = "mp3";
		public static const ID3_STREAM:String = "id3";
		
		public static const QUERY_STRING_STREAM:String = "streamName";
		public static const QUERY_STRING_STREAMTYPE:String = "streamType";
	}
}
