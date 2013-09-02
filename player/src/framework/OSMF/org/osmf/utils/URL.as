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
package org.osmf.utils
{
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * URL parses a Uniform Resource Identifier (URI/URL) into individual properties and provides easy access
	 * to query string parameters.  This also works with rtmp:// urls, but will assume the instance isn't specified.  
	 * To use rtmp:// urls with an instance name, use the FMSURL class instead of URL.
	 * 
	 * @see FMSURL
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class URL
	{		
		/**
		 * The constructor takes a URI/URL string and begins parsing it. The URI/URL can also 
		 * be set via the <code>url</code> property.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function URL(url:String) 
		{
			_rawUrl = url;
			_protocol = "";
			_userInfo = "";
			_host = "";
			_port = "";
			_path = "";
			_query = "";
			_fragment = "";
			
			if ((_rawUrl != null) && (_rawUrl.length > 0))
			{
				// Strip leading/trailing spaces.
				_rawUrl = _rawUrl.replace(/^\s+|\s+$/g, "");
				
				parseUrl();
			}
		}
		
		/**
		 * The raw URI/URL string used by this class.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get rawUrl():String
		{
			return _rawUrl;
		}
				
		/**
		 * The protocol string, such as "rtmp", "http".
		 * <p>
		 * The protocol string is converted to lower case and the trailing <code>"://"</code> 
		 * string, if it exists, is stripped off.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get protocol():String
		{
			return _protocol;
		}
		
		public function set protocol(value:String):void
		{
			if (value != null)
			{
				_protocol = value.replace(/:\/?\/?$/, "");
				_protocol = _protocol.toLowerCase();
			}
		}
		
		/** 
		 * The user info if present.
		 * <p>An example of a URI/URL containing user info might be:
		 * <code>http://user:password&#38;#64host.com:80/foo.php</code></p>
		 * <p>
		 * This property contains a string formatted as "username:password".
		 * </p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get userInfo():String
		{
			return _userInfo;
		}
		
		public function set userInfo(value:String):void 
		{
			if (value != null)
			{
				_userInfo = value.replace(/@$/, "");			
			}
		}
		
		/**
		 * The host name as it was specified in the URI/URL string supplied,
		 * without leading or trailing slashes.
		 * <p> 
		 * For example, in this URL: <code>"http://hostname.com:80/foo/bar/index.html?a=1&#38;b=2"</code>
		 * host would be <code>"hostname.com"</code></p>									
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get host():String
		{
			return _host;
		}
		
		public function set host(value:String):void
		{
			_host = value;
		}

		/**
		 * The port number as a string.
		 * <p> 
		 * For example, in this URL: <code>"http://hostname.com:80/foo/bar/index.html?a=1&#38;b=2"</code>
		 * port would be <code>"80"</code></p>									
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get port():String
		{
			return _port;
		}
		
		public function set port(value:String):void
		{
			if (value != null)
			{
				_port = value.replace(/(:)/, "");
			}
		}

		/**
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
		public function get path():String
		{
			return _path;
		}
		
		public function set path(value:String):void
		{
			if (value != null)
			{
				_path = value.replace(/^\//, "");
			}
		}
		
		/**
		 * The raw query string, everything after the first '?' character, and up to the '#' if it exists.
		 * 
		 * <p> 
		 * For example, in this URL: <code>"http://hostname.com/foo/bar/index.html?param1=abcdef&#38;param2=ghijkl#xyz"</code>
		 * query would be <code>"param1=abcdef&#38;param2=ghijkl"</code></p>
		 * 									
		 * @see #getParamValue()
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get query():String
		{
			return _query;
		}
		
		public function set query(value:String):void
		{
			if (value != null)
			{
				_query = value.replace(/^\?/, "");
			}
		}
				
		/**
		 * The fragment, everything after the '#' to the end of the URL string.
		 * <p>
		 * For example, in this URL:<code>"http://host.com/foo/bar/index.html?p1=123&#38;p2=456#xyz"</code>,
		 * the fragment is <code>"xyz"</code></p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get fragment():String
		{
			return _fragment;
		}
		
		public function set fragment(value:String):void
		{
			if (value != null)
			{
				_fragment = value.replace(/^#/, "");
			}
		}
		
		/**
		 * Returns the entire URL string.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function toString():String
		{
			return _rawUrl;
		}
		
		/**
		 * Given a query string parameter name, returns it's value. If not found, returns an empty string ("").
		 * 
		 * <p>
		 * For example, if the URL constructor were handed this value:<code>"http://host.com/foo/bar/index.html?param1=123&#38;param2=456"</code>,
		 * calling <code>getParamValue("param1")</code> would return <code>"123"</code></p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getParamValue(param:String):String
		{
			if (_query == null)
			{
				return "";
			}
			
			var pattern:RegExp = new RegExp("[\/?&]*" + param + "=([^&#]*)", "i");
						
			var result:Array = _query.match(pattern);
			var value:String = (result == null) ? "" : result[1];
			
			return value;
		}
		
		/**
		 * The url is fully qualified.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function get absolute():Boolean
		{
			return protocol != "";
		}
		
		/**
		 * Returns the file extension of the URL, the empty string if there is
		 * no extension.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get extension():String
		{
			var lastPathElement:int = path.lastIndexOf("/");
			var lastDot:int = path.lastIndexOf(".");
			if (lastDot != -1 && lastDot > lastPathElement)
			{
				return path.substr(lastDot+1);
			}
			
			return "";
		}
		
		/**
		 * Parses the url into properties.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function parseUrl():void
		{
			if ((_rawUrl == null) || (_rawUrl.length == 0))
			{
				return;
			}
			
			// Check to see if this is a relative path, meaning there is no protocol specified
			if (	_rawUrl.search(/:\//) == -1
				&&	_rawUrl.indexOf(":") != _rawUrl.length - 1
			   )
			{
				path = _rawUrl;
			}
			else
			{
	
				// Handle the special case where the user is tring to connect to a dev server running on 
	 			//	the same machine as the client with a url like this: "rtmp:/sudoku/room1"
				var oneSlashRegExp:RegExp = /^(rtmp|rtmp[tse]|rtmpte)(:\/[^\/])/i;
	 			var oneSlashResult:Array = _rawUrl.match(oneSlashRegExp);
	 				
				var tempUrl:String = _rawUrl;
	 				
	 			if (oneSlashResult != null)
	 			{
	 				tempUrl = _rawUrl.replace(/:\//, "://localhost/");	
	 			}
	
				// We'll parse the url in two passes: 
				// 1) pull out the host name which might contain '@' and ':' characters;
				// 2) parse the host name out into user info, host, and port.
				//
				// This makes the regular expressions simpler and should accommodate some irregular urls that might contain
				// '@' and ':' in the path.
				
	 			/* 
	 			* The regular expression below performs a match on a URL string, effectively breaking it up into 
	 			* the individual properites, such as protocol, host name, port, etc.
	 			* 
	 			* Here are the individual patterns of the regular expression:
	 			* 
	 			* protocol : ^([a-z+\w\+\.\-]+:\/?\/?)?
	 			*	The caret (^) means start at the beginnning of the string.
	 			*	The "[a-z+\w\+\.\-]+" pattern means match the following group of characters 1 or more times: letters from a to z, followed by any letter
	 			*		from a to z, a number from 0 to 9, an underscore (-), a plus sign (+), a period (.), or a dash (-).
	 			*	The ":\/?\/?" pattern means match the string ":" or ":/" or "://".
	 			*	The question mark '?' at the end means the entire sequence can appear once or not at all.
	 			*
	 			* path: (\/[^?#]*)
	 			*	This pattern matches a sequence starting with a slash (/) followed by any characters other than '?' or '#'.
	 			* 
	 			* query: (\?[^#]*)
	 			*	This pattern matches a sequence starting with a '?' followed by any character other than a '#'.
	 			*
	 			* fragment: (\#.*)
	 			*	This pattern matches a sequence starting with a '#' character followed by any character zero or more times.
	 			*/
				
				var pattern:RegExp = /^([a-z+\w\+\.\-]+:\/?\/?)?([^\/?#]*)?(\/[^?#]*)?(\?[^#]*)?(\#.*)?/i;		
				var result:Array = tempUrl.match(pattern);
				var hostName:String;
				
				if (result != null)
				{
					protocol = result[1];
					hostName = result[2];
			        path = result[3];
			        query = result[4];
			        fragment = result[5];
			        
			        /*
			        * Now we'll parse the host name.
			        *
		 			* user info: ([!-~]+@)?
	 				*	This pattern matches any charater from '!' to '~' in the ascii character set occurring 1 or more times followed by '@'.
	 				*
	 				* host and port number: ([^\/?#:]*)(:[\d]*)
	 				* 	This pattern matches any sequence of characters other than '/', '?', '#', and ':', followed by an optional ':' and a 
	 				* 	digit representing the port number.
	 				*/
			        pattern = /^([!-~]+@)?([^\/?#:]*)(:[\d]*)?/i;
			        result = hostName.match(pattern);
			        if (result != null)
			        {
						this.userInfo = result[1];
						this.host = result[2];
						this.port = result[3];
			        }
			 	}
			}
		}
		
		public static function isAbsoluteURL(url:String):Boolean
		{
			var theURL:URL = new URL(url);
			return theURL.absolute;
		}
		
		public static function getRootUrl(url:String):String
		{
			var path:String = url.substr(0, url.lastIndexOf("/"));
			
			return path;
		}
		
		
		/**
		 * Normalizes a root URL. It adds a trailing slash (/) if not present.
		 * It is assumed that the passed url is an absolute root url. No checks will be performed to validate this.
		 * 
		 * @param url The root URL to be normalized
		 * 
		 */
		public static function normalizeRootURL(url:String):String
		{
			if (url != null && url.charAt(url.length - 1) != "/")
			{
				return url + "/";
			}
			else
			{
				return url;
			}
		}
		
		/**
		 * Normalizes a relative URL. It removes the leading slash (/) if present.
		 * It is assumed that the passed url is a relative one. No checks will be performed to validate this.
		 */
		public static function normalizeRelativeURL(url:String):String
		{
			if (url.charAt(0) == "/")
			{
				return url.substr(1);
			}
			else
			{
				return url;
			}
		}
		
		private var _rawUrl:String;		// The raw URL string as it was supplied
		private var _protocol:String;	// The scheme or protocol, i.e., "http", "ftp", etc.
		private var _userInfo:String;	// User name : password. For example "http://user:password@host.com:80/foo.php"
		private var _host:String;		// Host name
		private var _port:String;		// The port name. Follows host, such as "http://host.com:80/index.html"
		private var _path:String;		// Path is everything after the host but before any params. For example 
										//	in this URL: "http://host.com:80/foo/bar/index.html?a=1&#38;b=2", path would be "/foo/bar/index.html"									
		private var _query:String;		// The entire query string, everything after the "?" up to the '#', if that exists
		private var _fragment:String;	// From the first # to the end of the url		
	}
}
