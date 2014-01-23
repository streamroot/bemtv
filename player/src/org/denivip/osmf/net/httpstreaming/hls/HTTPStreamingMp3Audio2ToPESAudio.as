/*
 * Copyright
 * hangulee@gmail.com
 * 
 */
 
 package org.denivip.osmf.net.httpstreaming.hls
{
	import __AS3__.vec.Vector;
	
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	
	import flash.utils.ByteArray;
	
	import org.osmf.net.httpstreaming.flv.FLVTagAudio;

	internal class HTTPStreamingMp3Audio2ToPESAudio extends HTTPStreamingMP2PESBase
	{
		private var _state:int;
		private var _haveNewTimestamp:Boolean = false;
		private var _audioTime:Number;
		private var _audioTimeIncr:Number;
		
		private var _frameLength:int;
		private var _remaining:int;	
		private var _audioData:ByteArray;
		
		private var _version:int;
		private var _layer:int;
		private var _bitRate:int;
		private var _sampleRate:int;
		private var _padding:int;
		private var _channel:int;
		
		public function HTTPStreamingMp3Audio2ToPESAudio():void
		{
			_state = 0;
		}
		
		private static const MPEG1:int  = 0x03;
		private static const MPEG2:int  = 0x02;
		private static const MPEG25:int = 0x01;
		
		private static const LAYER_1:int = 0x03;
		private static const LAYER_2:int = 0x02;
		private static const LAYER_3:int = 0x01;
		
		private var BITREATE_MAP_FOR_MPEG1_LAYER1:Array = [0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, 0];
		private var BITREATE_MAP_FOR_MPEG1_LAYER2:Array = [0, 32, 48, 56,  64,  80,  96, 112, 128, 160, 192, 224, 256, 320, 384, 0];
		private var BITREATE_MAP_FOR_MPEG1_LAYER3:Array = [0, 32, 40, 48,  56,  64,  80,  96, 112, 128, 160, 192, 224, 256, 320, 0];
		private var BITREATE_MAP_FOR_MPEG2_LAYER1:Array = [0, 32, 48, 56,  64,  80,  96, 112, 128, 144, 160, 176, 192, 224, 256, 0];
		private var BITREATE_MAP_FOR_MPEG2_LAYER2:Array = [0,  8, 16, 24,  32,  40,  48,  56,  64,  80,  96, 112, 128, 144, 160, 0]; // LAYER3 is same
		
		private var SAMPLERATE_MAP_FOR_MPEG1:Array  = [44100, 48000, 32000, 0];
		private var SAMPLERATE_MAP_FOR_MPEG2:Array  = [22050, 24000, 16000, 0];
		private var SAMPLERATE_MAP_FOR_MPEG25:Array = [11025, 12000,  8000, 0];
		
		private function GetBitRate(version:int, layer:int, index:int):int
		{
			if (version == MPEG1) {
				if (layer == LAYER_1) {
					return BITREATE_MAP_FOR_MPEG1_LAYER1[index];
				}
				else if (layer == LAYER_2) {
					return BITREATE_MAP_FOR_MPEG1_LAYER2[index];
				}
				else if (layer == LAYER_3) {
					return BITREATE_MAP_FOR_MPEG1_LAYER3[index];
				}
			}
			else if (version == MPEG2) {
				if (layer == LAYER_1) {
					return BITREATE_MAP_FOR_MPEG2_LAYER1[index];
				}
				else if (layer == LAYER_2 || layer == LAYER_3) {
					return BITREATE_MAP_FOR_MPEG2_LAYER2[index];
				}
			}
			return 0;
		}
		
		private function GetSampleRate(version:int, no:int):int
		{
			if (version == MPEG1) {
				return SAMPLERATE_MAP_FOR_MPEG1[no];
			} else if (version == MPEG2) {
				return SAMPLERATE_MAP_FOR_MPEG2[no];
			} else if (version == MPEG25) {
				return SAMPLERATE_MAP_FOR_MPEG25[no];
			} 
			
			return 0;
		}
		
		override public function processES(pusi:Boolean, packet:ByteArray, flush:Boolean = false): ByteArray {
			if(pusi)
			{
				// start of a new PES packet
				
				// Start code prefix and packet ID.
				
				value = packet.readUnsignedInt();
				packet.position -= 4;
				if(packet.readUnsignedInt() != 0x1c0)
				{
						throw new Error("PES start code not found or not ~");
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
					((packet.readUnsignedByte() & 0x0e) << 29) + 
					((packet.readUnsignedShort() & 0xfffe) << 14) + 
					((packet.readUnsignedShort() & 0xfffe) >> 1);

				var timestamp:Number = Math.round(pts/90);
				_haveNewTimestamp = true;
				
				if(!_timestampReseted) {
					_offset += timestamp - _prevTimestamp;
				}
				
				if (_isDiscontunity || (!_streamOffsetSet)) {// && _prevTimestamp == 0)) {
					if(timestamp > 0) {
						_offset += timestamp;
					}
					_streamOffsetSet = true;
				}

				_timestamp = _initialTimestamp + _offset;
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
			}
			else while(packet.bytesAvailable > 0)
			{
				if(_state < 7)
				{
					value = packet.readUnsignedByte();
				}
					
				switch(_state)
				{
					case 0: // first 0x01
						if(_haveNewTimestamp)
						{
							_audioTime = _timestamp;
							_haveNewTimestamp = false;
						}
						
						if(value == 0xff)
						{
							_state = 1;
						}
						break;
					case 1:
						if (value & 0xe0 == 0xe0) { // 1110 0000
							
							_version = ((value >> 3) & 0x03);
							_layer = ((value >> 1) & 0x03);
							// var crc:int = (value & 0x01);
							
							_state = 2;
						} else {
							_state = 0;
						}
						break;
					case 2:
						var bitrateIndex:int = ((value >> 4) & 0x0f);
						var sampleRate:int = ((value >> 2) & 0x03);
						_padding = ((value >> 1) & 0x01);
						//var bit:int = ((value & 0x01));
						
						_state = 3;
						
						_bitRate = GetBitRate(_version, _layer, bitrateIndex);
						if (_bitRate == 0) {
							_state = 0;
						}
						
						_sampleRate = GetSampleRate(_version, sampleRate);
						//_audioTimeIncr = 1024000.0 / _sampleRate;
						_audioTimeIncr = 144 * 8 * 1000 / _sampleRate;
						
						if (_sampleRate == 0) {
							_state = 0;
						}
						
						break;
					case 3:
						_channel = ((value >>6) & 0x03);
						//var modeExt:int = ((value >> 4) & 0x03);
						//var copyright:int = ((value >> 3) & 0x01);
						//var original:int = ((value >> 2) & 0x01);
						//var emphasis:int = (value & 0x03);
						
						_frameLength = int((144 * _bitRate * 1000 / _sampleRate ) + _padding);
						
						packet.position -= 4;
						
						dStart = packet.position;
						_audioData = new ByteArray();
						_remaining = _frameLength;
						
						_state = 4;
						break;
					case 4:
						var avail:int = packet.length - dStart;
						
						if(avail >= _remaining)
						{
							_audioData.writeBytes(packet, dStart, _remaining);
							packet.position += _remaining - 1;
							_remaining = 0;
						}
						else if(avail > 0)
						{
							_audioData.writeBytes(packet, dStart, avail);
							packet.position += avail;
							_remaining -= avail;
						}
						
						if(_remaining > 0)
						{
							//
						}
						else
						{
							tag = new FLVTagAudio();
							tag.timestamp = _audioTime;
							_audioTime += _audioTimeIncr;
							tag.soundChannels = (_channel == 0x03 ? FLVTagAudio.SOUND_CHANNELS_MONO : FLVTagAudio.SOUND_CHANNELS_STEREO);
							tag.soundFormat = FLVTagAudio.SOUND_FORMAT_MP3;
							tag.soundRate = FLVTagAudio.SOUND_RATE_44K; // rather than what is reported
							tag.soundSize = FLVTagAudio.SOUND_SIZE_16BITS;
							
							_state = 0;
							
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
			private var logger:Logger = Log.getLogger('org.denivip.osmf.net.httpstreaming.hls.HTTPStreamingMp3Audio2ToPESAudio') as Logger;
		}
	}
}
