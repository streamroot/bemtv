/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 * 
 **********************************************************/

package org.osmf.player.configuration
{
	
	/**
	 * Indicates how the control bar should be positioned relative to the video. 
	 */ 
	public final class ControlBarMode
	{
		/**
		 * <code>NONE</code> - a control bar will not be displayed.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const NONE:String 		= "none";
		
		
		/**
		 * <code>BOTTOM</code> - the ControlBar will be displayed under the player
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const DOCKED:String 			= "docked";
		
		/**
		 * <code>OVER</code> - the ControlBar will be displayed over the player
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const FLOATING:String 		= "floating";
		
		/**
		 * <code>values</code> - the list of values provided by this enum.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public static const values:Array = [ControlBarMode.DOCKED, ControlBarMode.FLOATING, ControlBarMode.NONE];		
	}
}