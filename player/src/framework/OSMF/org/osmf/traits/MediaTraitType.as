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
package org.osmf.traits
{
	import __AS3__.vec.Vector;
	
	/**
	 * MediaTraitType is the enumeration of all possible media trait types.
	 * 
	 * <p>The set of traits in the framework are fixed:  clients are not expected
	 * to introduce their own, as they form the core vocabulary of the system.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public final class MediaTraitType
	{
		/**
		 * Identifies an instance of an AudioTrait. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public static const AUDIO:String = "audio";
		
		/**
		 * Identifies an instance of a BufferTrait. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const BUFFER:String = "buffer";
		
		/**
		 * Identifies an instance of a DRMTrait. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const DRM:String = "drm";

		/**
		 * Identifies an instance of a DynamicStreamTrait. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const DYNAMIC_STREAM:String = "dynamicStream";

		/**
		 * Identifies an instance of an AlternativeAudioTrait.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		public static const ALTERNATIVE_AUDIO:String = "alternativeAudio";

		/**
		 * Identifies an instance of a LoadTrait. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const LOAD:String = "load";
				
		/**
		 * Identifies an instance of a PlayTrait. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const PLAY:String = "play";
		
		/**
		 * Identifies an instance of a SeekTrait. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const SEEK:String = "seek";
		
		/**
		 * Identifies an instance of a TimeTrait. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const TIME:String = "time";
		
		/**
		 * Identifies an instance of a DisplayObjectTrait. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const DISPLAY_OBJECT:String = "displayObject";
		
		/**
		 * Identifies an instance of a DVRTrait. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const DVR:String = "dvr";
				
		/**
		 * @private
		 * 
		 * Array containing all trait types in the system.
		 */
		public static const ALL_TYPES:Vector.<String> = Vector.<String>
			(	[ AUDIO
				, BUFFER
				, DRM
				, DYNAMIC_STREAM
				, LOAD
				, PLAY
				, SEEK
				, TIME
				, DISPLAY_OBJECT
				, DVR
				//, ALTERNATIVE_AUDIO
			  	]
			);
	}
}