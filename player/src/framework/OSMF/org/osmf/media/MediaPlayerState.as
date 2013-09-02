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
package org.osmf.media
{
	/**
     *  The MediaPlayerState class enumerates public constants that describe the current
     *  state of the MediaPlayer.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion OSMF 1.0
	 *  @productversion FLEXOSMF 4.0
     */
    public final class MediaPlayerState
    {
		/**
		 * The MediaPlayer has been created but is not ready to be used.
		 * This is the base state for a MediaPlayer.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public static const UNINITIALIZED:String   = "uninitialized";

		/**
		 * The MediaPlayer is loading or connecting.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public static const LOADING:String  = "loading";

		/**
		 * The MediaPlayer is ready to be used.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public static const READY:String = "ready";

		/**
	     * The MediaPlayer is playing media.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0		 
         */
		public static const PLAYING:String = "playing";

		/**
         * The MediaPlayer is pausing media.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public static const PAUSED:String = "paused";

		/**
		 * The MediaPlayer is buffering.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public static const BUFFERING:String = "buffering";

		/**
		 * The MediaPlayer encountered an error while trying to play media.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
		public static const PLAYBACK_ERROR:String = "playbackError";
	} 
}