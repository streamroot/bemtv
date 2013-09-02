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

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * StreamingXMLResource is a media resource that has a xml representation of 
	 * a Flash Media Manifest. It serves as an input object for MediaElements that 
	 * can process and present media represented by an F4M.	 
	 *  
	 * @langversion 3.0
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @productversion OSMF 1.6
	 */
	public class StreamingXMLResource extends MediaResourceBase
	{
		/**
		 * Constructor.
		 * 
		 * @param manifest The String representation of the Flash Media Manifest
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function StreamingXMLResource
			( manifest:String 
			, baseURL:String = null 
			, clipStartTime:Number = NaN 
			, clipEndTime:Number = NaN
			)
		{
			super();
			_manifest = manifest;
			if (baseURL != null)
			{
				_url = baseURL;
			}
			else
			{
				var xml:XML = new XML(manifest);
				var ns:Namespace = xml.namespace();
			    var manifestBaseURL:String = xml.ns::baseURL.text();
				if (manifestBaseURL != null)
				{
					_url = manifestBaseURL;
				}
				else
				{
					throw new Error("The baseURL was not specified neither via the baseURL parameter, nor via the manifest <baseURL> tag.");
				}
			}
			
			if (_url != null)
			{
				// Ensure _url has a trailing slash ("/")
				if (_url.charAt(_url.length - 1) != "/")
				{
					_url += "/";
				}
				
				// Add bogus "manifest.f4m" at the end of the _url
				// This is done because when the parser tries to extract the rootURL it expects a full URL
				_url += "manifest.f4m";
			}
			
			_clipStartTime = clipStartTime;
			_clipEndTime = clipEndTime;
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
		 * @private
		 */
		public function get manifest():String
		{
			return _manifest;
		}
		
		/**
		 * @private
		 */
		public function get url():String
		{
			return _url;
		}
		
		private var _manifest:String;
		private var _url:String;
		private var _clipStartTime:Number;
		private var _clipEndTime:Number;
	}
}