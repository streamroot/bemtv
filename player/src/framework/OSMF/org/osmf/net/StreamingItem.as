/*****************************************************
 *  
 *  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package org.osmf.net
{
	/**
	 * The StreamingItem class represents a single media stream within 
	 * a StreamingURLResource.
	 * 
	 * @see org.osmf.net.StreamingURLResource
	 * @see org.osmf.net.StreamingItemType
	 *  
	 * @langversion 3.0
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @productversion OSMF 1.6
	 */	
	public class StreamingItem
	{
		/**
		 * Default constructor
		 * 
		 * @param type  The <code>StreamingItemType</code> of the stream. Allowed values 
		 * 				are <code>VIDEO</code>, for a stream that includes video, and 
		 * 				<code>AUDIO</code>, for a stream that contains only audio. 
		 * @param streamName A <code>String</code> used to identify this stream.
		 * @param bitrate A <code>Number</code> specifying the stream’s encoded bit rate 
		 * 				  in kbps (kilobits per second).
		 * @param info 	An <code>Object</code> containing any custom information associated
		 * 				with the stream. Typically, this can include the width and height 
		 * 				of the video, but it could also contain a user-friendly description 
		 * 				of the stream.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		public function StreamingItem(type:String, streamName:String, bitrate:Number = 0, info:Object = null )
		{
			_type 		= type;
			_streamName	= streamName;
			_bitrate 	= bitrate;
			
			_info 		= info == null ? new Object() : info;
		}

		/**
		 * Returns a <code>String</code> specifying the type of the stream. 
		 * Possible values are <code>VIDEO</code>, for a stream that includes 
		 * video, and <code>AUDIO</code>, for a stream that contains only audio.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */			
		public function get type():String
		{
			return _type;	
		}

		/**
		 * Returns a <code>String</code> used to identify the stream.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */			
		public function get streamName():String
		{
			return _streamName;	
		}
		
		/**
		 * Returns a <code>Number</code> giving the stream’s bit rate, 
		 * specified in kilobits per second (kbps).
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		public function get bitrate():Number
		{
			return _bitrate;
		}

		/**
		 * Returns an <code>Object</code> containing any custom information 
		 * associated with the stream. Typically, this can include the width 
		 * and height of the video, but it could also contain a user-friendly 
		 * description of the stream.
		 *   
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		public function get info():Object
		{
			return _info;
		}
		
		// Internals
		private var _type:String = null;
		private var _streamName:String = null;
		private var _bitrate:Number;
		private var _info:Object = null;
	}
}