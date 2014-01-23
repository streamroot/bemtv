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
	import flash.utils.IDataInput;
	
	import com.hurlant.util.Hex;
	import org.denivip.osmf.utility.decrypt.AES;
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;
	import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
	
	[Event(name="notifySegmentDuration", type="org.osmf.events.HTTPStreamingFileHandlerEvent")]
	[Event(name="notifyTimeBias", type="org.osmf.events.HTTPStreamingFileHandlerEvent")]	
	

	public class HTTPStreamingMP2TSFileHandler extends HTTPStreamingFileHandlerBase
	{
		private var _syncFound:Boolean;
		private var _pmtPID:uint;
		private var _audioPID:uint;
		private var _videoPID:uint;
		private var _mp3AudioPID:uint;
		private var _audioPES:HTTPStreamingMP2PESAudio;
		private var _videoPES:HTTPStreamingMP2PESVideo;
		private var _mp3audioPES:HTTPStreamingMp3Audio2ToPESAudio;
		
		private var _cachedOutputBytes:ByteArray;
		private var alternatingYieldCounter:int = 0;
		
		private var _key:HTTPStreamingM3U8IndexKey = null;
		private var _iv:ByteArray = null;
		private var _decryptBuffer:ByteArray = new ByteArray;
		
		// AES-128 specific variables
		private var _decryptAES:AES = null;
		
		public function HTTPStreamingMP2TSFileHandler()
		{
			_audioPES = new HTTPStreamingMP2PESAudio;
			_videoPES = new HTTPStreamingMP2PESVideo;
			_mp3audioPES = new HTTPStreamingMp3Audio2ToPESAudio;
		}
		
		override public function beginProcessFile(seek:Boolean, seekTime:Number):void
		{
			_syncFound = false;
		}

		override public function get inputBytesNeeded():Number
		{
			return _syncFound ? 187 : 1;
		}
		
		override public function processFileSegment(input:IDataInput):ByteArray
		{
			var bytesAvailableStart:uint = input.bytesAvailable;
			var output:ByteArray;
			
			if (_cachedOutputBytes !== null) {
				output = _cachedOutputBytes;
				_cachedOutputBytes = null;
			}
			else {
				output = new ByteArray();
			}
			
			while (true) {
				if(!_syncFound)
				{
					if (_key) {
						if (_key.type == "AES-128") {
							if (input.bytesAvailable < 16) {
								if (_decryptBuffer.bytesAvailable < 1) {
									break;
								}
							} else {
								if (!decryptToBuffer(input, 16)) {
									break;
								}
							}
							if (_decryptBuffer.readByte() == 0x47) {
								_syncFound = true;
							}
						}
					} else {
						if(input.bytesAvailable < 1)
							break;
						
						if(input.readByte() == 0x47)
							_syncFound = true;
					}
				}
				else
				{
					var packet:ByteArray = new ByteArray();
					
					if (_key) {
						if (_key.type == "AES-128") {
							if (input.bytesAvailable < 176) {
								if (_decryptBuffer.bytesAvailable < 187) {
									break;
								}
							} else {
								var bytesLeft:uint = input.bytesAvailable - 176;
								if (bytesLeft > 0 && bytesLeft < 15) {
									if (!decryptToBuffer(input, input.bytesAvailable)) {
										break;
									}
								} else {
									if (!decryptToBuffer(input, 176)) {
										break;
									}
								}
							}
							_decryptBuffer.readBytes(packet, 0, 187);
						}
					} else {
						if(input.bytesAvailable < 187)
							break;
						
						input.readBytes(packet, 0, 187);
					}
					
					_syncFound = false;
					var result:ByteArray = processPacket(packet);
					if (result !== null) {
						output.writeBytes(result);
					}
					
					if (bytesAvailableStart - input.bytesAvailable > 10000) {
						alternatingYieldCounter = (alternatingYieldCounter + 1) & 0x03;
						if (alternatingYieldCounter /*& 0x01 === 1*/) {
							_cachedOutputBytes = output;
							return null;
						}
						break;
					}
				}
			}
			output.position = 0;
			
			return output.length === 0 ? null : output;
		}
		
		private function decryptToBuffer(input:IDataInput, blockSize:int):Boolean{
			if (_key) {
				// Clear buffer
				if (_decryptBuffer.bytesAvailable == 0) {
					_decryptBuffer.clear();
				}
				
				if (_key.type == "AES-128" && blockSize % 16 == 0 && _key.key) {
					if (!_decryptAES) {
						_decryptAES = new AES(_key.key);
						_decryptAES.pad = "none";
						_decryptAES.iv = _iv;
					}
					
					// Save buffer position
					var currentPosition:uint = _decryptBuffer.position;
					_decryptBuffer.position += _decryptBuffer.bytesAvailable;
					
					// Save block to decrypt
					var decrypt:ByteArray = new ByteArray;
					input.readBytes(decrypt, 0, blockSize);
					// Save new IV from ciphertext
					var newIv:ByteArray = new ByteArray;
					decrypt.position += (decrypt.bytesAvailable-16);
					decrypt.readBytes(newIv, 0, 16);
					decrypt.position = 0;
					// Decrypt
					if (input.bytesAvailable == 0) {
						_decryptAES.pad = "pkcs7";
					}
					_decryptAES.decrypt(decrypt);
					decrypt.position = 0;
					// Write into buffer
					_decryptBuffer.writeBytes(decrypt);
					_decryptBuffer.position = currentPosition;
					// Update AES IV
					_decryptAES.iv = newIv;
					
					return true;
				}
			}
			
			return false;
		}
		
		override public function endProcessFile(input:IDataInput):ByteArray
		{
			_decryptBuffer.clear();
			if (_decryptAES) {
				_decryptAES.destroy();
			}
			_decryptAES = null;
			return null;	
		}
		
		public function resetCache():void{
			_cachedOutputBytes = null;
			alternatingYieldCounter = 0;
			_decryptBuffer.clear();
			if (_decryptAES) {
				_decryptAES.destroy();
			}
			_decryptAES = null;
		}
		
		public function set isDiscontunity(isDiscontunity:Boolean):void{
			_videoPES.isDiscontunity = isDiscontunity;
			_audioPES.isDiscontunity = isDiscontunity;
			_mp3audioPES.isDiscontunity = isDiscontunity;
		}
		
		public function set initialOffset(offset:Number):void{
			offset *= 1000; // convert to ms
			_videoPES.initialTimestamp = offset;
			_audioPES.initialTimestamp = offset;
			_mp3audioPES.initialTimestamp = offset;
		}
		
		public function set key(key:HTTPStreamingM3U8IndexKey):void {
			_key = key;
			if (_decryptAES) {
				_decryptAES.destroy();
			}
			_decryptAES = null;
		}
		
		public function set iv(iv:String):void {
			if (iv) {
				_iv = Hex.toArray(iv);
			}
		}
		
		private function processPacket(packet:ByteArray):ByteArray
		{
			// decode rest of transport stream prefix (after the 0x47 flag byte)
			
			// top of second byte
			var value:uint = packet.readUnsignedByte();
			
			//var tei:Boolean = Boolean(value & 0x80);	// error indicator
			var pusi:Boolean = Boolean(value & 0x40);	// payload unit start indication
			//var tpri:Boolean = Boolean(value & 0x20);	// transport priority indication
			
			// bottom of second byte and all of third
			value <<= 8;
			value += packet.readUnsignedByte();
			
			var pid:uint = value & 0x1fff;	// packet ID
			
			// fourth byte
			value = packet.readUnsignedByte();
			//var scramblingControl:uint = (value >> 6) & 0x03;	// scrambling control bits
			var hasAF:Boolean = Boolean(value & 0x20);	// has adaptation field
			var hasPD:Boolean = Boolean(value & 0x10);	// has payload data
			//var ccount:uint = value & 0x0f;		// continuty count
			
			// technically hasPD without hasAF is an error, see spec
			
			if(hasAF)
			{
				// process adaptation field
				// don't care about flags
				// don't care about clocks here
                //noinspection UnnecessaryLocalVariableJS - code inspection is wrong, this cannot be simplified because packet.position changes
                var af:uint = packet.readUnsignedByte();
				packet.position += af;	// skip to end
			}

            return hasPD ? processES(pid, pusi, packet) : null;
		}
		
		private function processES(pid:uint, pusi:Boolean, packet:ByteArray):ByteArray
		{
			var output:ByteArray = null;
			if(pid == 0)	// PAT
			{
				if(pusi)
					processPAT(packet);
			}
			else if(pid == _pmtPID)
			{
				if(pusi)
					processPMT(packet);
			}
			else if(pid == _audioPID)
			{
				output = _audioPES.processES(pusi, packet);
			}
			else if(pid == _videoPID)
			{
				output = _videoPES.processES(pusi, packet);
			}
			else if(pid == _mp3AudioPID)
			{
				output = _mp3audioPES.processES(pusi, packet);
			}
			
			return output;
		}
		
		private function processPAT(packet:ByteArray):void
		{
			packet.readUnsignedByte();   // pointer:uint
			packet.readUnsignedByte();   // tableID:uint
			var remaining:uint = packet.readUnsignedShort() & 0x03ff; // ignoring misc and reserved bits
			
			packet.position += 5; // skip tsid + version/cni + sec# + last sec#
			remaining -= 5;
			
			while(remaining > 4)
			{
				packet.readUnsignedShort(); // program number
				_pmtPID = packet.readUnsignedShort() & 0x1fff; // 13 bits
				remaining -= 4;
				
				//return; // immediately after reading the first pmt ID, if we don't we get the LAST one
			}
			
			// and ignore the CRC (4 bytes)
		}
		
		private function processPMT(packet:ByteArray):void
		{
			packet.readUnsignedByte();  // pointer:uint
			var tableID:uint = packet.readUnsignedByte();
			
			if (tableID != 0x02)
			{
				CONFIG::LOGGING
				{
					logger.warn("PAT pointed to PMT that isn't PMT");
				}
				return; // don't try to parse it
			}

			var remaining:uint = packet.readUnsignedShort() & 0x03ff; // ignoring section syntax and reserved
			
			packet.position += 7; // skip program num, rserved, version, cni, section num, last section num, reserved, PCR PID
			remaining -= 7;
			
			var piLen:uint = packet.readUnsignedShort() & 0x0fff;
			remaining -= 2;
			
			packet.position += piLen; // skip program info
			remaining -= piLen;
			
			while(remaining > 4)
			{
				var type:uint = packet.readUnsignedByte();
				var pid:uint = packet.readUnsignedShort() & 0x1fff;
				var esiLen:uint = packet.readUnsignedShort() & 0x0fff;
				remaining -= 5;
				
				packet.position += esiLen;
				remaining -= esiLen;
				
				switch(type)
				{
					case 0x1b: // H.264 video
						_videoPID = pid;
						break;
					case 0x0f: // AAC Audio / ADTS
						_audioPID = pid;
						break;
					
					case 0x03: // MP3 Audio  (3 & 4)
					case 0x04:
						_mp3AudioPID = pid;
						break;
					
					default:
						CONFIG::LOGGING
						{
							logger.error("unsupported type "+type.toString(16)+" in PMT");
						}
						break;
				}
			}
			
			// and ignore CRC
		}
		
		override public function flushFileSegment(input:IDataInput):ByteArray
		{
			var flvBytes:ByteArray = new ByteArray();
			var flvBytesVideo:ByteArray = _videoPES.processES(false, null, true);
			var flvBytesAudio:ByteArray = _audioPES.processES(false, null, true);
		
			if(flvBytesVideo)
				flvBytes.readBytes(flvBytesVideo);
			if(flvBytesAudio)
				flvBytes.readBytes(flvBytesAudio);
			
			return flvBytes;
		}
		
		CONFIG::LOGGING
		{
			private var logger:Logger = Log.getLogger('org.denivip.osmf.net.httpstreaming.hls.HTTPStreamingMP2TSFileHandler') as Logger;
		}
	}
}
