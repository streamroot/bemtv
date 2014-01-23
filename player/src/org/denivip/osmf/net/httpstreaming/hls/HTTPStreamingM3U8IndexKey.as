/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the at.matthew.httpstreaming package.
 *
 * The Initial Developer of the Original Code is
 * Matthew Kaufman.
 * Portions created by the Initial Developer are Copyright (C) 2011
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** */
 
 package org.denivip.osmf.net.httpstreaming.hls
{
	import flash.utils.ByteArray;
	
	/**
	 * Represents an AES-encryption key for M3U8 indexes
	 */
	internal class HTTPStreamingM3U8IndexKey
	{		
		private var _type:String;
		private var _url:String;
		private var _key:ByteArray = null;
		
		public function HTTPStreamingM3U8IndexKey(type:String, url:String)
		{
			_type = type;
			_url = url;
		}
		
		public function get type():String{ return _type; }
		
		public function get url():String{ return _url; }
		
		public function get key():ByteArray{ return _key; }
		
		public function set key(key:ByteArray):void { _key = key; }
		
		public function isReady():Boolean {
			return (_key != null);

		}
	}
}