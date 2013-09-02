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
package org.osmf.net.httpstreaming.dvr
{
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Describes the DVR cast information used by media objects.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */ 
	public class DVRInfo
	{
		/**
		 * The ID of this &lt;dvrInfo&gt; element. It is optional. If it is not specified, 
		 * then none of the media elements is of DVR content. If it is specified, it is applicable to all
		 * the media elements are DVR contents.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 		
		public var id:String;
		
		/**
		 * The url that points to a remote location at which the &lt;dvrInfo&gt; element is available 
		 * for download
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var url:String;

		/**
		 * The offset, in seconds, from the beginning of the recorded stream. Client can begin viewing
		 * the stream at this location. It is optional, and defaults to zero.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var beginOffset:uint = 0;

		/**
		 * The amoutn of data, in seconds, that client can begin viewing
		 * from the current media time. It is optional, and defaults to zero.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var endOffset:uint = 0;

		/**
		 * The window length on the server, in seconds: represents the maximum 
		 * length of the content.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var windowDuration:int = -1;
		
		/**
		 * Indicates whether the stream is offline, or available for playback. It is optional, and defaults to false. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var offline:Boolean;
		
		/**
		 * Indicates whether the stream is recording. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var isRecording:Boolean;

		/**
		 * Indicates the current total length of the content. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var curLength:Number;

		/**
		 * Indicates the starting position when the DVR content is loaded and about to play. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var startTime:Number = NaN;
	}
}