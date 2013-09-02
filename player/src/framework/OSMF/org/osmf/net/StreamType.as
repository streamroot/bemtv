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
package org.osmf.net
{
	/**
	 * The StreamType class is an enumeration of constant values that you can
	 * use to set the streamType property of the StreamingURLResource class.
	 * This property allows the player to specify over which connection type
	 * the resource should be streamed.
	 *
	 * @see StreamingURLResource
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
     *  @productversion FLEXOSMF 4.0 
	 */
	public final class StreamType
	{
		/**
		 * The LIVE stream type represents a live stream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public static const LIVE:String = "live";

		/**
		 * The RECORDED stream type represents a recorded stream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public static const RECORDED:String = "recorded";

		/**
		 * The LIVE_OR_RECORDED stream type represents a live or a recorded stream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public static const LIVE_OR_RECORDED:String = "liveOrRecorded";
		
		/**
		 * The DVR stream type represents a possibly server side
		 * recording live stream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public static const DVR:String = "dvr";
	}
}
