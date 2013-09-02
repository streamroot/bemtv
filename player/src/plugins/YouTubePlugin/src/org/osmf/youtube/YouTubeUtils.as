/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
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
 **********************************************************/


package org.osmf.youtube
{
	import flash.utils.Dictionary;
	
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.PlayState;

	/**
	 * This class holds a couple of utility functions for YouTube chromeless player
	 * as well as mappings between YouTube notions and corresponding OSMF counterparts.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0 
	 *
	 */
	public class YouTubeUtils
	{		
		public static var STATE_MAP:Dictionary;
		public static var QUALITY_MAP:Dictionary;
		public static var WIDTH_MAP:Dictionary;
		public static var HEIGHT_MAP:Dictionary;
		
		// static initializer
		{
			STATE_MAP = new Dictionary();
			STATE_MAP[-1] = LoadState.UNINITIALIZED;
			STATE_MAP[0] = PlayState.STOPPED;
			STATE_MAP[1] = PlayState.PLAYING;
			STATE_MAP[2] = PlayState.PAUSED;
			STATE_MAP[3] = LoadState.LOADING;
			STATE_MAP[5] = LoadState.READY;

			//NOTE: when YouTube adds new quality modes, one should add a bitrate also
			//NOTE: these values are placeholders
			//TODO: need to figure out the actual YouTube bitrates for each stream quality
			
			QUALITY_MAP = new Dictionary();
			QUALITY_MAP["small"] = 240;
			QUALITY_MAP["medium"] = 360;
			QUALITY_MAP["large"] = 576;
			QUALITY_MAP["hd720"] = 720;
			QUALITY_MAP["hd1080"] = 1080;
			QUALITY_MAP["highres"] = 2000;
			
			WIDTH_MAP = new Dictionary();
			WIDTH_MAP["small"] = 426;
			WIDTH_MAP["medium"] = 640;
			WIDTH_MAP["large"] = 1024;
			WIDTH_MAP["hd720"] = 1280;
			WIDTH_MAP["hd1080"] = 1920;
			WIDTH_MAP["highres"] = 3555;
			
			HEIGHT_MAP = new Dictionary();
			HEIGHT_MAP["small"] = 240;
			HEIGHT_MAP["medium"] = 360;
			HEIGHT_MAP["large"] = 576;
			HEIGHT_MAP["hd720"] = 720;
			HEIGHT_MAP["hd1080"] = 1080;
			HEIGHT_MAP["highres"] = 2000;
		}

		// Public interface
		/**
		 * Returns an bitrate based on the supplied YouTube quality level.
		 *
		 * <b>Note that these values are placeholders as we do not know exactly the matching
		 * bitrates. Also when YouTube adds new quality modes, one should add a bitrate also
		 * to the internal QUALITY_MAP dictionary.
		 *
		 * @param youTubeQuality
		 * @return estimated bitrate in kilobits per second.
		 */
		public static function getOSMFBitrate(youTubeQuality:String):Number
		{
			return (youTubeQuality in QUALITY_MAP) ? QUALITY_MAP[youTubeQuality] : UNKNOWN_QUALITY_BITRATE;
		}

		//

		/**
		 * Retrieves an OSMF state, based on the supplied YouTube player state.
		 *
		 * @param youTubeState
		 * @return OSMF compatible LoadState or PlayState
		 */
		public static function getOSMFState(youTubeState:int):String
		{
			return (youTubeState in STATE_MAP) ? STATE_MAP[youTubeState] : null;

		}

		/**
		 * Retrieves the YouTube movie ID from the original YouTube url.
		 *
		 * @param youTubeUrl
		 * @return YouTube movie id.
		 */
		public static function getYouTubeID(youTubeUrl:String):String
		{
			var matches:Array = youTubeUrl.match(/(.*)(v[=\/])(.{11})/);
			var id:String = null;

			if (matches && matches.length > 2)
			{
				id = matches[3];
			}

			return id;
		}
		
		public static function constructStreamItems(qualityLevels:Array):Vector.<DynamicStreamingItem>
		{
			var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
			for each(var qualityLevel:String in qualityLevels)
			{		
				var dynamicStreamingItem:DynamicStreamingItem 
				= new DynamicStreamingItem(qualityLevel, 
					QUALITY_MAP[qualityLevel], 
					WIDTH_MAP[qualityLevel],
					HEIGHT_MAP[qualityLevel]);
				streamItems.unshift(dynamicStreamingItem);
			}
			return streamItems;
		}

		// Internals
		//
		
		private static const UNKNOWN_QUALITY_BITRATE:int = 2048;
	}
}