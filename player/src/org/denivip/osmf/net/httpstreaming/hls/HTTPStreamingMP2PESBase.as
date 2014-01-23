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
		
	internal class HTTPStreamingMP2PESBase
	{

		protected var _offset:Number = 0.0;
		protected var _initialTimestamp:Number = 0.0;
		protected var _prevTimestamp:Number = 0.0;
		protected var _timestamp:Number;
		protected var _compositionTime:Number;
		protected var _timestampReseted:Boolean = false;
		protected var _isDiscontunity:Boolean = false;
		protected var _streamOffsetSet:Boolean = false;

		public function set initialTimestamp(value:Number):void{
			_initialTimestamp = value;
			_offset = 0.0;
			_prevTimestamp = 0.0;
			_timestampReseted = true;
			
			// is beginning of stream
			if(_initialTimestamp == 0)
				_streamOffsetSet = false;
		}
	    
	    public function processES(pusi:Boolean, packet:ByteArray, flush:Boolean = false):ByteArray
	    {
	    	return null;
	    }
		
		public function set isDiscontunity(isDiscontunity:Boolean):void {
			_isDiscontunity = isDiscontunity;
			_streamOffsetSet = false;
		}
	}



}