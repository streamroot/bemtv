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
	
	import org.denivip.osmf.logging.HLSLogger;
	import org.osmf.logging.Log;
	import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
	
	[Event(name="notifySegmentDuration", type="org.osmf.events.HTTPStreamingFileHandlerEvent")]
	[Event(name="notifyTimeBias", type="org.osmf.events.HTTPStreamingFileHandlerEvent")]	
	

	public class HTTPStreamingMP2TSFileHandler extends HTTPStreamingFileHandlerBase
	{
		private var _syncFound:Boolean;
		private var _pmtPID:uint;
		private var _audioPID:uint;
		private var _videoPID:uint;
		private var _audioPES:HTTPStreamingMP2PESAudio;
		private var _videoPES:HTTPStreamingMP2PESVideo;
		
		private var _initialOffset:Number = NaN;
		
		private var _cachedOutputBytes:ByteArray;
		private var alternatingYieldCounter:int = 0;
		
		public function HTTPStreamingMP2TSFileHandler()
		{
			_audioPES = new HTTPStreamingMP2PESAudio;
			_videoPES = new HTTPStreamingMP2PESVideo;
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
			/*while(true)
			{
				if(!_syncFound)
				{
					if(input.bytesAvailable < 1)
						return null;
					
					if(input.readByte() == 0x47)
						_syncFound = true;
				}
				else
				{
					if(input.bytesAvailable < 187)
						return null;
					
					_syncFound = false;
					var packet:ByteArray = new ByteArray();
				
					input.readBytes(packet, 0, 187);
				
					return processPacket(packet);	
				}
			}
			return null;*/
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
					if(input.bytesAvailable < 1)
						break;
					
					if(input.readByte() == 0x47)
						_syncFound = true;
				}
				else
				{
					if(input.bytesAvailable < 187)
						break;
					
					_syncFound = false;
					var packet:ByteArray = new ByteArray();
					
					input.readBytes(packet, 0, 187);
					
					var result:ByteArray = processPacket(packet);
					if (result !== null) {
						output.writeBytes(result);
					}
					
					if (bytesAvailableStart - input.bytesAvailable > 10000) {
						alternatingYieldCounter = (alternatingYieldCounter + 1) & 0x03;
						if (alternatingYieldCounter & 0x01 === 1) {
							_cachedOutputBytes = output;
							return null;
						}
						break;
					}
				}
			}
			return output.length === 0 ? null : output;
		}
			
		override public function endProcessFile(input:IDataInput):ByteArray
		{
			return null;	
		}
		
		public function resetCache():void{
			_cachedOutputBytes = null;
			alternatingYieldCounter = 0;
		}
		
		public function get initialOffset():Number{
			if(!isNaN(_initialOffset))
				return _initialOffset;
			else
				return 0;
		}
		
		private function processPacket(packet:ByteArray):ByteArray
		{
			// decode rest of transport stream prefix (after the 0x47 flag byte)
			
			// top of second byte
			var value:uint = packet.readUnsignedByte();
			
			var tei:Boolean = Boolean(value & 0x80);	// error indicator
			var pusi:Boolean = Boolean(value & 0x40);	// payload unit start indication
			var tpri:Boolean = Boolean(value & 0x20);	// transport priority indication
			
			// bottom of second byte and all of third
			value <<= 8;
			value += packet.readUnsignedByte();
			
			var pid:uint = value & 0x1fff;	// packet ID
			
			// fourth byte
			value = packet.readUnsignedByte();
			var scramblingControl:uint = (value >> 6) & 0x03;	// scrambling control bits
			var hasAF:Boolean = Boolean(value & 0x20);	// has adaptation field
			var hasPD:Boolean = Boolean(value & 0x10);	// has payload data
			var ccount:uint = value & 0x0f;		// continuty count
			
			// technically hasPD without hasAF is an error, see spec
			
			if(hasAF)
			{
				// process adaptation field

				var afLen:uint = packet.readUnsignedByte();
				
				// don't care about flags
				// don't care about clocks here
				
				packet.position += afLen;	// skip to end
			}
			
			if(hasPD)
			{
				return processES(pid, pusi, packet);
			}
			else
			{
				return null;
			}
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
				
				if(isNaN(_initialOffset))
					_initialOffset = _audioPES.timestamp/1000;
			}
			else if(pid == _videoPID)
			{
				output = _videoPES.processES(pusi, packet);
				
				if(isNaN(_initialOffset))
					_initialOffset = _videoPES.timestamp/1000;
			}
			
			return output;
		}
		
		private function processPAT(packet:ByteArray):void
		{
			var pointer:uint = packet.readUnsignedByte();
			var tableID:uint = packet.readUnsignedByte();
			
			var sectionLen:uint = packet.readUnsignedShort() & 0x03ff; // ignoring misc and reserved bits
			var remaining:uint = sectionLen;
			
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
			var pointer:uint = packet.readUnsignedByte();
			var tableID:uint = packet.readUnsignedByte();
			
			if (tableID != 0x02)
			{
				CONFIG::LOGGING
				{
					logger.warn("PAT pointed to PMT that isn't PMT");
				}
				return; // don't try to parse it
			}
			var sectionLen:uint = packet.readUnsignedShort() & 0x03ff; // ignoring section syntax and reserved
			var remaining:uint = sectionLen;
			
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
				
					// need to add MP3 Audio  (3 & 4)
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
			var flvBytesVideo:ByteArray = null;
			var flvBytesAudio:ByteArray = null;
			

			flvBytesVideo = _videoPES.processES(false, null, true);

			flvBytesAudio = _audioPES.processES(false, null, true);
		
			
			if(flvBytesVideo)
				flvBytes.readBytes(flvBytesVideo);
			if(flvBytesAudio)
				flvBytes.readBytes(flvBytesAudio);
			
			return flvBytes;
		}
		
		CONFIG::LOGGING
		{
			private var logger:HLSLogger = Log.getLogger('org.denivip.osmf.net.httpstreaming.hls.HTTPStreamingMP2TSFileHandler') as HLSLogger;
		}
	}
}
