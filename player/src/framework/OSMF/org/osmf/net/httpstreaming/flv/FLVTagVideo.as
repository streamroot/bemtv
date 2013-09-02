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
	public class FLVTagVideo extends FLVTag
	{
		public static const FRAME_TYPE_KEYFRAME:int = 1;
		public static const FRAME_TYPE_INTER:int = 2;
		public static const FRAME_TYPE_DISPOSABLE_INTER:int = 3;
		public static const FRAME_TYPE_GENERATED_KEYFRAME:int = 4;
		public static const FRAME_TYPE_INFO:int = 5;
		
		public static const CODEC_ID_JPEG:int = 1;
		public static const CODEC_ID_SORENSON:int = 2;
		public static const CODEC_ID_SCREEN:int = 3;
		public static const CODEC_ID_VP6:int = 4;
		public static const CODEC_ID_VP6_ALPHA:int = 5;
		public static const CODEC_ID_SCREEN_V2:int = 6;
		public static const CODEC_ID_AVC:int = 7;
		
		public static const AVC_PACKET_TYPE_SEQUENCE_HEADER:int = 0;
		public static const AVC_PACKET_TYPE_NALU:int = 1;
		public static const AVC_PACKET_TYPE_END_OF_SEQUENCE:int = 2;
		
		public static const INFO_PACKET_SEEK_START:int = 0;
		public static const INFO_PACKET_SEEK_END:int = 1;
		
		public function FLVTagVideo(type:int = FLVTag.TAG_TYPE_VIDEO)
		{
			super(type);
		}
		
		public function get frameType():int
		{
			return (bytes[TAG_HEADER_BYTE_COUNT + 0] >> 4) & 0x0f;
		}
		
		public function set frameType(value:int):void
		{
			bytes[TAG_HEADER_BYTE_COUNT + 0] &= 0x0f;	// clear top 4 bits
			bytes[TAG_HEADER_BYTE_COUNT + 0] |= (value & 0x0f) << 4;
		}
		
		public function get codecID():int
		{
			return (bytes[TAG_HEADER_BYTE_COUNT + 0] & 0x0f);
		}
		
		public function set codecID(value:int):void
		{
			bytes[TAG_HEADER_BYTE_COUNT + 0] &= 0xf0;	// clear bottom 4 bits
			bytes[TAG_HEADER_BYTE_COUNT + 0] |= (value & 0x0f);			
		}
		
		public function get infoPacketValue():int
		{
			if (frameType != FRAME_TYPE_INFO)
			{
				throw new Error("get infoPacketValue() not permitted unless frameType is FRAME_TYPE_INFO");
			}
			
			return bytes[TAG_HEADER_BYTE_COUNT + 1];
		}
		
		public function set infoPacketValue(value:int):void
		{
			if (frameType != FRAME_TYPE_INFO)
			{
				throw new Error("get infoPacketValue() not permitted unless frameType is FRAME_TYPE_INFO");
			}
			
			bytes[TAG_HEADER_BYTE_COUNT + 1] = value;
			bytes.length = TAG_HEADER_BYTE_COUNT + 2;	// one of format, one more byte of info
			dataSize = 2;
		}
	
		public function get avcPacketType():int
		{
			// throw error if frameType == FRAME_TYPE_INFO?
			if (codecID != CODEC_ID_AVC)
			{
				throw new Error("get avcPacketType() not permitted unless codecID is CODEC_ID_AVC");
			}
			
			return bytes[TAG_HEADER_BYTE_COUNT + 1];
		}
		
		public function set avcPacketType(value:int):void
		{
			// throw error if frameType == FRAME_TYPE_INFO?
			if (codecID != CODEC_ID_AVC)
			{
				throw new Error("set avcPacketType() not permitted unless codecID is CODEC_ID_AVC");
			}
			
			bytes[TAG_HEADER_BYTE_COUNT + 1] = value;
			if (avcPacketType != AVC_PACKET_TYPE_NALU)
			{
				// zero the composition time offset
				bytes[TAG_HEADER_BYTE_COUNT + 2] = 0;
				bytes[TAG_HEADER_BYTE_COUNT + 3] = 0;
				bytes[TAG_HEADER_BYTE_COUNT + 4] = 0;
				
				// and truncate packet
				bytes.length = TAG_HEADER_BYTE_COUNT + 5; // one of format, one avc packet type, 3 of comp time offset
				dataSize = 5;
			}
		}
		
		public function get avcCompositionTimeOffset():int
		{
			// throw error if frameType == FRAME_TYPE_INFO?
			if ((codecID != CODEC_ID_AVC) || (avcPacketType != AVC_PACKET_TYPE_NALU))
			{
				throw new Error("get avcCompositionTimeOffset() not permitted unless codecID is CODEC_ID_AVC and avcPacketType is AVC NALU");
			}	
			
			var value:int = bytes[TAG_HEADER_BYTE_COUNT + 2] << 16;
			value |= bytes[TAG_HEADER_BYTE_COUNT + 3] << 8;
			value |= bytes[TAG_HEADER_BYTE_COUNT + 4];
			if (value & 0x00800000)
			{
				value |= 0xff000000;	// sign-extend the 24-bit read for a 32-bit int
			}
			
			return value;
		}
		
		public function set avcCompositionTimeOffset(value:int):void
		{
			// throw error if frameType == FRAME_TYPE_INFO?
			if ((codecID != CODEC_ID_AVC) || (avcPacketType != AVC_PACKET_TYPE_NALU))
			{
				throw new Error("set avcCompositionTimeOffset() not permitted unless codecID is CODEC_ID_AVC and avcPacketType is AVC NALU");
			}	
			
			bytes[TAG_HEADER_BYTE_COUNT + 2] = (value >> 16) & 0xff;
			bytes[TAG_HEADER_BYTE_COUNT + 3] = (value >> 8) & 0xff;
			bytes[TAG_HEADER_BYTE_COUNT + 4] = (value) & 0xff;	
		}
		
		override public function get data():ByteArray
		{
			// throw error if frameType == FRAME_TYPE_INFO?
			var data:ByteArray = new ByteArray();
			if (codecID == CODEC_ID_AVC)
			{
				data.writeBytes(bytes, TAG_HEADER_BYTE_COUNT + 5, dataSize - 5);	// just the AVC payload
			}
			else
			{
				data.writeBytes(bytes, TAG_HEADER_BYTE_COUNT + 1, dataSize - 1);	// just the video payload, not the format
			}
			return data;		
		}	
	
		override public function set data(value:ByteArray):void
		{
			// throw error if frameType == FRAME_TYPE_INFO?
			if (codecID == CODEC_ID_AVC)
			{
				bytes.length = TAG_HEADER_BYTE_COUNT + value.length + 5;	// resize array first
				bytes.position = TAG_HEADER_BYTE_COUNT + 5;
				bytes.writeBytes(value, 0, value.length); // copy in after format, AVC packet type, and composition time offset
				dataSize = value.length + 5;	// set dataSize field to new payload length plus format, AVC packet type, and composition time offset length
			}
			else
			{
				bytes.length = TAG_HEADER_BYTE_COUNT + value.length + 1;	// resize array first
				bytes.position = TAG_HEADER_BYTE_COUNT + 1;
				bytes.writeBytes(value, 0, value.length); // copy in after format
				dataSize = value.length + 1;	// set dataSize field to new payload length plus format length
			}	
		}
	}
}