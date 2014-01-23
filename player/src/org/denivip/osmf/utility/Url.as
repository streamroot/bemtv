package org.denivip.osmf.utility
{
	/*
	 * Contains Utility functions for relative / absolute url.
	 * Main difference is if relative url is starting with slash "/" or without "/"
	 * 
	 * Example:
	 * m3u8:
		http://www.example.com/playlist/first/video.m3u8
	
	 * relative path starting without "/":
			part-1.ts
		absolute path: 
			http://www.example.com/playlist/first/part-1.ts
	
	 * relative path starting with "/":
			/part-1.ts
		absolute path:
			http://www.example.com/part-1.ts
	 */
	public class Url
	{
		public static function absolute(rootUrl:String, url:String):String {
			if (url.search(/(ftp|file|https?):\/\//) == 0)
				return url;
						
			if (url.charAt(0) == '/') {
				var urlParts:Array = rootUrl.split('/', 4);
				rootUrl = urlParts[2]
				? urlParts[0] + '//' + urlParts[2]
				: urlParts[0] + '///' + urlParts[3];
				//*		'//' = http || https || ftp,	 '///' = file
				return rootUrl + url;
			}
		
			if (rootUrl.lastIndexOf('/') != rootUrl.length - 1) {
				rootUrl = rootUrl.substr(rootUrl.lastIndexOf('/')).indexOf('.') > -1
				? rootUrl.substr(0, rootUrl.lastIndexOf('/') + 1)
				: rootUrl + '/';
			}
			return rootUrl + url;
		}
	}
}
