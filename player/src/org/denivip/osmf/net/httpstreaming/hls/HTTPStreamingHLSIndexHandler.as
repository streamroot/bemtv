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
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import org.denivip.osmf.plugins.HLSSettings;
	import org.denivip.osmf.utility.Padding;
	import org.denivip.osmf.utility.Url;
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.events.HTTPStreamingIndexHandlerEvent;
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
			var args:Object = {};
			args.indexInfo = indexInfo;
			args.streamName = "";
			initialize(args);
		}
		
		override public function initialize(args:Object):void{
			_indexInfo = args.indexInfo as HTTPStreamingHLSIndexInfo;
			if( !_indexInfo ||
				!_indexInfo.streams ||
				_indexInfo.streams.length <= 0 ){
				dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
				return;
			}
			
			_baseURL = _indexInfo.baseURL.substr(0, args.indexInfo.baseURL.lastIndexOf('/')+1);
			_streamNames = [];
			_streamQualityRates = [];
			_streamURLs = [];
			
			for each(var hsi:HLSStreamInfo in _indexInfo.streams){
				_streamNames.push(hsi.streamName);
				_streamQualityRates.push(hsi.bitrate);
				var url:String = Url.absolute(_baseURL, hsi.streamName);
				_streamURLs.push(url);
			}
			
			_rateVec = new Vector.<HTTPStreamingM3U8IndexRateItem>(_indexInfo.streams.length);
			
			notifyRatesReady();
			
			// This code is....rather tedious.  TODO figure out why we're doing this, refactor.  Must be an easier way.
			var index:uint = 0;
			for (var x:uint = 0; x < _streamNames.length; x++)
			{
				if( _streamURLs[x] == _baseURL + args.streamName )
				{
					index = x;
					break;
				}
			}
			
			dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.REQUEST_LOAD_INDEX, false, false, false, NaN, null, null, new URLRequest(_streamURLs[index]), index, true));
		}
		
		override public function dispose():void{
			_indexInfo = null;
			_rateVec = null;
			
			_streamNames = null;
			_streamQualityRates = null;
			_streamURLs = null;
			
			_prevPlaylist = null;
		}
		
		override public function processIndexData(data:*, indexContext:Object):void{
			CONFIG::LOGGING
			{
				_reloadTime = getTimer() - _reloadTime;
				logger.info("Playlist reload time {0} sec", (_reloadTime/1000));
			}
			var quality:int;
			var keyRequest:Array;
			var keyItem:HTTPStreamingM3U8IndexKey;
			if(getQualifiedClassName(indexContext) == "Array") {
				// TODO: Update this to use an appropriate Object context
				data = ByteArray(data);
				keyRequest = indexContext as Array;
				keyItem = keyRequest[0];
				quality = keyRequest[1];
				
				// Set key
				keyItem.key = data;
				generateIndexReadyForQuality(quality);
			} else {
				quality = indexContext as int;
				data = String(data).replace(/\\\s*[\r?\n]\s*/g, "");
				
				if(String(data).localeCompare(_prevPlaylist) == 0)
					++_matchCounter;
				
				if(_matchCounter == HLSSettings.hlsMaxErrors){ // if delivered playlist again not changed then error_event (or all what you want)
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
				var keyExistsInIndex:Boolean = false;
				var keyExists:Boolean = false;
				var keyIndex:int = -1;
				var keyIv:String;
				var keyIvGiven:Boolean = false;
				var keyIvIndex:int = 0;
				var duration:Number = 0;
				
				for(var i:int = 0; i < len; i++){
					if(i == 0){
						if(lines[i] != '#EXTM3U'){
							dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
							return;
						}
					}
					
					if (lines[i].indexOf("#") != 0 && lines[i].length > 0) { //non-empty line not starting with # => segment URI
						//var url:String = (lines[i].search(/(ftp|file|https?):\/\//) == 0) ?  lines[i] : rateItem.url.substr(0, rateItem.url.lastIndexOf('/')+1) + lines[i];
						var url:String = Url.absolute(rateItem.url, lines[i]);
						// spike for hidden discontinuity
						if(url.match(/SegNum(\d+)/)){
							var chunkIndex:int = parseInt(url.match(/SegNum(\d+)/)[1]);
							if(chunkIndex <= _prevChunkIndex)
								discontinuity = true;
							_prevChunkIndex = chunkIndex;
						}
						// _spike
						indexItem = new HTTPStreamingM3U8IndexItem(duration, url, discontinuity);
						// Add key if it exists
						if(keyExists) {
							indexItem.key = keyIndex;						
							// Attach correct IV
							if(keyIvGiven) {
								indexItem.iv = keyIv;
							} else {
								indexItem.iv = Padding.zeropad(keyIvIndex, 32);
								keyIvIndex++;
							}
						}
						rateItem.addIndexItem(indexItem);
						discontinuity = false;
					}
					else if(lines[i].indexOf("#EXTINF:") == 0){
						duration = parseFloat(lines[i].match(/([\d\.]+)/)[1]);						
					}else if(lines[i].indexOf("#EXT-X-KEY:") == 0){
						// Flag that encryption key exists in whole playlist
						keyExistsInIndex = true;
						// Flag that encryption key exists for this segment
						keyExists = true;
						
						// Parse for encryption key
						var keyAttributeString:String = lines[i].substring(11);
						var keyAttributes:Array = keyAttributeString.split(",");
						var keyComponent:String;
						var keyValue:String;
						var keyType:String;
						var keyUrl:String;
						
						for (var k:int=keyAttributes.length-1; k >= 0; k--) {
							var keyComponents:Array = keyAttributes[k].split("=");
							keyComponent = keyComponents[0];
							keyValue = keyComponents[1];
							if (keyComponents.length > 2) {
								for (var j:int=2; j < keyComponents.length; j++) {
									keyValue = keyValue + "=" + keyComponents[j];
								}
							}
							
							if(keyComponent == "METHOD") {
								keyType = keyValue;
							}else if(keyComponent == "URI") {
								var strip:RegExp = /"/g;
								keyUrl = keyValue.replace(strip,"");
								//if (keyUrl.search(/(ftp|file|https?):\/\//) != 0) keyUrl = rateItem.url.substr(0, rateItem.url.lastIndexOf('/') + 1) + keyUrl;
								keyUrl = Url.absolute(rateItem.url, keyUrl);
							}else if(keyComponent == "IV") {
								keyIv = keyValue.substr(2);
							}
						}
						
						// TODO - Support SAMPLE-AES
						if(keyType == "AES-128") {
							keyItem = new HTTPStreamingM3U8IndexKey(keyType, keyUrl);
							if(keyIv) {
								keyIvGiven = true;
							}
							rateItem.addIndexKey(keyItem);
							keyIndex++;
							keyRequest = new Array(keyItem, quality);
							dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.REQUEST_LOAD_INDEX, false, false, false, NaN, null, null, new URLRequest(keyUrl), keyRequest, true));
						}
					}else if(lines[i].indexOf("#EXT-X-ENDLIST") == 0){
						rateItem.isLive = false;
					}else if(lines[i].indexOf("#EXT-X-MEDIA-SEQUENCE:") == 0){
						keyIvIndex = parseInt(lines[i].match(/(\d+)/)[1]);
						rateItem.sequenceNumber = keyIvIndex;
					}else{
						if(lines[i].indexOf("#EXT-X-TARGETDURATION:") == 0){
							rateItem.targetDuration = parseFloat(lines[i].match(/([\d\.]+)/)[1]);
						}
						if(lines[i].indexOf("#EXT-X-DISCONTINUITY") == 0){
							discontinuity = true;
							// Reset encryption key variables
							keyExists = false;
							keyIvGiven = false;
							keyIvIndex = 0;
						}
					}
				}
				rateItem.isParsed = true;
				
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
				generateIndexReadyForQuality(quality);
				
				if(rateItem.isLive){
					notifyTotalDuration(rateItem.totalTime, rateItem.isLive);
					_quality = quality;
				}				
			}
		}
		
		override public function getFileForTime(time:Number, quality:int):HTTPStreamRequest{
			_fileHandler.resetCache();
			
			var request:HTTPStreamRequest = checkRateAvilable(quality);
			if(request)
				return request;	// We don't have the manifest for this quality setting yet.
			
			if(_DVR && _dvrStartTime > 0){
				_dvrStartTime = 0.0;
				dispatchDVRStreamInfo(quality);
			}
			
			var item:HTTPStreamingM3U8IndexRateItem = _rateVec[quality];
			var manifest:Vector.<HTTPStreamingM3U8IndexItem> = item.manifest;
			if(!manifest.length)
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);	// nothing in the manifest...
			var len:int = manifest.length;
			var tempItem:HTTPStreamingM3U8IndexItem = manifest[len-1];
			if(time > tempItem.startTime+tempItem.duration)	// is requested time past the last item in the manifest?
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
				_quality = quality;
				notifyTotalDuration(item.totalTime, item.isLive);
			}
			
			_fileHandler.initialOffset = manifest[_segment].startTime;
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
				notifyTotalDuration(item.totalTime, item.isLive);
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
					dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.REQUEST_LOAD_INDEX, false, false, item.isLive, 0, _streamNames, _streamQualityRates, new URLRequest(_rateVec[quality].url), quality, false));						
					return new HTTPStreamRequest(HTTPStreamRequestKind.LIVE_STALL, null, 1.0);
				}
			}
			
			if(_segment >= manifest.length){ // if playlist ended, then end =)
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			}else{ // load new chunk
				request = new HTTPStreamRequest(HTTPStreamRequestKind.DOWNLOAD, manifest[_segment].url);
				
				CONFIG::LOGGING
				{
					logger.info("Load next segment for stream {0}. Segment num {1} from {2}", manifest[_segment].url, _segment, manifest.length);
				}
				
				dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.FRAGMENT_DURATION, false, false, manifest[_segment].duration));
				
				if(manifest[_segment].discontinuity){
					// mark as discontinuity so stream offset should be set again
					_fileHandler.isDiscontunity = true;
					_fileHandler.initialOffset = manifest[_segment].startTime;
					//dispatchEvent(new HTTPHLSStreamingEvent(HTTPHLSStreamingEvent.DISCONTINUITY));
				}
				// Set key and iv on fileHandler
				_fileHandler.key = getCurrentKey();
				_fileHandler.iv = getCurrentIv();
				
				// Increment segments
				++_segment;
				++_absoluteSegment;
			}
			
			return request;
		}
		
		public function getCurrentKey():HTTPStreamingM3U8IndexKey {
			var currentSegment:int = _segment;
			var rateItem:HTTPStreamingM3U8IndexRateItem = _rateVec[_quality];
			if (rateItem.key) {
				var manifest:Vector.<HTTPStreamingM3U8IndexItem> = rateItem.manifest;
				if (currentSegment >= 0 && currentSegment < manifest.length) {
					var item:HTTPStreamingM3U8IndexItem = manifest[currentSegment];
					if (item.key >= 0) {
						var keys:Vector.<HTTPStreamingM3U8IndexKey> = rateItem.key;
						if (item.key < keys.length) {
							return keys[item.key];
						}
					}
				}
			}
			return null;
		}
		
		public function getCurrentIv():String {
			var currentSegment:int = _segment;
			var rateItem:HTTPStreamingM3U8IndexRateItem = _rateVec[_quality];
			if (rateItem.key) {
				var manifest:Vector.<HTTPStreamingM3U8IndexItem> = rateItem.manifest;
				if (currentSegment >= 0 && currentSegment < manifest.length) {
					var item:HTTPStreamingM3U8IndexItem = manifest[currentSegment];
					if (item.key >= 0) {
						var keys:Vector.<HTTPStreamingM3U8IndexKey> = rateItem.key;
						if (item.key < keys.length) {
							return item.iv;
						}
					}
				}
			}
			return null;
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
		
		private function generateIndexReadyForQuality(quality:int):void{
			var rateItem:HTTPStreamingM3U8IndexRateItem = _rateVec[quality];
			var isReady:Boolean = false;
			
			if (rateItem.isParsed) {
				var keys:Vector.<HTTPStreamingM3U8IndexKey> = rateItem.key;
				if (keys) {
					isReady = true;
					for (var i:int=keys.length-1; i >= 0; i--) {
						isReady = isReady && keys[i].isReady();
					}
				} else {
					isReady = true;
				}
				
				// Send off notification if ready
				if (isReady) {
					var initialOffset:Number;
					if(rateItem.isLive){
						initialOffset = rateItem.totalTime - ((rateItem.totalTime/rateItem.manifest.length) * 3);
						if(initialOffset < rateItem.totalTime - 30)
							initialOffset = rateItem.totalTime - 30;
					}
					notifyIndexReady(quality, initialOffset);					
				}
			}
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
		
		private function notifyTotalDuration(duration:Number, live:Boolean):void{
			var sdo:FLVTagScriptDataObject = new FLVTagScriptDataObject();
			var metaInfo:Object = {};
            metaInfo.duration = live ? 0 : duration;
			
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
		
		private var _prevChunkIndex:int = -1;
		CONFIG::LOGGING
		{
			protected var logger:Logger = Log.getLogger("org.denivip.osmf.plugins.hls.HTTPStreamingM3U8IndexHandler") as Logger;
			private var _reloadTime:int;
		}
	}
}
