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
	import org.osmf.net.httpstreaming.HTTPStreamingIndexInfoBase;

	/**
	 * Index info for HLS-streaming
	 * Builded from .m3u8 playlist
	 */
	public class HTTPStreamingHLSIndexInfo extends HTTPStreamingIndexInfoBase
	{
		private var _baseURL:String;
		private var _streams:Vector.<HLSStreamInfo>;
		
		public function HTTPStreamingHLSIndexInfo(
			baseUrl:String,
			streams:Vector.<HLSStreamInfo> = null)
		{
			_baseURL = baseUrl;
			_streams = streams;
		}
		
		public function get baseURL():String{ return _baseURL; }
		public function get streams():Vector.<HLSStreamInfo>{ return _streams; }
	}
}