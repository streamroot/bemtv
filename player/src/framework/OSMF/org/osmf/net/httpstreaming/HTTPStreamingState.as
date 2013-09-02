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
package org.osmf.net.httpstreaming
{
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Enumeration of states that an HTTPNetStream can cycle through.
	 * 
	 * In general, the HTTPNetStream cycles through the following categories
	 * of states:
	 * 1) LOAD
	 * 2) PLAY
	 * 3) END_SEGMENT
	 * 
	 * The LOAD and PLAY states have several sub-states to distinguish between
	 * operations triggered by seeks, and operations triggered by normal playback.
	 */ 
	internal class HTTPStreamingState
	{
		/**
		 * Indicates the HDS-related object is in its initial state.  
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		internal static const INIT:String = "init";
		
		/**
		 * Indicates the HDS-related source is about to load a new fragment.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		internal static const LOAD:String = "load";
		
		/**
		 * Indicates the HDS-related object is waiting for conditions to be
		 * appropriate in order to do additional processing.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		internal static const WAIT:String = "wait";
		
		/**
		 * Indicates the HDS-related object is starting playing a new fragment.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		internal static const BEGIN_FRAGMENT:String = "beginFragment";

		/**
		 * Indicates the HDS-related object has finished playing the current fragment.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		internal static const END_FRAGMENT:String = "endFragment";
	
		/**
		 * Indicates the HDS-related object is playing the current stream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		internal static const PLAY:String = "play";
		
		/**
		 * Indicates the HDS-related object is reading the content of the current stream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		internal static const READ:String = "read";

		/**
		 * Indicates the HDS-related object is currently seeking.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		internal static const SEEK:String = "seek";

		/**
		 * Indicates the HDS-related object is stopping playback.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		internal static const STOP:String = "stop";
		
		/**
		 * Indicates the HDS-related object is halted.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		internal static const HALT:String = "halt";	
	}
}