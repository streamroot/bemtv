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
	public class FLVHeader
	{
		public static const MIN_FILE_HEADER_BYTE_COUNT:int = 9;

		public function FLVHeader(input:IDataInput=null)
		{
			super();
			
			if (input != null)
			{
				readHeader(input);
				readRest(input);
			}
		}
		
		public function get hasAudioTags():Boolean
		{
			return _hasAudioTags;
		}
		
		public function set hasAudioTags(value:Boolean):void
		{
			_hasAudioTags = value;
		}
		
		public function get hasVideoTags():Boolean
		{
			return _hasVideoTags;
		}
		
		public function set hasVideoTags(value:Boolean):void
		{
			_hasVideoTags = value;
		}
		
		public function write(output:IDataOutput):void
		{
			output.writeByte(0x46);	// 'F'
			output.writeByte(0x4c); // 'L'
			output.writeByte(0x56); // 'V'
			output.writeByte(0x01); // version 0x01
			
			var flags:uint = 0;
			if (_hasAudioTags)
			{
				flags |= 0x04;
			}
			if (_hasVideoTags)
			{
				flags |= 0x01;
			}
			
			output.writeByte(flags);
			
			var offsetToWrite:uint = MIN_FILE_HEADER_BYTE_COUNT;	// standard length
			
			output.writeUnsignedInt(offsetToWrite);
			
			var previousTagSize0:uint = 0;
			
			output.writeUnsignedInt(previousTagSize0);
		}
		
		// Internals
		//
		
		/**
		 * @private
		 */
		internal function readHeader(input:IDataInput):void
		{
			if (input.bytesAvailable < MIN_FILE_HEADER_BYTE_COUNT)
			{
				throw new Error("FLVHeader() input too short");
			}
				
			if (input.readByte() != 0x46)
			{
				throw new Error("FLVHeader readHeader() Signature[0] not 'F'");
			}
			if (input.readByte() != 0x4c)
			{
			 	throw new Error("FLVHeader readHeader() Signature[1] not 'L'");
			}
			if (input.readByte() != 0x56)
			{
				throw new Error("FLVHeader readHeader() Signature[2] not 'V'");
			}
			
			if (input.readByte() != 0x01)
			{
				throw new Error("FLVHeader readHeader() Version not 0x01");
			}
			
			var flags:int = input.readByte();
			
			_hasAudioTags = (flags & 0x04) ? true : false;
			_hasVideoTags = (flags & 0x01) ? true : false;

			offset = input.readUnsignedInt();
			
			if (offset < MIN_FILE_HEADER_BYTE_COUNT)
			{
				throw new Error("FLVHeader() offset smaller than minimum");
			}
		}
		
		/**
		 * @private
		 */
		internal function readRest(input:IDataInput):void
		{
			if (offset > MIN_FILE_HEADER_BYTE_COUNT)
			{
				// Most FLV files don't have headers longer than standard, so
				// this is rarely (if ever) used, thus the if.
				
				if ((offset - MIN_FILE_HEADER_BYTE_COUNT) < (input.bytesAvailable - FLVTag.PREV_TAG_BYTE_COUNT))
				{
					throw new Error("FLVHeader() input too short for nonstandard offset");
				}
					
				var discard:ByteArray = new ByteArray();
				input.readBytes(discard, 0, offset - MIN_FILE_HEADER_BYTE_COUNT);
			}
			
			if (input.bytesAvailable < FLVTag.PREV_TAG_BYTE_COUNT)
			{
				throw new Error("FLVHeader() input too short for previousTagSize0");
			}
				
			input.readUnsignedInt(); 	// discard PreviousTagSize0
		}
		
		/**
		 * @private
		 */
		internal function get restBytesNeeded():int
		{
			return FLVTag.PREV_TAG_BYTE_COUNT + (offset - MIN_FILE_HEADER_BYTE_COUNT);
		}
		
		/**
		 * @private
		 */
		
		private var _hasVideoTags:Boolean = true;
		private var _hasAudioTags:Boolean = true;
		private var offset:uint;
	}
}