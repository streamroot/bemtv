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
	
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;
	import org.osmf.net.httpstreaming.flv.FLVTagAudio;

	internal class HTTPStreamingMP2PESAudio extends HTTPStreamingMP2PESBase
	{
		private var _state:int;
		private var _haveNewTimestamp:Boolean = false;
		private var _audioTime:Number;
		private var _audioTimeIncr:Number;
		private var _profile:int = -1;
		private var _sampleRateIndex:int = -1;
		private var _channelConfig:int = -1;
        private var _channelConfigTemp:int = -1;
		private var _frameLength:int;
		private var _remaining:int;	
		private var _adtsHeader:ByteArray;
		private var _needACHeader:Boolean;
		private var _audioData:ByteArray;

		
		public function HTTPStreamingMP2PESAudio():void
		{
			_state = 0;
			_adtsHeader = new ByteArray();
			_needACHeader = true;	// need more than this, actually... 
		}
		
		
		private var srMap:Array = [ 96000, 88200, 64000, 48000, 44100, 32000, 24000, 22050, 16000, 12000, 11025, 8000, 7350 ];
		
		private function getIncrForSRI(srIndex:uint):Number
		{
		
			var rate:Number = srMap[srIndex];
			
			return 1024000.0/rate;	// t = 1/rate... 1024 samples/frame and srMap is in kHz
		}
		
		override public function processES(pusi:Boolean, packet:ByteArray, flush:Boolean = false): ByteArray {
			if(pusi)
			{
				// start of a new PES packet
				
				// Start code prefix and packet ID.
				
				value = packet.readUnsignedInt();
				packet.position -= 4;
				
				var startCode:uint =  packet.readUnsignedInt();
				if(startCode < 0x1C0 || startCode > 0x1DF && startCode != 0x1bd)
				{
						throw new Error("PES start code not found or not AAC/AVC");
				}
				// Ignore packet length and marker bits.
				packet.position += 3;
				// need PTS only
				var flags:uint = (packet.readUnsignedByte() & 0xc0) >> 6;
				if(flags != 0x02 && flags != 0x03)
				{ 
					throw new Error("No PTS in this audio PES packet");
				}

				var length:uint = packet.readUnsignedByte();

				var pts:Number =
					uint((packet.readUnsignedByte() & 0x0e) << 29) +
					uint((packet.readUnsignedShort() & 0xfffe) << 14) +
					uint((packet.readUnsignedShort() & 0xfffe) >> 1);

				var timestamp:Number = Math.round(pts/90);
				_haveNewTimestamp = true;
				
				if(!_timestampReseted) {
					_offset += timestamp - _prevTimestamp;
				}
				
				if (_isDiscontunity || (!_streamOffsetSet)) {// && _prevTimestamp == 0)) {
					/*if(timestamp > 0) {
						_offset += timestamp;
					}*/
					_timestamp = _initialTimestamp;
					_streamOffsetSet = true;
				}else{
					_timestamp = _initialTimestamp + _offset;
				}
				
				_prevTimestamp = timestamp;
				_timestampReseted = false;
				_isDiscontunity = false;
				
				length -= 5;
				// no comp time for audio
				// Skip other header data.
				packet.position += length;
			}
		
			var value:uint;

			var tag:FLVTagAudio;
			var tagData:ByteArray = new ByteArray();
						
			if(!flush)
			{
				var dStart:uint = packet.position;
			}
			
			if(flush)
			{
				;
				CONFIG::LOGGING
				{
					logger.info("audio flush at state "+_state.toString());
				}
			}
			else while(packet.bytesAvailable > 0)
			{
				
				
				if(_state < 7)
				{
					value = packet.readUnsignedByte();
					_adtsHeader[_state] = value;
				}
					
				switch(_state)
				{
					case 0: // first 0xff of flags
						if(_haveNewTimestamp)
						{
							_audioTime = _timestamp;
							_haveNewTimestamp = false;
						}
							
						if(value == 0xff)
						{
							_state = 1;
						}
						else
						{
							CONFIG::LOGGING
							{
								logger.info("adts seek 0");
							}
						}
						break;
					case 1: // final 0xf of flags, first nibble of flags
						if((value & 0xf0) != 0xf0)
						{
							CONFIG::LOGGING
							{
								logger.info("adts seek 1");
							}
							_state = 0;
						}
						else
						{
							_state = 2;
							// 1 bit always 1
							// 2 bits of layer, always 00
							// 1 bit of protection present
						}
						break;
					case 2:

						_state = 3;
                        var profile:int = (value >> 6) & 0x03;
                        if( profile != _profile) {
                            _profile = profile;
                            _needACHeader = true;
                        }

						var sampleRateIndex:int = (value >> 2) & 0x0f;
                        if( sampleRateIndex != _sampleRateIndex) {
                            // Change in sample rate.  We need an AC header.
                            _sampleRateIndex = sampleRateIndex;
                            _needACHeader = true;
                        }
						_audioTimeIncr = getIncrForSRI(_sampleRateIndex);
						// one private bit
						_channelConfigTemp = (value & 0x01) << 2; // first bit thereof
						break;
					case 3:

						_state = 4;
						_channelConfigTemp += (value >> 6) & 0x03; // rest of channel config
                        if( _channelConfigTemp != _channelConfig) {
                            _channelConfig = _channelConfigTemp;
                            _needACHeader = true;
                        }
						// orig/copy bit
						// home bit
						// copyright id bit
						// copyright id start
						_frameLength = (value & 0x03) << 11; // bits 12 and 11 of the length
						break;
					case 4:
						_state = 5;
						_frameLength += (value) << 3; // bits 10, 9, 8, 7, 6, 5, 4, 3
						break;
					case 5:
						_state = 6;
						_frameLength += (value & 0xe0) >> 5;
						_remaining = _frameLength - 7;	// XXX crc issue?
						// buffer fullness
						break;
					case 6:
						_state = 7;
						dStart = packet.position;
						_audioData = new ByteArray();
						// 6 more bits of buffer fullness
						//2  bits number of raw data blocks in frame (add one to get count)
						
						if(_needACHeader)
						{
							tag = new FLVTagAudio();
							tag.timestamp = _audioTime;
							tag.soundFormat = FLVTagAudio.SOUND_FORMAT_AAC;
							tag.soundChannels = FLVTagAudio.SOUND_CHANNELS_STEREO;
							tag.soundRate = FLVTagAudio.SOUND_RATE_44K; // rather than what is reported
							tag.soundSize = FLVTagAudio.SOUND_SIZE_16BITS;
							tag.isAACSequenceHeader = true;
							/*
							var acHeader:ByteArray = new ByteArray();
							acHeader[0] = (_profile + 1)<<3;
							acHeader[0] |= _sampleRateIndex >> 1;
							acHeader[1] = (_sampleRateIndex & 0x01) << 7;
							acHeader[1] |= _channelConfig << 3;
							acHeader.length = 2;
							*/
							_adtsHeader.length = 4;
							tag.data = _adtsHeader;
							_needACHeader = false;
							
							tag.write(tagData); // unroll out vector
						}
						break;
					case 7:
						if((packet.length - dStart) >= _remaining)
						{
							packet.position += _remaining;
							_remaining = 0;
						}
						else
						{
							var avail:uint = packet.length - dStart;
							packet.position += avail;
							_remaining -= avail;
							_audioData.writeBytes(packet, dStart, packet.position-dStart);
						}

						if(_remaining > 0)
						{
							//
						}
						else
						{
							_audioData.writeBytes(packet, dStart, packet.position - dStart);
							
							_state = 0;
							
							tag = new FLVTagAudio();
							tag.timestamp = _audioTime;
							_audioTime += _audioTimeIncr;
							tag.soundChannels = FLVTagAudio.SOUND_CHANNELS_STEREO;
							tag.soundFormat = FLVTagAudio.SOUND_FORMAT_AAC;
							tag.isAACSequenceHeader = false;
							tag.soundRate = FLVTagAudio.SOUND_RATE_44K; // rather than what is reported
							tag.soundSize = FLVTagAudio.SOUND_SIZE_16BITS;
							tag.data = _audioData;
							
							tag.write(tagData); // unrolled out the vector for audio tags
						}
						break;
				} // switch
			} // while
			
			tagData.position = 0;
			
			return tagData;
		}
		
		CONFIG::LOGGING
		{
			private var logger:Logger = Log.getLogger('org.denivip.osmf.net.httpstreaming.hls.HTTPStreamingMP2PESAudio') as Logger;
		}
	}
}