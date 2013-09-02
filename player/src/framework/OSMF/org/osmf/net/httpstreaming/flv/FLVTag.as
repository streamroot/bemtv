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
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;

	[ExcludeClass]
	
	/**
	 * @private
	 */ 
  	public class FLVTag
	{
		// arguably these should move to their own class...
		public static const TAG_TYPE_AUDIO:int = 8;
		public static const TAG_TYPE_VIDEO:int = 9;
		public static const TAG_TYPE_SCRIPTDATAOBJECT:int = 18;
		
		// TODO: Do we call this "filtered" or "encrypted" or "DRM" or "protected"?
		public static const TAG_FLAG_ENCRYPTED:int = 0x20;
		public static const TAG_TYPE_ENCRYPTED_AUDIO:int = TAG_TYPE_AUDIO + TAG_FLAG_ENCRYPTED;
		public static const TAG_TYPE_ENCRYPTED_VIDEO:int = TAG_TYPE_VIDEO + TAG_FLAG_ENCRYPTED;
		public static const TAG_TYPE_ENCRYPTED_SCRIPTDATAOBJECT:int = TAG_TYPE_SCRIPTDATAOBJECT + TAG_FLAG_ENCRYPTED;
		
		// but these are good here...
		public static const TAG_HEADER_BYTE_COUNT:int = 11;
		public static const PREV_TAG_BYTE_COUNT:int = 4;
		
		public function FLVTag(type:int)
		{
			super();
			
			bytes = new ByteArray();
			bytes.length = TAG_HEADER_BYTE_COUNT;
			bytes[0] = type;
		}
		
		public function read(input:IDataInput):void
		{
			// Reads a complete Tag, overwriting type.
			readType(input);
			readRemainingHeader(input);
			readData(input);
			readPrevTag(input);		
		}
		
		public function readType(input:IDataInput):void
		{
			if (input.bytesAvailable < 1)
			{
				throw new Error("FLVTag.readType() input too short");
			}
			
			input.readBytes(bytes, 0, 1);	// just the type field, 1 byte
		}
		
		public function readRemaining(input:IDataInput):void
		{
			// Note that the TYPE must have already been read in order to
			// construct us.
			readRemainingHeader(input);
			readData(input);
			readPrevTag(input);		
		}
		
		public function readRemainingHeader(input:IDataInput):void
		{
			if (input.bytesAvailable < 10)
			{
				throw new Error("FLVTag.readHeader() input too short");
			}
			
			input.readBytes(bytes, 1, TAG_HEADER_BYTE_COUNT - 1);	// skipping type field at first byte
		}
		
		public function readData(input:IDataInput):void
		{
			if (dataSize > 0)
			{
				if (input.bytesAvailable < dataSize)
				{
					throw new Error("FLVTag().readData input shorter than dataSize");
				}
				
				input.readBytes(bytes, TAG_HEADER_BYTE_COUNT, dataSize); // starting immediately after header, for computed size
			}
		}
		
		public function readPrevTag(input:IDataInput):void
		{
			if (input.bytesAvailable < 4)
			{
				throw new Error("FLVTag.readPrevTag() input too short");
			}
			
			input.readUnsignedInt();	// discard, because we can regenerate and we also don't care if value is correct
		}
		
		public function write(output:IDataOutput):void
		{
			output.writeBytes(bytes, 0, TAG_HEADER_BYTE_COUNT + dataSize);
			output.writeUnsignedInt(TAG_HEADER_BYTE_COUNT + dataSize); // correct prevTagSize, even though many things don't care
		}
		
		public function get tagType():uint
		{
			return bytes[0];
		}
		
		public function set tagType(value:uint):void
		{
			bytes[0] = value;
		}
		
		public function get isEncrpted():Boolean
		{
			return((bytes[0] & TAG_FLAG_ENCRYPTED) ? true : false);
		}
		
		public function get dataSize():uint
		{
			return (bytes[1] << 16) | (bytes[2] << 8) | (bytes[3]);  
		}
		
		public function set dataSize(value:uint):void
		{
			bytes[1] = (value >> 16) & 0xff;
			bytes[2] = (value >> 8) & 0xff;
			bytes[3] = (value) & 0xff;
			bytes.length = TAG_HEADER_BYTE_COUNT + value;	// truncate/grow as necessary
		}
		
		public function get timestamp():uint
		{
			// noting the unusual order
			return (bytes[7] << 24) | (bytes[4] << 16) | (bytes[5] << 8) | (bytes[6]);
		}
		
		public function set timestamp(value:uint):void
		{
			bytes[7] = (value >> 24) & 0xff; // extended byte in unusual location
			bytes[4] = (value >> 16) & 0xff;
			bytes[5] = (value >> 8) & 0xff;
			bytes[6] = (value) & 0xff;
		}
		
		public function get data():ByteArray
		{
			var data:ByteArray = new ByteArray();
			data.writeBytes(bytes, TAG_HEADER_BYTE_COUNT, dataSize);
			return data;
		}		
		
		public function set data(value:ByteArray):void
		{
			bytes.length = TAG_HEADER_BYTE_COUNT + value.length;	// resize first
			bytes.position = TAG_HEADER_BYTE_COUNT;
			bytes.writeBytes(value, 0, value.length); // copy in
			dataSize = value.length;	// set dataSize field to new payload length
		}
		protected var bytes:ByteArray = null;
	}
}