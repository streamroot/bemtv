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

package org.osmf.player.utils
{	
	import flash.geom.Rectangle;
	
	import org.osmf.player.chrome.utils.MediaElementUtils;
	import org.osmf.elements.LightweightVideoElement;
	import org.osmf.media.MediaElement;
	import org.osmf.player.configuration.VideoRenderingMode;
	import org.osmf.player.errors.StrobePlayerError;
	import org.osmf.player.errors.StrobePlayerErrorCodes;


	/**
	 * Utility function which are used for optimizing the viewer's experience with both HD and SD content.
	 * 
	 */
	public class VideoRenderingUtils
	{		
		
		/**
		 * Determines the value to be set for deblocking based on configuration setting and type of content (HD or SD)
		 */ 
		public static function determineDeblocking(deblockingConfiguration:uint, highQuality:Boolean):int
		{
			var result:int;
			switch (deblockingConfiguration)
			{
				case  VideoRenderingMode.NONE:	
					result = 1;
					break;
				case  VideoRenderingMode.DEBLOCKING:
				case  VideoRenderingMode.SMOOTHING_DEBLOCKING:	
					result = 0;
					break;
				case VideoRenderingMode.AUTO:
					result = (highQuality ? 1 : 0);// Disable deblocking for High Quality videos
					break;
				default:
					throw new StrobePlayerError(StrobePlayerErrorCodes.ILLEGAL_INPUT_VARIABLE);
			}
			return result;
		}
		
		/**
		 * Determines the value to be set for smoothing based on configuration setting and type of content (HD or SD)
		 */ 
		public static function determineSmoothing(smoothingConfiguration:uint, highQuality:Boolean):Boolean
		{
			var result:Boolean;
			switch (smoothingConfiguration)
			{
				case  VideoRenderingMode.NONE:
					result = false;
					break;				
				case  VideoRenderingMode.SMOOTHING:
				case  VideoRenderingMode.SMOOTHING_DEBLOCKING:
					result = true;
					break;
				case VideoRenderingMode.AUTO:
					result = !highQuality;// Disable smoothing for High Quality videos
					break;
				default:
					throw new StrobePlayerError(StrobePlayerErrorCodes.ILLEGAL_INPUT_VARIABLE);
			}
			return result;
		}
		
		/**
		 * Computes the optimal size of the fullScreenSource rectangle.
		 */ 
		public static function computeOptimalFullScreenSourceRect(stageFullScreenWidth:int, stageFullScreenHeight:int, videoWidth:int, videoHeight:int):Rectangle
		{
			var r:Number = (stageFullScreenWidth / stageFullScreenHeight) / ( videoWidth / videoHeight);
			var fullScreenSourceWidth:Number = videoWidth;
			var fullScreenSourceHeight:Number = videoHeight;
			if (r > 1)
			{
				fullScreenSourceWidth = videoWidth * r;					
			}
			else
			{
				fullScreenSourceHeight = videoHeight / r;
			}
			
			var rect:Rectangle =  new Rectangle(
				0,
				0,
				fullScreenSourceWidth,
				fullScreenSourceHeight); 
			
			return rect;
		}
		
		/**
		 * Apply High Definition
		 */ 
		public static function applyHDSDBestPractices(mediaElement:MediaElement, videoRenderingMode:uint, highQuality:Boolean):void
		{
			var lightweightVideoElement:LightweightVideoElement = MediaElementUtils.getMediaElementParentOfType(mediaElement, LightweightVideoElement) as LightweightVideoElement;
			if (lightweightVideoElement != null)
			{				
				lightweightVideoElement.smoothing 
					= VideoRenderingUtils.determineSmoothing
					(   videoRenderingMode
						, highQuality 
					);
				lightweightVideoElement.deblocking 
					= VideoRenderingUtils.determineDeblocking
					(   videoRenderingMode
						, highQuality
					);			
			}
		}
	}
}