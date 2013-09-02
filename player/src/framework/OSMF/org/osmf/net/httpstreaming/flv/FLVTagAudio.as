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
*****************************************************/
package org.osmf.net.httpstreaming.flv
{
	import flash.utils.ByteArray;

	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class FLVTagAudio extends FLVTag
	{
		public static const SOUND_FORMAT_LINEAR:int = 0;
		public static const SOUND_FORMAT_ADPCM:int = 1;
		public static const SOUND_FORMAT_MP3:int = 2;
		public static const SOUND_FORMAT_LINEAR_LE:int = 3;
		public static const SOUND_FORMAT_NELLYMOSER_16K:int = 4;
		public static const SOUND_FORMAT_NELLYMOSER_8K:int = 5;
		public static const SOUND_FORMAT_NELLYMOSER:int = 6;
		public static const SOUND_FORMAT_G711A:int = 7;
		public static const SOUND_FORMAT_G711U:int = 8;
		public static const SOUND_FORMAT_AAC:int = 10;
		public static const SOUND_FORMAT_SPEEX:int = 11;
		public static const SOUND_FORMAT_MP3_8K:int = 14;
		public static const SOUND_FORMAT_DEVICE_SPECIFIC:int = 15;
		
		public static const SOUND_RATE_5K:Number = 5512.5;
		public static const SOUND_RATE_11K:Number = 11025;
		public static const SOUND_RATE_22K:Number = 22050;
		public static const SOUND_RATE_44K:Number = 44100;
		
		public static const SOUND_SIZE_8BITS:int = 8;
		public static const SOUND_SIZE_16BITS:int = 16;
		
		public static const SOUND_CHANNELS_MONO:int = 1;
		public static const SOUND_CHANNELS_STEREO:int = 2;
		
		public function FLVTagAudio(type:int = FLVTag.TAG_TYPE_AUDIO)
		{
			super(type);
		}
		
		public function get soundFormatByte():int
		{
			return bytes[TAG_HEADER_BYTE_COUNT + 0];
		}
		
		public function set soundFormatByte(value:int):void
		{
			bytes[TAG_HEADER_BYTE_COUNT + 0] = value;
		}
		
		public function get soundFormat():int
		{
			return (bytes[TAG_HEADER_BYTE_COUNT + 0] >> 4) & 0x0f;
		}
		
		public function set soundFormat(value:int):void
		{
			bytes[TAG_HEADER_BYTE_COUNT + 0] &= 0x0f;	// clear upper 4 bits
			bytes[TAG_HEADER_BYTE_COUNT + 0] |= (value << 4) & 0xf0;
			
			if (value == SOUND_FORMAT_AAC)
			{
				soundRate = SOUND_RATE_44K;
				soundChannels = SOUND_CHANNELS_STEREO;
				isAACSequenceHeader = false;	// reasonable default
			}
		}
		
		public function get soundRate():Number
		{
			switch ((bytes[TAG_HEADER_BYTE_COUNT + 0] >> 2) & 0x03)
			{
				case 0: return SOUND_RATE_5K;
				case 1: return SOUND_RATE_11K;
				case 2: return SOUND_RATE_22K;
				case 3: return SOUND_RATE_44K;
			}
			
			throw new Error("get soundRate() a two-bit number wasn't 0, 1, 2, or 3. impossible.");
		}
		
		public function set soundRate(value:Number):void
		{
			var setting:int;
			switch (value)
			{
				case SOUND_RATE_5K:
					setting = 0;
					break;
				case SOUND_RATE_11K:
					setting = 1;
					break;
				case SOUND_RATE_22K:
					setting = 2;
					break;
				case SOUND_RATE_44K:
					setting = 3;
					break;
				default:
					throw new Error("set soundRate valid values 5512.5, 11025, 22050, 44100");
			}
			
			bytes[TAG_HEADER_BYTE_COUNT + 0] &= 0xf3;	// clear upper two bits of lower 4 bits
			bytes[TAG_HEADER_BYTE_COUNT + 0] |= (setting << 2);
		}
		
		public function get soundSize():int
		{
			if ((bytes[TAG_HEADER_BYTE_COUNT + 0] >> 1) & 0x01)
			{
				return SOUND_SIZE_16BITS;
			}
			else
			{
				return SOUND_SIZE_8BITS;
			}
		}
		
		public function set soundSize(value:int):void
		{
			switch (value)
			{
				case SOUND_SIZE_8BITS:
					bytes[TAG_HEADER_BYTE_COUNT + 0] &= 0xfd;	// clear second bit up
					break;
				case SOUND_SIZE_16BITS:
					bytes[TAG_HEADER_BYTE_COUNT + 0] |= 0x02;	// set second bit up
					break;
				default:
					throw new Error("set soundSize valid values 8, 16");
					break;
			}
		}
		
		public function get soundChannels():int
		{
			if (bytes[TAG_HEADER_BYTE_COUNT + 0] & 0x01)
			{
				return SOUND_CHANNELS_STEREO;
			}
			else
			{
				return SOUND_CHANNELS_MONO;
			}
		}
		
		public function set soundChannels(value:int):void
		{
			switch (value)
			{
				case SOUND_CHANNELS_MONO:
					bytes[TAG_HEADER_BYTE_COUNT + 0] &= 0xfe;	// clear lowest bit
					break;
				case SOUND_CHANNELS_STEREO:
					bytes[TAG_HEADER_BYTE_COUNT + 0] |= 0x01;	// set lowest bit
					break;
				default:
					throw new Error("set soundChannels valid values 1, 2");
					break;
			}
		}
		
		public function get isAACSequenceHeader():Boolean
		{
			if (soundFormat != SOUND_FORMAT_AAC)
			{
				throw new Error("get isAACSequenceHeader not valid if soundFormat != SOUND_FORMAT_AAC");
			}
			
			if (bytes[TAG_HEADER_BYTE_COUNT + 1] == 0)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function set isAACSequenceHeader(value:Boolean):void
		{
			if (soundFormat != SOUND_FORMAT_AAC)
			{
				throw new Error("set isAACSequenceHeader not valid if soundFormat != SOUND_FORMAT_AAC");
			}
			
			if (value)
			{
				bytes[TAG_HEADER_BYTE_COUNT + 1] = 0;
			}
			else
			{
				bytes[TAG_HEADER_BYTE_COUNT + 1] = 1;
			}
		}

		public function get isCodecConfiguration():Boolean
		{
			// this function must be updated if other codecs are added which require configuration data
			// be passed through even when audio is being skipped over
			
			// so far, only AAC has this behavior
			
			switch (soundFormat)
			{
				case FLVTagAudio.SOUND_FORMAT_AAC:
					if (isAACSequenceHeader)	// is it an AAC sequence header?
					{
						return true;
					}
					break;
				default:
					break;
			}
			
			return false;
		}
		
		// XXX need warnings about get/set having different behavior after format is set to AAC		
		override public function get data():ByteArray
		{
			var data:ByteArray = new ByteArray();
			if (soundFormat == SOUND_FORMAT_AAC)
			{
				data.writeBytes(bytes, TAG_HEADER_BYTE_COUNT + 2, dataSize - 2);	// just the audio payload, not the format OR the AACPacketType
			}
			else
			{
				data.writeBytes(bytes, TAG_HEADER_BYTE_COUNT + 1, dataSize - 1);	// just the audio payload, not the format
			}
			return data;
		}
		
		
		override public function set data(value:ByteArray):void
		{
			if (soundFormat == SOUND_FORMAT_AAC)
			{
				bytes.length = TAG_HEADER_BYTE_COUNT + value.length + 2;	// resize array first
				bytes.position = TAG_HEADER_BYTE_COUNT + 2;
				bytes.writeBytes(value, 0, value.length); // copy in after format AND AACPacketType
				dataSize = value.length + 2;	// set dataSize field to new payload length plus format + AACPacketType length
			}
			else
			{
				bytes.length = TAG_HEADER_BYTE_COUNT+value.length + 1;	// resize array first
				bytes.position = TAG_HEADER_BYTE_COUNT + 1;
				bytes.writeBytes(value, 0, value.length); // copy in after format
				dataSize = value.length + 1;	// set dataSize field to new payload length plus format length
			}		
		}
	}
}