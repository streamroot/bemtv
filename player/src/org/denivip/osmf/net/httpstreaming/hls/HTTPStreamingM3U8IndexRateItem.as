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
	
	internal class HTTPStreamingM3U8IndexRateItem
	{
		public var sequenceNumber:int;
		public var isLive:Boolean;
		public var targetDuration:Number;
		public var isParsed:Boolean;
		
		private var _bw:Number;
		private var _url:String;
		private var _manifest:Vector.<HTTPStreamingM3U8IndexItem>;
		private var _manifestKeys:Vector.<HTTPStreamingM3U8IndexKey>;
		private var _totalTime:Number;
		
		public function HTTPStreamingM3U8IndexRateItem(
			bw:Number = 0,
			url:String = null,
			seqNum:int = 0,
			live:Boolean = true  // Live is true for all streams until we get a #EXT-X-ENDLIST tag
		)
		{
			_bw = bw;
			_url = url;
			_manifest = new Vector.<HTTPStreamingM3U8IndexItem>;
			_manifestKeys = new Vector.<HTTPStreamingM3U8IndexKey>;
			_totalTime = 0;
			
			sequenceNumber = seqNum;
			isLive = live;
		}
		
		public function get bw():Number{ return _bw; }
		
		public function get url():String{ return _url; }
		
		public function get totalTime():Number{ return _totalTime; }
		
		public function addIndexItem(item:HTTPStreamingM3U8IndexItem):void{
			item.startTime = _totalTime;
			_totalTime += item.duration;
			_manifest.push(item);
		}
		
		public function get manifest():Vector.<HTTPStreamingM3U8IndexItem>
		{
			return _manifest;
		}
		
		public function addIndexKey(item:HTTPStreamingM3U8IndexKey):void{
			_manifestKeys.push(item);
		}
		
		public function get key():Vector.<HTTPStreamingM3U8IndexKey>
		{
			return _manifestKeys;
		}
	}
}