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
	 * VideoRenderingMode is an enumeration which holds the configuration options for how smoothing and deblocking should be applied. 
	 * Note that this is used together with the highQualityThreshold configuration option.
	 */ 
	public class VideoRenderingMode
	{
		/**
		 * <code>NONE</code> - disable both smoothing and deblocking.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const NONE:uint		= 0x0;

		/**
		 * <code>SMOOTHING</code> - enable smoothing only.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const SMOOTHING:uint		= 0x1;
		
		/**
		 * <code>DEBLOCKING</code> - enabled deblocking only
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const DEBLOCKING:uint	= 0x2;
		
		/**
		 * <code>SMOOTHING_DEBLOCKING</code> - enable both smoothing and deblocking.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const SMOOTHING_DEBLOCKING:uint	= 0x3;
		
		/**
		 * <code>AUTO</code> - the value will be determined by SD/HD rules.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const AUTO:uint	= 0x4;      
	
		/**
		 * <code>values</code> - the list of values provided by this enum.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public static const values:Array = [VideoRenderingMode.NONE, VideoRenderingMode.SMOOTHING, VideoRenderingMode.DEBLOCKING, VideoRenderingMode.SMOOTHING_DEBLOCKING, VideoRenderingMode.AUTO];
	}
}