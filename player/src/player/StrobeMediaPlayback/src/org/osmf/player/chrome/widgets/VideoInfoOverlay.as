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

package org.osmf.player.chrome.widgets
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.videoClasses.VideoSurface;
	import org.osmf.media.videoClasses.VideoSurfaceInfo;
	import org.osmf.net.*;
	import org.osmf.player.media.StrobeMediaPlayer;
	import org.osmf.player.utils.StrobePlayerStrings;
	import org.osmf.player.utils.StrobeUtils;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFSettings;
	
	CONFIG::FLASH_10_1	
	{	
		import flash.net.NetGroup;	
		import flash.net.NetStreamMulticastInfo;
	}

	/**
	 * VideoInfoOverlay can be used for troubleshooting common Strobe Media Playback issues.
	 * 
	 * You can activate it by choosing the "Strobe Media Playback Info" on the ControlBar context menu (right click on the control bar).
	 */ 
	public class VideoInfoOverlay extends Sprite
	{	
		/**
		 * Registers the context menu item. Note that we use the ControlBar as the ContextMenu target.
		 */ 
		public function register(target:Sprite, container:Sprite, mediaPlayer:StrobeMediaPlayer):void
		{
			this.container = container;
			this.mediaPlayer = mediaPlayer;
			
			var customContextMenu:ContextMenu;
			customContextMenu = new ContextMenu();
			var videoInfoItem:ContextMenuItem = new ContextMenuItem(StrobePlayerStrings.title + " Info");
			customContextMenu.hideBuiltInItems();
			customContextMenu.customItems = [videoInfoItem];
			videoInfoItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onItemSelect);
			target.contextMenu = customContextMenu;
		}
		
		public function showInfo():void
		{
			if (refreshTimer != null)
			{
				return;
			}
			
			refreshTimer = new Timer(REFRESH_INTERVAL);
			refreshTimer.addEventListener(TimerEvent.TIMER, onTimer);
			refreshTimer.start();
			
			videoInfoOverlay = new ASSET_VideoInfoOverlay();
			container.addChild(videoInfoOverlay);
			containerWidth = container.width;
			videoInfoOverlayWidth = videoInfoOverlay.width;
			videoInfoOverlay.x = 5;
			videoInfoOverlay.y = 5;
			
			for (var idx:int=0; idx < videoInfoOverlay.numChildren; idx++)
			{
				var child:DisplayObject = videoInfoOverlay.getChildAt(idx);	
				if (child is CloseButton)
				{
					closeButton = child as CloseButton;
					closeButton.addEventListener(MouseEvent.CLICK, onCloseButtonClick);
				}
				
				if (child.name == "videoInfo")
				{
					textField = child as TextField;
				}
			}
			onTimer(null);
		}
		// Internals
		private static const REFRESH_INTERVAL:int = 3000;
		
		private var refreshTimer:Timer;
		private var textField:TextField;		
		private var container:Sprite;
		private var mediaPlayer:StrobeMediaPlayer;
		private var closeButton:CloseButton;
		private var videoInfoOverlay:MovieClip;
		private var containerWidth:Number;
		private var videoInfoOverlayWidth:Number;
		
		private function onItemSelect(event:Event):void
		{
			showInfo();
		}
		
		private function onCloseButtonClick(event:MouseEvent):void
		{
			refreshTimer.stop();
			refreshTimer = null;
			
			closeButton.removeEventListener(
				MouseEvent.CLICK, 
				onCloseButtonClick
			);
		
			container.removeChild(videoInfoOverlay);
			videoInfoOverlay = null;
		}
		
		private function onTimer(event:Event = null):void
		{
			// Adjust the Info overlay if it doesn't fit inside the vide. The content of the overlay will be scaled.
			if (container.width < videoInfoOverlay.width || containerWidth != container.width)
			{				
				containerWidth = container.width;
				var oldWidth:Number = videoInfoOverlay.width;
				var newWidth:Number = Math.min(containerWidth - 10, videoInfoOverlayWidth);
				videoInfoOverlay.width = newWidth;
				videoInfoOverlay.height *= newWidth / oldWidth;
			}
			
			var videoInfo:String = "Build " + StrobePlayerStrings.version;
			
			// Build a information text message. 
			var targetFP:String = "10.0";
			CONFIG::FLASH_10_1	
			{	
				targetFP = "10.1";
			}
			
			videoInfo += " for Flash Player "
				+ targetFP
				+ "\n";
			
			videoInfo += "Flash Player version:\t" + Capabilities.version;
			if (Capabilities.isDebugger)
			{
				videoInfo += " (debug)";
			}			
				
			// TODO: Move this to a 'Capabilities' kind of class
			var stageVideoSupport:Boolean = OSMFSettings.supportsStageVideo;
			
			var videoSurface:VideoSurface = mediaPlayer.displayObject as VideoSurface;
			if (videoSurface)
			{
				var videoSurfaceInfo:VideoSurfaceInfo = videoSurface.info;
				var decodingMode:String = 
				videoInfo += "\nHardware Video Decoding:   \t"
					+ (videoSurfaceInfo.renderStatus == "accelerated" ? "Yes" : "No")
					+ "\n";	
				videoInfo += "Hardware Video Rendering:  \t";
				if (stageVideoSupport)
				{
					if (videoSurfaceInfo.stageVideoInUse)
					{
						videoInfo += "Yes (StageVideo " + videoSurfaceInfo.stageVideoInUseCount + "/" + videoSurfaceInfo.stageVideoCount + ")";
					}
					else
					{
						videoInfo += "No";
					}		
				}
				else
				{
					videoInfo += "Not available in this version of Flash Player. Flash Player 10.2 is required.";					
				}				
				videoInfo += "\n";
			}
			videoInfo += "\n";
			
			var netStream:NetStream = null;
			CONFIG::FLASH_10_1	
			{
				var netGroup:NetGroup = null;
			}
			var media:MediaElement = mediaPlayer.media;
			if (media && media.hasTrait(MediaTraitType.LOAD))
			{
				var loadTrait:NetStreamLoadTrait = media.getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
				if (loadTrait)
				{
					netStream = loadTrait.netStream;
					CONFIG::FLASH_10_1	
					{
						netGroup = loadTrait.netGroup;
					}
					if (netStream)
					{
						videoInfo += "Frame rate:\t" 
							+ netStream.currentFPS.toFixed(2)
							+ " fps"
							+ "\t";
						
						videoInfo += "Dropped frames:\t" 
							+ netStream.info.droppedFrames							
							+ "\n";
						
						videoInfo += "Buffer length / time:\t"
							+ netStream.bufferLength.toFixed(2) 
							+ " s"	
							+ " / " 
							+ netStream.bufferTime.toFixed(2)
							+ " s"
							+ "\n";
					}
				}
			}
			
			videoInfo += "Memory usage:\t" 
				+ StrobeUtils.bytes2String(System.totalMemory)
				+ "\n";

			CONFIG::FLASH_10_1	
			{	
				if (netStream)
				{
					var multicastInfo:NetStreamMulticastInfo = netStream.multicastInfo;			
					if (netGroup)
					{
						videoInfo += "\nNeighbors (count/estimated):\t" 
							+ netGroup.neighborCount 
							+ " / " 
							+ netGroup.estimatedMemberCount.toFixed(2) 
							+ "\n";
					}
					if (multicastInfo)
					{
						
						videoInfo += "Download speed:\t" 
							+ StrobeUtils.bytesPerSecond2String(multicastInfo.receiveDataBytesPerSecond)
							+ " ( " 
							+ StrobeUtils.bytesPerSecond2ByteString(multicastInfo.receiveDataBytesPerSecond)
							+ " )\n";
						
						videoInfo += "Upload speed:\t" 
							+ StrobeUtils.bytesPerSecond2String(multicastInfo.sendDataBytesPerSecond) + 
							" ( " 
							+ StrobeUtils.bytesPerSecond2ByteString(multicastInfo.sendDataBytesPerSecond) 
							+ " )\n";
						
						
						videoInfo += "Total Bytes Pushed From/To Peers:\t" 
							+ StrobeUtils.bytes2String(multicastInfo.bytesPushedFromPeers) 
							+ " / " 
							+ StrobeUtils.bytes2String(multicastInfo.bytesPushedToPeers) 
							+ "\n";
						
						
						videoInfo += "Total Bytes Requested From Peers:\t" 
							+ StrobeUtils.bytes2String(multicastInfo.bytesRequestedFromPeers) 
							+ "\n";
						
						videoInfo += "Total Bytes Received From IP Multicast:\t" 
							+ StrobeUtils.bytes2String(multicastInfo.bytesReceivedFromIPMulticast) 
							+ "\n";
						
//						*bytesPushedFromPeers 
//						*bytesRequestedFromPeers 
//						bytesReceivedFromIPMulticast 
//						*bytesPushedToPeers
					}
					

					videoInfo += "\nStream state:\t"
						+ mediaPlayer.state 
						+ "\n";			
				}	
			}
			
			textField.text = videoInfo;
			
		}
	}
}