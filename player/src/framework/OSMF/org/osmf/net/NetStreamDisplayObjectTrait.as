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
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.net.NetStream;
	
	import org.osmf.media.videoClasses.VideoSurface;
	import org.osmf.traits.DisplayObjectTrait;
	
	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class NetStreamDisplayObjectTrait extends DisplayObjectTrait
	{
		public function NetStreamDisplayObjectTrait(netStream:NetStream, videoSurface:DisplayObject, mediaWidth:Number=0, mediaHeight:Number=0)
		{
			super(videoSurface, mediaWidth, mediaHeight);
			
			this.netStream = netStream;
			this.videoSurface = videoSurface as VideoSurface;
			
			NetClient(netStream.client).addHandler(NetStreamCodes.ON_META_DATA, onMetaData);
			if (this.videoSurface is VideoSurface)
				this.videoSurface.addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		
		private function onStage(event:Event):void
		{
			videoSurface.removeEventListener(Event.ADDED_TO_STAGE, onStage);
			videoSurface.addEventListener(Event.ENTER_FRAME, onFrame);				
		}
				
		private function onFrame(event:Event):void
		{	
			if  (
					videoSurface.videoWidth != 0
			 	 && videoSurface.videoHeight != 0 
				)
			{	
				if  (	videoSurface.videoWidth != mediaWidth
					 && videoSurface.videoHeight != mediaHeight
					)
				{
					newMediaSize(videoSurface.videoWidth, videoSurface.videoHeight);		
				}
				videoSurface.removeEventListener(Event.ENTER_FRAME, onFrame);							
			}
		}
	
		private function onMetaData(info:Object):void 
    	{       		
    		if	(
					!isNaN(info.width)
    			&&  !isNaN(info.height)
    			&&	(	info.width != mediaWidth
    				||	info.height != mediaHeight
    				)
    			)
    		{	    			
				newMediaSize(info.width, info.height);
    		}
    	}
		
		private function newMediaSize(width:Number, height:Number):void
		{
			if	(
					videoSurface != null					
				&& 	videoSurface.width == 0 
			  	&&	videoSurface.height == 0
				)  //If there is no layout, set as no scale.
			{
				videoSurface.width = width;
				videoSurface.height = height;	
			}
			setMediaSize(width, height);
		}
    	
		private var videoSurface:VideoSurface;
		private var netStream:NetStream;
	}
}