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
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import org.denivip.osmf.elements.m3u8Classes.M3U8Item;
	import org.denivip.osmf.elements.m3u8Classes.M3U8Playlist;
	import org.denivip.osmf.elements.m3u8Classes.M3U8PlaylistParser;
	import org.denivip.osmf.events.HTTPHLSStreamingEvent;
	import org.denivip.osmf.logging.HLSLogger;
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.events.HTTPStreamingIndexHandlerEvent;
	import org.osmf.events.ParseEvent;
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;
	import org.osmf.net.httpstreaming.HTTPStreamRequest;
	import org.osmf.net.httpstreaming.HTTPStreamRequestKind;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataMode;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;

	[Event(name="notifyIndexReady", type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]
	[Event(name="notifyRates", type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]
	[Event(name="notifyTotalDuration", type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]
	[Event(name="requestLoadIndex", type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]
	[Event(name="notifyError", type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]
	[Event(name="DVRStreamInfo", type="org.osmf.events.DVRStreamInfoEvent")]
	
	/**
	 * 
	 */
	public class HTTPStreamingHLSIndexHandler extends HTTPStreamingIndexHandlerBase
	{
		private static const MAX_ERRORS:int = 10;
		
		private var _fileHandler:HTTPStreamingMP2TSFileHandler;
		private var _indexInfo:HTTPStreamingHLSIndexInfo;
		private var _baseURL:String;
		private var _rateVec:Vector.<HTTPStreamingM3U8IndexRateItem>;
		private var _segment:int;
		private var _absoluteSegment:int;
		private var _quality:int = -1;
		
		private var _streamNames:Array;
		private var _streamQualityRates:Array;
		private var _streamURLs:Array;
		
		// for error handling (if playlist don't update on server)
		private var _prevPlaylist:String;
		private var _matchCounter:int;
		
		private var _DVR:Boolean;
		private var _fromDVR:Boolean;
		private var _dvrInfo:DVRInfo;
		private var _dvrStartTime:Number;
		
		public function HTTPStreamingHLSIndexHandler(fileHandler:HTTPStreamingMP2TSFileHandler){
			super();
			
			_fileHandler = fileHandler;
		}
		
		override public function dvrGetStreamInfo(indexInfo:Object):void{
			_DVR = true;
			_fromDVR = true;
			initialize(indexInfo);
		}
		
		override public function initialize(indexInfo:Object):void{
			_indexInfo = indexInfo as HTTPStreamingHLSIndexInfo;
			if( !_indexInfo ||
				!_indexInfo.streams ||
				_indexInfo.streams.length <= 0 ){
				dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
				return;
			}
			
			_baseURL = _indexInfo.baseURL.substr(0, indexInfo.baseURL.lastIndexOf('/')+1);
			_streamNames = [];
			_streamQualityRates = [];
			_streamURLs = [];
			
			for each(var hsi:HLSStreamInfo in _indexInfo.streams){
				_streamNames.push(hsi.streamName);
				_streamQualityRates.push(hsi.bitrate);
				var url:String = _baseURL + hsi.streamName;
				_streamURLs.push(url);
			}
			
			_rateVec = new Vector.<HTTPStreamingM3U8IndexRateItem>(_indexInfo.streams.length);
			
			notifyRatesReady();
			
			dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.REQUEST_LOAD_INDEX, false, false, false, NaN, null, null, new URLRequest(_streamURLs[0]), 0, true));
		}
		
		override public function dispose():void{
			_indexInfo = null;
			_rateVec = null;
			
			_streamNames = null;
			_streamQualityRates = null;
			_streamURLs = null;
			
			_prevPlaylist = null;
		}
		
		/*
			used only in live streaming
		*/
		override public function processIndexData(data:*, indexContext:Object):void{
			CONFIG::LOGGING
			{
				_reloadTime = getTimer() - _reloadTime;
				logger.info("Playlist reload time {0} sec", (_reloadTime/1000));
			}
			
			var quality:int = indexContext as int;
			data = String(data).replace(/\\\s*[\r?\n]\s*/g, "");
			
			if(String(data).localeCompare(_prevPlaylist) == 0)
				++_matchCounter;
			
			if(_matchCounter == MAX_ERRORS){ // if delivered playlist again not changed then error_event (or all what you want)
				CONFIG::LOGGING
				{
					logger.error("Stream is stuck. Playlist on server don't updated!");
				}
				dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
			}
			
			_prevPlaylist = String(data);
			
			var lines:Vector.<String> = Vector.<String>(String(data).split(/\r?\n/));
			var rateItem:HTTPStreamingM3U8IndexRateItem = new HTTPStreamingM3U8IndexRateItem(_streamQualityRates[quality], _streamURLs[quality]);
			var indexItem:HTTPStreamingM3U8IndexItem;
			var len:int = lines.length;
			var discontinuity:Boolean = false;
			for(var i:int = 0; i < len; i++){
				if(i == 0){
					if(lines[i] != '#EXTM3U'){
						dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
						return;
					}
				}
				
				if(lines[i].indexOf("#EXTINF:") == 0){
					var duration:Number = parseFloat(lines[i].match(/([\d\.]+)/)[1]);
					var url:String = rateItem.url.substr(0, rateItem.url.lastIndexOf('/')+1) + lines[i+1];
					indexItem = new HTTPStreamingM3U8IndexItem(duration, url, discontinuity);
					rateItem.addIndexItem(indexItem);
					discontinuity = false;
				}else if(lines[i].indexOf("#EXT-X-ENDLIST") == 0){
					rateItem.isLive = false;
				}else if(lines[i].indexOf("#EXT-X-MEDIA-SEQUENCE:") == 0){
					rateItem.sequenceNumber = parseInt(lines[i].match(/(\d+)/)[1]);
				}else{
					if(lines[i].indexOf("#EXT-X-TARGETDURATION:") == 0){
						rateItem.targetDuration = parseFloat(lines[i].match(/([\d\.]+)/)[1]);
					}
					if(lines[i].indexOf("#EXT-X-DISCONTINUITY") == 0){
						discontinuity = true;
					}
				}
			}
			
			if(_DVR){
				if(isNaN(_dvrStartTime))
					_dvrStartTime = 0.0;
				else{
					var prevRateItem:HTTPStreamingM3U8IndexRateItem = _rateVec[quality];
					if(prevRateItem){
						len = rateItem.sequenceNumber-prevRateItem.sequenceNumber;
						if(len > prevRateItem.manifest.length){
							len = prevRateItem.manifest.length;
						}
						for(i = 0; i < len; i++){
							_dvrStartTime += prevRateItem.manifest[i].duration;
						}
					}
				}
			}
			
			_rateVec[quality] = rateItem;
			var initialOffset:Number;
			if(rateItem.isLive){
				initialOffset = rateItem.totalTime - ((rateItem.totalTime/rateItem.manifest.length) * 3);
				if(initialOffset < rateItem.totalTime - 30)
					initialOffset = rateItem.totalTime - 30;
			}
			notifyIndexReady(quality, initialOffset);
			if(rateItem.isLive){
				notifyTotalDuration(rateItem.totalTime, quality, rateItem.isLive);
				_quality = quality;
			}
		}
		
		override public function getFileForTime(time:Number, quality:int):HTTPStreamRequest{
			_fileHandler.resetCache();
			
			var request:HTTPStreamRequest = checkRateAvilable(quality);
			if(request)
				return request;
			
			if(_DVR && _dvrStartTime > 0){
				_dvrStartTime = 0.0;
				dispatchDVRStreamInfo(quality);
			}
			
			time -= _fileHandler.initialOffset;
			if(time < 0)
				time = 0;
			
			var item:HTTPStreamingM3U8IndexRateItem = _rateVec[quality];
			var manifest:Vector.<HTTPStreamingM3U8IndexItem> = item.manifest;
			if(!manifest.length)
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			var len:int = manifest.length;
			var tempItem:HTTPStreamingM3U8IndexItem = manifest[len-1];
			if(time > tempItem.startTime+tempItem.duration)
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			
			var i:int;
			for(i = 0; i < len; i++){
				if(time < manifest[i].startTime)
					break;
			}
			if(i > 0) --i;
			
			_segment = i;
			_absoluteSegment = item.sequenceNumber + _segment;
			
			if(!item.isLive && _quality != quality){
				notifyTotalDuration(item.totalTime, quality, item.isLive);
				_quality = quality;
			}
			
			return getNextFile(quality);
		}
		
		override public function getNextFile(quality:int):HTTPStreamRequest{
			var request:HTTPStreamRequest = checkRateAvilable(quality);
			if(request)
				return request;
			
			var item:HTTPStreamingM3U8IndexRateItem = _rateVec[quality];
			var manifest:Vector.<HTTPStreamingM3U8IndexItem> = item.manifest;
			
			if(!item.isLive && _quality != quality){
				_quality = quality;
				notifyTotalDuration(item.totalTime, quality, item.isLive);
			}
			
			if(item.isLive){
				if(_absoluteSegment == 0 && _segment == 0){ // Initialize live playback
					_absoluteSegment = item.sequenceNumber + _segment;
				}
				
				if(_absoluteSegment != (item.sequenceNumber + _segment)){ // We re-loaded the live manifest, need to re-normalize the list
					_segment = _absoluteSegment - item.sequenceNumber;
					if(_segment < 0)
					{
						_segment=0;
						_absoluteSegment = item.sequenceNumber;
					}
					_matchCounter = 0; // reset error counter!
				}
				if(_segment >= manifest.length){ // Try to force a reload
					CONFIG::LOGGING
					{
						_reloadTime = getTimer();
					}
					dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.REQUEST_LOAD_INDEX, false, false, item.isLive, 0, _streamNames, _streamQualityRates, new URLRequest(_rateVec[quality].url), _rateVec[quality], false));						
					return new HTTPStreamRequest(HTTPStreamRequestKind.LIVE_STALL, null, 1.0);
				}
			}
			
			if(_segment >= manifest.length){ // if playlist ended, then end =)
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			}else{ // load new chunk
				request = new HTTPStreamRequest(HTTPStreamRequestKind.DOWNLOAD, manifest[_segment].url);
				
				dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.FRAGMENT_DURATION, false, false, manifest[_segment].duration));
				
				if(manifest[_segment].discontinuity){
					dispatchEvent(new HTTPHLSStreamingEvent(HTTPHLSStreamingEvent.DISCONTINUITY));
				}
				
				++_segment;
				++_absoluteSegment;
			}
			
			return request;
		}
		
		/*
			Private secton
		*/
		private function checkRateAvilable(quality:int):HTTPStreamRequest{
			if(!_rateVec[quality]){
				if(_streamQualityRates.length > quality){
					dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.REQUEST_LOAD_INDEX, false, false, false, NaN, null, null, new URLRequest(_streamURLs[quality]), quality, true));
					return new HTTPStreamRequest(HTTPStreamRequestKind.RETRY, null, 1);
				}else{
					return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
				}
			}
			return null;
		}
		
		private function notifyRatesReady():void{
			dispatchEvent(
				new HTTPStreamingIndexHandlerEvent(
					HTTPStreamingIndexHandlerEvent.RATES_READY,
					false,
					false,
					false,
					0,
					_streamNames,
					_streamQualityRates
				)
			);
		}
		
		private function notifyIndexReady(quality:int, offset:Number):void{
			
			if(_DVR){
				dispatchDVRStreamInfo(quality);
				if(_fromDVR){
					_fromDVR = false;
					return;
				}
			}
			
			var initialOffset:Number = Math.max(offset, 0);
				
			dispatchEvent(
				new HTTPStreamingIndexHandlerEvent(
					HTTPStreamingIndexHandlerEvent.INDEX_READY,
					false,
					false,
					_rateVec[quality].isLive,
					initialOffset
				)
			);
		}
		
		private function notifyTotalDuration(duration:Number, quality:int, live:Boolean):void{
			var sdo:FLVTagScriptDataObject = new FLVTagScriptDataObject();
			var metaInfo:Object = new Object();
			if(!live)
				metaInfo.duration = duration;
			else
				metaInfo.duration = 0;
			
			sdo.objects = ["onMetaData", metaInfo];
			dispatchEvent(
				new HTTPStreamingEvent(
					HTTPStreamingEvent.SCRIPT_DATA,
					false,
					false,
					0,
					sdo,
					FLVTagScriptDataMode.IMMEDIATE
				)
			);
		}
		
		private function dispatchDVRStreamInfo(quality:int):void{
			var item:HTTPStreamingM3U8IndexRateItem = _rateVec[quality];
			if(!_dvrInfo)
				_dvrInfo = new DVRInfo();
			
			_dvrInfo.id = _baseURL;
			_dvrInfo.isRecording = item.isLive; // it's simple if not live then VOD =)
			
			if(isNaN(_dvrStartTime))
				_dvrInfo.startTime = 0.0;
			else
				_dvrInfo.startTime = _dvrStartTime;
			
			_dvrInfo.curLength = item.totalTime;
			_dvrInfo.windowDuration = item.totalTime;
			
			dispatchEvent(new DVRStreamInfoEvent(
					DVRStreamInfoEvent.DVRSTREAMINFO,
					false,
					false,
					_dvrInfo
				)
			);
		}
		
		CONFIG::LOGGING
		{
			protected var logger:HLSLogger = Log.getLogger("org.denivip.osmf.plugins.hls.HTTPStreamingM3U8IndexHandler") as HLSLogger;
			private var _reloadTime:int;
		}
	}
}
