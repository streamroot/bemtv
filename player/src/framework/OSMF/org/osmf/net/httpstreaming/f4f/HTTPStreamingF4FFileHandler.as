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
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.events.HTTPStreamingFileHandlerEvent;
	import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
	import org.osmf.net.httpstreaming.flv.FLVTag;
	
	CONFIG::LOGGING
	{			
		import org.osmf.logging.Log;
		import org.osmf.logging.Logger;
	}
	
	[ExcludeClass]

	/**
	 * @private
	 * 
	 * This is the actual implementation of HTTPStreamingFileHandlerBase. It handles 
	 * individual fragments of an F4V file.
	 */	
	public class HTTPStreamingF4FFileHandler extends HTTPStreamingFileHandlerBase
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function HTTPStreamingF4FFileHandler()
		{
			super();
			
		}
		
		/** 
		 * @private
		 */
		override public function beginProcessFile(seek:Boolean, seekTime:Number):void
		{
			_processRequestWasSeek = seek;
			_seekToTime = seek ? seekTime : 0;
			_bytesNeeded = F4FConstants.FIELD_SIZE_LENGTH + F4FConstants.FIELD_TYPE_LENGTH + F4FConstants.FIELD_LARGE_SIZE_LENGTH + F4FConstants.FIELD_EXTENDED_TYPE_LENGTH;
			_bytesReadSinceAfraStart = 0;
			_countingReadBytes = false;
			_boxInfoPending = true;
			_nextBox = null;
			
			// XXX Must be revisted 
			// [cdobre] It's only downhill from here...
			_bytesNeeded1 = F4FConstants.FIELD_SIZE_LENGTH + F4FConstants.FIELD_TYPE_LENGTH + F4FConstants.FIELD_LARGE_SIZE_LENGTH + F4FConstants.FIELD_EXTENDED_TYPE_LENGTH;
			_bytesReadSinceAfraStart1 = 0;
			_countingReadBytes1 = false;
			_boxInfoPending1 = true;
			_nextBox1 = null;
 
		}
		
		/**
		 * @private
		 */	
		override public function get inputBytesNeeded():Number
		{
			return _bytesNeeded;
		}
		
		/**
		 * @private
		 */		
		override public function processFileSegment(input:IDataInput):ByteArray
		{
			if (input.bytesAvailable < _bytesNeeded)
			{
				return null;
			}

			var returnByteArray:ByteArray = null;

			var bytesRead:Number = F4FConstants.FIELD_SIZE_LENGTH + F4FConstants.FIELD_TYPE_LENGTH;
						
			if (_boxInfoPending)
			{
				_ba = new ByteArray();
				
				input.readBytes(_ba, 0, bytesRead);
				if (_countingReadBytes)
				{
					_bytesReadSinceAfraStart += bytesRead;
				}
				
				_parser.init(_ba);
				_nextBox = _parser.getNextBoxInfo();
				if (_nextBox.size == F4FConstants.FLAG_USE_LARGE_SIZE)
				{
					bytesRead += F4FConstants.FIELD_LARGE_SIZE_LENGTH;
					
					_ba.position = 0;
					input.readBytes(_ba, 0, F4FConstants.FIELD_LARGE_SIZE_LENGTH);
					if (_countingReadBytes)
					{
						_bytesReadSinceAfraStart += F4FConstants.FIELD_LARGE_SIZE_LENGTH;
					}
					_nextBox.size = _parser.readLongUIntToNumber();
				}
				
				// TODO: Check for extended type too.
				
				_boxInfoPending = false;
				if (_nextBox.type == F4FConstants.BOX_TYPE_MDAT)
				{
					_bytesNeeded = 0;
					_mdatBytesPending = _nextBox.size - bytesRead;
				}
				else
				{
					_bytesNeeded = _nextBox.size - bytesRead;
					_mdatBytesPending = 0;
					if (_nextBox.type == F4FConstants.BOX_TYPE_AFRA)
					{
						_bytesReadSinceAfraStart = bytesRead;
						_countingReadBytes = true;
					}
				}
			}
			// otherwise, we are not waiting for BoxInfo but the actual box contents
			else if (_bytesNeeded > 0)
			{
				var pos:uint = _ba.position;
				input.readBytes(_ba, _ba.length, _nextBox.size - bytesRead);
				if (_countingReadBytes)
				{
					_bytesReadSinceAfraStart += (_nextBox.size - bytesRead);
				}
				_ba.position = pos;
				
				if (_nextBox.type == F4FConstants.BOX_TYPE_ABST)
				{
					var abst:AdobeBootstrapBox = _parser.readAdobeBootstrapBox(_nextBox);
					if (abst != null)
					{
						dispatchEvent(
							new HTTPStreamingFileHandlerEvent(
								HTTPStreamingFileHandlerEvent.NOTIFY_BOOTSTRAP_BOX, 
								false, 
								false, 
								0, 
								null, 
								null, 
								abst));
					}
				} 
				else if (_nextBox.type == F4FConstants.BOX_TYPE_AFRA)
				{
					_afra = _parser.readFragmentRandomAccessBox(_nextBox);
					processSeekToTime();
				}
				else if (_nextBox.type == F4FConstants.BOX_TYPE_MOOF)
				{
					// Don't need to do anything with a MOOF box, so skip and move on.
				}

				_bytesNeeded = F4FConstants.FIELD_SIZE_LENGTH + F4FConstants.FIELD_TYPE_LENGTH + F4FConstants.FIELD_LARGE_SIZE_LENGTH + F4FConstants.FIELD_EXTENDED_TYPE_LENGTH;
				_boxInfoPending = true;
				_nextBox = null;
			}
			else
			{
				returnByteArray = getMDATBytes(input, false);
			}
			
			return returnByteArray;
		}
		
		/**
		 * @private
		 */	
		override public function endProcessFile(input:IDataInput):ByteArray
		{
			if (this._bytesNeeded > 0)
			{
				CONFIG::LOGGING
				{			
					logger.error("_bytesNeeded: " + this._bytesNeeded );
					logger.error( "******* bytesNeeded bigger than expected potentially because fragment format is wrong!" );
				}
				
				dispatchEvent(
					new HTTPStreamingEvent(
						HTTPStreamingEvent.FILE_ERROR, 
						false, 
						false, 
						0, 
						null, 
						null
					)
				);
			}
			
			return getMDATBytes(input, true);
		}	

		/**
		 * @private
		 */	
		override public function flushFileSegment(input:IDataInput):ByteArray
		{
			return null;
		}
		
		// Internal
		//
		
		private function getMDATBytes(input:IDataInput, endOfFile:Boolean):ByteArray
		{
			if (input == null)
			{
				return null;
			}
			
			skipSeekBytes(input);
			
			var ba:ByteArray;
			if (_mdatBytesPending > 0)
			{
				var bytesToRead:uint = _mdatBytesPending < input.bytesAvailable? _mdatBytesPending : input.bytesAvailable;
				if (!endOfFile && bytesToRead > MAX_BYTES_PER_MDAT_READ)
				{
					bytesToRead = MAX_BYTES_PER_MDAT_READ;
				}
				ba = new ByteArray();
				_mdatBytesPending -= bytesToRead;
				input.readBytes(ba, 0, bytesToRead);
			}
			
			return ba;
		}
		
		private function skipSeekBytes(input:IDataInput):void
		{
			if (_bytesReadSinceAfraStart < _mdatBytesOffset)
			{
				var skip:uint = _mdatBytesOffset - _bytesReadSinceAfraStart;
				if (input.bytesAvailable < skip)
				{
					skip = input.bytesAvailable;
				}
				
				var ba:ByteArray = new ByteArray();
				input.readBytes(ba, 0, skip);
				_bytesReadSinceAfraStart += skip;
				_mdatBytesPending -= skip;
			}
		}
		
		/**
		 * File handler notifies HTTPNetStream of segment duration (fragment duration in
		 * f4f terminology) and time bias if it is actually a seek.
		 * 
		 * The segment duration can be known by the file index handler if there is no
		 * seek. Otherwise, file handler needs to consult the afra box to figure that out.
		 * This means that NOTIFY_SEGMENT_DURATION can be done from two places, which is 
		 * desirable. Therefore, we have only file handler report the segment duration.
		 * 
		 * For the seek case, segment duration is the duration of the whole segment minus
		 * the portion to be skipped.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function processSeekToTime():void
		{
			var timeBias:Number = 0;
			var entry:LocalRandomAccessEntry = null;
			
			if (_seekToTime <= 0)
			{
				_mdatBytesOffset = 0;
			}
			else
			{
				entry = getMDATBytesOffset(_seekToTime);
				if (entry != null)
				{
					_mdatBytesOffset = entry.offset;
					timeBias = entry.time;
				} 
				else
				{
					_mdatBytesOffset = 0;
				}
			}
		}
		
		private function getMDATBytesOffset(seekToTime:Number):LocalRandomAccessEntry
		{
			return (!isNaN(seekToTime))? _afra.findNearestKeyFrameOffset(seekToTime * _afra.timeScale) : null;
		}

		private var _afra:AdobeFragmentRandomAccessBox;
		private var _ba:ByteArray;
		private var _boxInfoPending:Boolean;
		private var _bytesNeeded:uint;
		private var _bytesReadSinceAfraStart:uint;
		private var _countingReadBytes:Boolean;
		private var _mdatBytesPending:uint;
		private var _nextBox:BoxInfo;
		private var _parser:BoxParser = new BoxParser();
		private var _seekToTime:Number;
		private var _mdatBytesOffset:Number;
		private var _processRequestWasSeek:Boolean = false;
		
		private static const MAX_BYTES_PER_MDAT_READ:uint = 10*1024;
		
		private var _ba1:ByteArray;
		private var _boxInfoPending1:Boolean;
		private var _bytesNeeded1:uint;
		private var _bytesReadSinceAfraStart1:uint;
		private var _countingReadBytes1:Boolean;
		private var _mdatBytesPending1:uint = 0;
		private var _nextBox1:BoxInfo;
		private var _mixedVideoTime:uint;
		private var _mixedAudioTime:uint;
		private var tagHeaderPending:Boolean = true;
		private var tagBodyPending:Boolean;
		private var tagHeaderPending1:Boolean = true;
		private var tagBodyPending1:Boolean;
		private var _parser1:BoxParser = new BoxParser();
		private	var currTime:uint = 0;
		private	var videoTag:int = FLVTag.TAG_TYPE_VIDEO;
		private	var videoTime:uint = 0;
		private	var videoDataSize:uint = 0;
		private	var audioTag:int = FLVTag.TAG_TYPE_AUDIO;
		private	var audioTime:uint = 0;
		private	var audioDataSize:uint = 0;
		private	var	videoHeaderBytes:ByteArray = new ByteArray();
		private var	audioHeaderBytes:ByteArray = new ByteArray();
		private	var	videoDataBytes:ByteArray = new ByteArray();
		private	var	audioDataBytes:ByteArray = new ByteArray();
		
		private	var _videoInput:ByteArray = new ByteArray();
		private	var _audioInput:ByteArray = new ByteArray();

		
		CONFIG::LOGGING
		{
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FFileHandler");
		}
	}
}