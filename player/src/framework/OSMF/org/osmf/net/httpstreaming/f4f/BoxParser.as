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
package org.osmf.net.httpstreaming.f4f
{
	import __AS3__.vec.Vector;
	
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
		
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
		import org.osmf.logging.Log;
	}

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The parser that takes byte array and converts into a list of boxes in sequence.
	 */
	internal class BoxParser extends EventDispatcher
	{
		/**
		 * Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function BoxParser()
		{
			super();
			
			_ba = null;
		}

		/**
		 * Set bytes to be parsed upon.
		 * 
		 * @param ba The byte array to be parsed upon.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function init(ba:ByteArray):void
		{
			_ba = ba;
			_ba.position = 0;
		}
		
		/**
		 * Read a 4 byte unsigned integer and a 4 byte string from the byte array, construct
		 * and return a BoxInfo object
		 * 
		 * @return a BoxInfo object
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getNextBoxInfo():BoxInfo
		{
			if (_ba == null || _ba.bytesAvailable < F4FConstants.FIELD_SIZE_LENGTH + F4FConstants.FIELD_TYPE_LENGTH)
			{
				return null;
			}
			
			var size:Number = _ba.readUnsignedInt();
			var type:String = _ba.readUTFBytes(F4FConstants.FIELD_TYPE_LENGTH);

			return new BoxInfo(size, type);
		}
		
		/**
		 * Parse and return a list of root level boxes in the order
		 * of the boxes in the byte array.
		 * 
		 * @return the list of root level boxes.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getBoxes():Vector.<Box>
		{
			var boxes:Vector.<Box> = new Vector.<Box>();
			var bi:BoxInfo = getNextBoxInfo();
			while (bi != null)
			{
				if (bi.type == F4FConstants.BOX_TYPE_ABST)
				{
					var abst:AdobeBootstrapBox = new AdobeBootstrapBox();
					parseAdobeBootstrapBox(bi, abst);
					boxes.push(abst);
				}
				else if (bi.type == F4FConstants.BOX_TYPE_AFRA)
				{
					var afra:AdobeFragmentRandomAccessBox = new AdobeFragmentRandomAccessBox();
					parseAdobeFragmentRandomAccessBox(bi, afra);
					boxes.push(afra);
				}
				else if (bi.type == F4FConstants.BOX_TYPE_MDAT)
				{
					var mdat:MediaDataBox = new MediaDataBox();
					parseMediaDataBox(bi, mdat);
					boxes.push(mdat);
				}
				else
				{
					_ba.position = _ba.position + bi.size - (F4FConstants.FIELD_SIZE_LENGTH + F4FConstants.FIELD_TYPE_LENGTH);
				}
				
				bi = getNextBoxInfo();
				if (bi != null && bi.size <= 0)
				{
					break;
				}
			}
			
			return boxes;
		}
		
		/**
		 * Parse and returns AFRA
		 * 
		 * @return AFRA if the current byte array from the current position is indeed an AFRA, null otherwise.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function readFragmentRandomAccessBox(bi:BoxInfo):AdobeFragmentRandomAccessBox
		{
			var afra:AdobeFragmentRandomAccessBox = new AdobeFragmentRandomAccessBox();
			parseAdobeFragmentRandomAccessBox(bi, afra);
			return afra;
		}
		
		/**
		 * Parse and returns ABST
		 * 
		 * @return ABST if the current byte array from the current position is indeed an ABST, null otherwise.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function readAdobeBootstrapBox(bi:BoxInfo):AdobeBootstrapBox
		{
			var abst:AdobeBootstrapBox = new AdobeBootstrapBox();
			this.parseAdobeBootstrapBox(bi, abst);
			return abst;
		}
		
		// Internals
		//
		
		/**
		 * Reads 8 bytes from the byte array, treats the 8 bytes as an long integer and pack the values
		 * into a Number. This is a little tricky since ActionScript does not have a long integer type. 
		 * The solution is to read an unsigned integer which is 4 bytes long, times the unsigned integer
		 * by 2^32, and assign the value to a Number. Next, read the next unsigned integer, and then 
		 * add the new unsigned integer to the existing number.
		 * 
		 * @return the number that is created from the 8 bytes read from the byte array at the current position.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		internal function readLongUIntToNumber():Number
		{
			if (_ba == null || _ba.bytesAvailable < 8)
			{
				CONFIG::LOGGING
				{
					logger.error( "******* not enough length for readLongUIntToNumer" );
					logger.error( "******* probable cause: malformed BOOTSTRAP data" );
				}
				
				throw new IllegalOperationError("not enough length for readLongUIntToNumer");
			}
			
			var result:Number = _ba.readUnsignedInt();
			result *= 4294967296.0;
			result += _ba.readUnsignedInt();
			
			return result;
		}
		
		/**
		 * Reads and returns an unsigned integer from the byte array at the current position.
		 * 
		 * @return an unsigned integer.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function readUnsignedInt():uint
		{
			if (_ba == null || _ba.bytesAvailable < 4)
			{
				CONFIG::LOGGING
				{
					logger.error( "******* not enough length for readUnsignedInt" );
					logger.error( "******* probable cause: malformed BOOTSTRAP data" );
				}
				
				throw new IllegalOperationError("not enough length for readUnsignedInt");
			}
			
			return _ba.readUnsignedInt();
		}
	
		
		/**
		 * Reads the number of data bytes, specified by the length parameter, from the byte stream. 
		 * The bytes are read into the ByteArray object specified by the bytes parameter, and the 
		 * bytes are written into the destination ByteArray starting at the position specified by offset.
		 * 
		 * @param bytes The ByteArray object to read data into.
		 * @param offset The offset (position) in bytes at which the read data should be written.
		 * @param length The number of bytes to read. The default value of 0 causes all available data to be read.  
		 * 
		 * @throws IllegalOperaitonError There is not sufficient data available to read.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function readBytes(bytes:ByteArray, offset:uint = 0, length:uint = 0):void
		{
			if (_ba == null || _ba.bytesAvailable < length)
			{ 
				CONFIG::LOGGING
				{
					logger.error( "******* not enough length for readBytes: " + length );
					logger.error( "******* probable cause: malformed BOOTSTRAP data" );
				}
				
				throw new IllegalOperationError("not enough length for readBytes: " + length);
			}
			
			return _ba.readBytes(bytes, offset, length);
		}
		
		/**
		 * Reads an unsigned byte from the byte stream. The returned value is in the range 0 to 255. 
		 * 
		 * @return A 32-bit unsigned integer between 0 and 255.
		 *  
		 * @throws IllegalOperaitonError There is not sufficient data available to read.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function readUnsignedByte():uint
		{
			if (_ba == null || _ba.bytesAvailable < 1)
			{
				CONFIG::LOGGING
				{
					logger.error( "not enough length for readUnsingedByte" );
					logger.error( "******* probable cause: malformed BOOTSTRAP data" );
				}
				
				throw new IllegalOperationError("not enough length for readUnsingedByte");
			}
			
			return _ba.readUnsignedByte();
		}
		
		/**
		 * Read a number of bytes, treat them as bytes of an unsigned integer and return the uint. 
		 * The number of bytes must be between 0 and 4.
		 * 
		 * @return A 32-bit unsigned integer converted from the list of bytes.
		 *  
		 * @throws IllegalOperaitonError There is not sufficient data available to read.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function readBytesToUint(length:uint):uint
		{
			if (_ba == null || _ba.bytesAvailable < length)
			{
				CONFIG::LOGGING
				{
					logger.error( "not enough length for readUnsingedByte" );
					logger.error( "******* probable cause: malformed BOOTSTRAP data" );
				}
				
				throw new IllegalOperationError("not enough length for readUnsingedByte");
			}
			
			if (length > 4) 
			{
				CONFIG::LOGGING
				{
					logger.error( "length for readUnsingedByte must be equal or less than 4 bytes; length: " + length );
					logger.error( "******* probable cause: malformed BOOTSTRAP data" );
				}
				
				throw new IllegalOperationError("number of bytes to read must be equal or less than 4");
			}
	
			var result:uint = 0;
			for (var i:uint = 0; i < length; i++)
			{
				result = (result << 8);		
				var byte:uint = _ba.readUnsignedByte();
				result += byte;
			}
			
			return result;
		}

		/**
		 * Read a null terminated string.
		 * 
		 * @return the null terminated string.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		private function readString():String
		{
			var pos:uint = _ba.position;
			while (_ba.position < _ba.length)
			{
				var c:uint = _ba.readByte();
				if (c == 0)
				{
					break;
				}
			}
			
			var length:uint = _ba.position - pos;
			_ba.position = pos;
			return _ba.readUTFBytes(length);
		}
		
		// Internal
		//

		private function parseBox(boxInfo:BoxInfo, box:Box):void
		{
			var size:Number = boxInfo.size;
			var boxLength:uint = F4FConstants.FIELD_SIZE_LENGTH + F4FConstants.FIELD_TYPE_LENGTH;

			if (boxInfo.size == F4FConstants.FLAG_USE_LARGE_SIZE)
			{
				size = readLongUIntToNumber();
				boxLength += F4FConstants.FIELD_LARGE_SIZE_LENGTH;
			}
			if (boxInfo.type == F4FConstants.EXTENDED_TYPE)
			{
				// Read past the extended type.
				var extendedType:ByteArray = new ByteArray();
				readBytes(extendedType, 0, F4FConstants.FIELD_EXTENDED_TYPE_LENGTH);
				
				boxLength += F4FConstants.FIELD_EXTENDED_TYPE_LENGTH;
			}
			
			box.size = size;
			box.type = boxInfo.type;
			box.boxLength = boxLength;
		}
		
		private function parseFullBox(boxInfo:BoxInfo, fullBox:FullBox):void
		{
			parseBox(boxInfo, fullBox);
			
			fullBox.version = readUnsignedByte();
			fullBox.flags = readBytesToUint(FULL_BOX_FIELD_FLAGS_LENGTH);
		}
		
		private function parseAdobeBootstrapBox(boxInfo:BoxInfo, abst:AdobeBootstrapBox):void
		{
			parseFullBox(boxInfo, abst);
			
			abst.bootstrapVersion = readUnsignedInt();

			var temp:uint = readUnsignedByte();
			
			abst.profile = (temp >> 6);
			abst.live = ((temp & 0x20) == 0x20);
			abst.update = ((temp & 0x1) == 0x1);
			
			abst.timeScale = readUnsignedInt();
			abst.currentMediaTime = readLongUIntToNumber();
			abst.smpteTimeCodeOffset = readLongUIntToNumber();
			abst.movieIdentifier = readString();

			var serverEntryCount:uint = readUnsignedByte();
			var serverBaseURLs:Vector.<String> = new Vector.<String>();
			for (var i:int = 0; i < serverEntryCount; i++)
			{
				serverBaseURLs.push(readString());
			}
			abst.serverBaseURLs = serverBaseURLs;
			
			var qualityEntryCount:uint = readUnsignedByte();
			var qualitySegmentURLModifiers:Vector.<String> = new Vector.<String>();
			for (i = 0; i < qualityEntryCount; i++)
			{
				qualitySegmentURLModifiers.push(readString());
			}
			abst.qualitySegmentURLModifiers = qualitySegmentURLModifiers;
			
			abst.drmData = readString();
			abst.metadata = readString();

			var segmentRunTableCount:uint = readUnsignedByte();
			var segmentRunTables:Vector.<AdobeSegmentRunTable> = new Vector.<AdobeSegmentRunTable>();
			for (i = 0; i < segmentRunTableCount; i++)
			{
				boxInfo = getNextBoxInfo();
				if (boxInfo.type == F4FConstants.BOX_TYPE_ASRT)
				{
					var asrt:AdobeSegmentRunTable = new AdobeSegmentRunTable();
					parseAdobeSegmentRunTable(boxInfo, asrt);
					segmentRunTables.push(asrt);
				}
				else
				{
					CONFIG::LOGGING
					{
						logger.error( "Unexpected data structure: " + boxInfo.type );
						logger.error( "******* probable cause: malformed BOOTSTRAP data" );
					}
					
					throw new IllegalOperationError("Unexpected data structure: " + boxInfo.type);
				}
			}
			abst.segmentRunTables = segmentRunTables;
			
			var fragmentRunTableCount:uint = readUnsignedByte();
			var fragmentRunTables:Vector.<AdobeFragmentRunTable> = new Vector.<AdobeFragmentRunTable>();
			for (i = 0; i < fragmentRunTableCount; i++)
			{
				boxInfo = getNextBoxInfo();
				if (boxInfo.type == F4FConstants.BOX_TYPE_AFRT)
				{
					var afrt:AdobeFragmentRunTable = new AdobeFragmentRunTable();
					parseAdobeFragmentRunTable(boxInfo, afrt);
					fragmentRunTables.push(afrt);
				}
				else
				{
					CONFIG::LOGGING
					{
						logger.error( "Unexpected data structure: " + boxInfo.type );
						logger.error( "******* probable cause: malformed BOOTSTRAP data" );
					}
					
					throw new IllegalOperationError("Unexpected data structure: " + boxInfo.type);
				}
			}
			abst.fragmentRunTables = fragmentRunTables;
		}
		
		private function parseAdobeSegmentRunTable(boxInfo:BoxInfo, asrt:AdobeSegmentRunTable):void
		{
			parseFullBox(boxInfo, asrt);
			
			var qualityEntryCount:uint = readUnsignedByte();
			var qualitySegmentURLModifiers:Vector.<String> = new Vector.<String>();
			for (var i:uint = 0; i < qualityEntryCount; i++)
			{
				qualitySegmentURLModifiers.push(readString());
			}
			asrt.qualitySegmentURLModifiers = qualitySegmentURLModifiers;
			
			var entryCount:uint = readUnsignedInt();
			for (i = 0; i < entryCount; i++)
			{
				asrt.addSegmentFragmentPair(new SegmentFragmentPair(readUnsignedInt(), readUnsignedInt()));
			}
		}

		private function parseAdobeFragmentRunTable(boxInfo:BoxInfo, afrt:AdobeFragmentRunTable):void
		{
			parseFullBox(boxInfo, afrt);
			
			afrt.timeScale = readUnsignedInt();
			
			var qualityEntryCount:uint = readUnsignedByte();
			var qualitySegmentURLModifiers:Vector.<String> = new Vector.<String>();
			for (var i:uint = 0; i < qualityEntryCount; i++)
			{
				qualitySegmentURLModifiers.push(readString());
			}
			afrt.qualitySegmentURLModifiers = qualitySegmentURLModifiers;
			
			var entryCount:uint = readUnsignedInt();
			for (i = 0; i < entryCount; i++)
			{
				var fdp:FragmentDurationPair = new FragmentDurationPair();
				parseFragmentDurationPair(fdp);
				afrt.addFragmentDurationPair(fdp);
			}
		}
		
		private function parseFragmentDurationPair(fdp:FragmentDurationPair):void
		{
			fdp.firstFragment = readUnsignedInt();
			fdp.durationAccrued = readLongUIntToNumber();
			fdp.duration = readUnsignedInt();
			
			if (fdp.duration == 0)
			{
				fdp.discontinuityIndicator = readUnsignedByte();
			}
			
//			CONFIG::LOGGING
//			{
//				logger.debug("    firstFragment=" + fdp.firstFragment + 
//					"  duration=" + fdp.duration + 
//					"  durationAccrued=" + fdp.durationAccrued +
//					"  discontinuityIndicator=" + fdp.discontinuityIndicator);
//			}
		}
		
		private function parseAdobeFragmentRandomAccessBox(boxInfo:BoxInfo, afra:AdobeFragmentRandomAccessBox):void
		{
			parseFullBox(boxInfo, afra);
			
			var sizes:uint = readBytesToUint(1);
			var longIdFields:Boolean = ((sizes & AFRA_MASK_LONG_ID) > 0);
			var longOffsetFields:Boolean = ((sizes & AFRA_MASK_LONG_OFFSET) > 0);
			var globalEntries:Boolean = ((sizes & AFRA_MASK_GLOBAL_ENTRIES) > 0);
			
			afra.timeScale = readUnsignedInt();
			
//			CONFIG::LOGGING
//			{
//				logger.debug("------------------- AFRA -------------------");
//				
//				logger.debug(" timeScale=" + afra.timeScale);
//			}

			var entryCount:uint = readUnsignedInt();
			
			var localRandomAccessEntries:Vector.<LocalRandomAccessEntry> = new Vector.<LocalRandomAccessEntry>();
			for (var i:uint = 0; i < entryCount; i++)
			{
				var lrae:LocalRandomAccessEntry = new LocalRandomAccessEntry();
				parseLocalRandomAccessEntry(lrae, longOffsetFields);
				localRandomAccessEntries.push(lrae);
			}
			afra.localRandomAccessEntries = localRandomAccessEntries;
			
			var globalRandomAccessEntries:Vector.<GlobalRandomAccessEntry> = new Vector.<GlobalRandomAccessEntry>();
			if (globalEntries)
			{
				entryCount = readUnsignedInt();
				for (i = 0; i < entryCount; i++)
				{
					var grae:GlobalRandomAccessEntry = new GlobalRandomAccessEntry();
					parseGlobalRandomAccessEntry(grae, longIdFields, longOffsetFields);
					globalRandomAccessEntries.push(grae);
				}
			}
			afra.globalRandomAccessEntries = globalRandomAccessEntries;
		}
		
		private function parseLocalRandomAccessEntry(lrae:LocalRandomAccessEntry, longOffsetFields:Boolean):void
		{
			lrae.time = readLongUIntToNumber();
			if (longOffsetFields)
			{
				lrae.offset = readLongUIntToNumber();
			}
			else
			{
				lrae.offset = readUnsignedInt();
			}
			
//			CONFIG::LOGGING
//			{
//				logger.debug("    time=" + lrae.time + "   offset=" + lrae.offset);
//			}
		}

		private function parseGlobalRandomAccessEntry(grae:GlobalRandomAccessEntry, longIdFields:Boolean, longOffsetFields:Boolean):void
		{
			grae.time = readLongUIntToNumber();

			if (longIdFields)
			{
				grae.segment = readUnsignedInt();
				grae.fragment = readUnsignedInt();
			}
			else
			{
				grae.segment = readBytesToUint(2);
				grae.fragment = readBytesToUint(2);
			}
			
			if (longOffsetFields)
			{
				grae.afraOffset = readLongUIntToNumber();
				grae.offsetFromAfra = readLongUIntToNumber();
			}
			else
			{
				grae.afraOffset = readUnsignedInt();
				grae.offsetFromAfra = readUnsignedInt();
			}
			
//			CONFIG::LOGGING
//			{
//				logger.debug(
//					"    time=" + grae.time + 
//					"   segment=" + grae.segment + 
//					"   fragment=" + grae.fragment + 
//					"   afraOffset=" + grae.afraOffset + 
//					"   offsetFromAfra=" + grae.offsetFromAfra);
//			}
		}
		
		private function parseMediaDataBox(boxInfo:BoxInfo, mdat:MediaDataBox):void
		{
			parseBox(boxInfo, mdat);
			
			var data:ByteArray = new ByteArray();
			readBytes(data, 0, mdat.size - mdat.boxLength);
			mdat.data = data;
		}
		
		private var _ba:ByteArray;
		
		private static const FULL_BOX_FIELD_FLAGS_LENGTH:uint = 3;
		private static const AFRA_MASK_LONG_ID:uint = 128;
		private static const AFRA_MASK_LONG_OFFSET:uint = 64;
		private static const AFRA_MASK_GLOBAL_ENTRIES:uint = 32;

		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.net.httpstreaming.f4f.BoxParser");;
		}
	}
}