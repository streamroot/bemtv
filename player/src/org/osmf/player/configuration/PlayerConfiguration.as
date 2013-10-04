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
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.StreamType;
	import org.osmf.player.chrome.configuration.ConfigurationUtils;
	import org.osmf.player.metadata.StrobeDynamicMetadata;

	/**
	 * Player configuration data model
	 */ 		
	public class PlayerConfiguration
	{
		/** The location of the mediafile. */
		public var src:String = "";
		
		/** Contains the asset metadata */
		public var metadata:Object = {};
		
		public var resource:Object = {streamType:StreamType.LIVE_OR_RECORDED};
		public var player:Object = {};
		// StreamingURLResource properties 		
		/** Defines the stream type */
		//public var streamType:String = StreamType.LIVE_OR_RECORDED;		
		
		/** Indicates, for RTMP streaming URLs, whether the URL includes the FMS application instance or not. */
		//public var urlIncludesFMSApplicationInstance : Boolean = false;
		
		/** The background color of the player */ 
		public var backgroundColor:uint = 0;
		
		/** Tint color */ 
		public var tintColor:uint = 0;
		
		/** Tels wether the player should auto hide controls */ 
		public var controlBarAutoHide:Boolean = true;
		
		/** Changes the timeout for the autohide behaviour. In seconds */ 
		public var controlBarAutoHideTimeout:Number = 3;
		
		/** The location of the control bar */ 
		public var controlBarMode:String = ControlBarMode.DOCKED;
		
		/** The type of the control bar */
		public var controlBarType:String = ControlBarType.DESKTOP;
		
		/** Tels whether the media should be played in a loop */ 
		//public var loop:Boolean = false;
		
		/** Tels whether the media should autostart */ 
		//public var autoPlay:Boolean = false;
		
		/**
		 * Scale mode as defined here:
		 * http://help.adobe.com/en_US/FlashPlatform/beta/reference/actionscript/3/org/osmf/display/ScaleMode.html
		 */ 
		public var scaleMode:String = ScaleMode.LETTERBOX;
		
		/** Defines the file that holds the player's skin */
		public var skin:String = "";
		
		/** Defines if messages will show verbose or not */ 
		public var verbose:Boolean = false;
		
		/** Defines the path to the image to show before the main content shows */
		public var poster:String = "";
		
		/** Defines the path to the image to show at the end of the content */
		public var endOfVideoOverlay:String = "";
	
		/** Defines if the play button overlay appears */
		public var playButtonOverlay:Boolean = true;
		
		/** Defines if the buffering overlay appears */
		public var bufferingOverlay:Boolean = true;
		
		/** Defines the high quality threshold */
		//public var highQualityThreshold:uint = 480;
		
		/** Defines the video rendering mode */
		//public var videoRenderingMode:uint = VideoRenderingMode.AUTO;
		
		/** Defines the auto switch quality */
		//public var autoSwitchQuality:Boolean = true;
		
		/** Defines the optimizeInitialIndex flag */ 
		public var optimizeInitialIndex:Boolean = true
			
		/** Defines the optimized buffering flag */
		public var optimizeBuffering:Boolean = true;
	
		/** Defines the initial buffer time for video content */
		public var initialBufferTime:Number = 0.1;		
		
		/** Defines the expanded buffer time for video content */
		public var expandedBufferTime:Number = 10;	
		
	
		/** Defines the minimal continuous playback time */
		public var minContinuousPlaybackTime:Number = 30;
		
		/** Defines the collection of plug-in configurations */		
		public var plugins:Object = {};
		
		
		public var haltOnError:Boolean = false;
				
		public var javascriptCallbackFunction:String = "";
		
		public var rtmpNetConnectionFactoryTimeout:Number = 10;
		public var multicastNetConnectionFactoryTimeout:Number = 60;
		
		public var showVideoInfoOverlayOnStartUp:Boolean = false;
		
		public var enableStageVideo:Boolean = true;
		
		// Debug configuration setting
		public var removeContentFromStageOnFullScreenWithStageVideo:Boolean = false;
		public var useFullScreenSourceRectOnFullScreenWithStageVideo:Boolean = false;
	}
}