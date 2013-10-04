/***********************************************************
 * Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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

package org.osmf.player.chrome{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.assets.FontAsset;
	import org.osmf.player.chrome.widgets.AutoHideWidget;
	import org.osmf.player.chrome.widgets.ButtonHighlight;
	import org.osmf.player.chrome.widgets.CurrentTimeWidget;
	import org.osmf.player.chrome.widgets.FullScreenEnterButton;
	import org.osmf.player.chrome.widgets.FullScreenLeaveButton;
	import org.osmf.player.chrome.widgets.PauseButton;
	import org.osmf.player.chrome.widgets.PlayButton;
	import org.osmf.player.chrome.widgets.ScrubBar;
	import org.osmf.player.chrome.widgets.TotalTimeWidget;
	import org.osmf.player.chrome.widgets.Widget;
	import org.osmf.player.chrome.widgets.WidgetIDs;
	import org.osmf.traits.MediaTraitType;

	/**
	 * MobileControlBar
	 * @author johncblandii
	 */
	public class TabletControlBar extends AutoHideWidget implements IControlBar
	{	
		// OVERRIDES
		//
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			id = WidgetIDs.CONTROL_BAR;
			face = AssetIDs.CONTROL_BAR_BACKDROP;
			fadeSteps = 6;
			
			layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			layoutMetadata.verticalAlign = VerticalAlign.TOP;
			layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			layoutMetadata.height = 55;

			FontAsset(assetManager.getAsset(AssetIDs.DEFAULT_FONT)).resource.size = 16;
			FontAsset(assetManager.getAsset(AssetIDs.DEFAULT_FONT_BOLD)).resource.size = 16;
			
			super.configure(xml, assetManager);
			
			// Left margin
			var leftMargin:Widget = new Widget();
			leftMargin.face = AssetIDs.CONTROL_BAR_BACKDROP_LEFT;
			leftMargin.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			addChildWidget(leftMargin);
			
			// Play/pause
			var playButton:PlayButton = new PlayButton();
			playButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE
			playButton.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			playButton.addEventListener(MouseEvent.ROLL_OVER, showHighlight, false, 0, true);
			playButton.addEventListener(MouseEvent.ROLL_OUT, removeHighlight, false, 0, true);
			addChildWidget(playButton);
			
			var pauseButton:PauseButton = new PauseButton();
			pauseButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE
			pauseButton.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			pauseButton.addEventListener(MouseEvent.ROLL_OVER, showHighlight, false, 0, true);
			pauseButton.addEventListener(MouseEvent.ROLL_OUT, removeHighlight, false, 0, true);
			addChildWidget(pauseButton);
			
			// Middle controls
			var middleControls:Widget = new Widget();
			middleControls.layoutMetadata.verticalAlign = VerticalAlign.BOTTOM;
			middleControls.layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			middleControls.layoutMetadata.percentWidth = 100;
			middleControls.layoutMetadata.height = 44;
			
			// Current time
			var currentTime:CurrentTimeWidget = new CurrentTimeWidget();
			currentTime.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			currentTime.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			currentTime.layoutMetadata.height = 25;
			middleControls.addChildWidget(currentTime);
			
			// Spacer
			var beforeScrubSpacer:Widget = new Widget();
			beforeScrubSpacer.width = 10;
			middleControls.addChildWidget(beforeScrubSpacer);
			
			// Scrub bar
			var scrubBar:ScrubBar = new ScrubBar();
			scrubBar.id = WidgetIDs.SCRUB_BAR;
			scrubBar.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			scrubBar.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			scrubBar.layoutMetadata.percentWidth = 100;
			scrubBar.layoutMetadata.height = 25;
			scrubBar.includeTimeHint = false;
			middleControls.addChildWidget(scrubBar);
			
			// Spacer
			var afterScrubSpacer:Widget = new Widget();
			afterScrubSpacer.width = 10;
			middleControls.addChildWidget(afterScrubSpacer);
			
			// Duration
			var totalTime:TotalTimeWidget = new TotalTimeWidget();
			totalTime.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			totalTime.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			totalTime.layoutMetadata.height = 25;
			middleControls.addChildWidget(totalTime);
			
			addChildWidget(middleControls);
			
			// FullScreen
			var fullscreenLeaveButton:FullScreenLeaveButton = new FullScreenLeaveButton();
			fullscreenLeaveButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;	
			fullscreenLeaveButton.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			fullscreenLeaveButton.addEventListener(MouseEvent.ROLL_OVER, showHighlight, false, 0, true);
			fullscreenLeaveButton.addEventListener(MouseEvent.ROLL_OUT, removeHighlight, false, 0, true);
			addChildWidget(fullscreenLeaveButton);
			
			var fullscreenEnterButton:FullScreenEnterButton = new FullScreenEnterButton();
			fullscreenEnterButton.id = WidgetIDs.FULL_SCREEN_ENTER_BUTTON;
			fullscreenEnterButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			fullscreenEnterButton.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			fullscreenEnterButton.addEventListener(MouseEvent.ROLL_OVER, showHighlight, false, 0, true);
			fullscreenEnterButton.addEventListener(MouseEvent.ROLL_OUT, removeHighlight, false, 0, true);
			addChildWidget(fullscreenEnterButton);
			
			var rightMargin:Widget = new Widget();
			rightMargin.face = AssetIDs.CONTROL_BAR_BACKDROP_RIGHT;
			rightMargin.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			addChildWidget(rightMargin);
			
			// Configure
			configureWidgets([leftMargin, playButton, pauseButton, middleControls, currentTime, beforeScrubSpacer, scrubBar, afterScrubSpacer, totalTime, fullscreenLeaveButton, fullscreenEnterButton, rightMargin]);
			
			measure();
			
			highlight = new ButtonHighlight(assetManager);
		}
		
		// INTERNALS
		//
		
		private function configureWidgets(widgets:Array):void
		{
			for each( var widget:Widget in widgets)
			{
				if (widget)
				{
					widget.configure(<default/>, assetManager);					
				}
			}
		}
		
		protected function removeHighlight(event:Event=null):void{
			if(highlight.parent) removeChild(highlight);
		}
		
		protected function showHighlight(event:Event):void{
			if(isNaN(event.target.width) || isNaN(event.target.height)) return;
			addChildAt(highlight, 1);
			
			//calculate it once [cut down on calculations]
			if(!highlightSize) highlightSize = new Rectangle(0, 0, highlight.width/2, highlight.height/2);
			
			highlight.x = (event.target.x+event.target.width/2)-highlightSize.width;
			highlight.y = (event.target.y+event.target.height/2)-highlightSize.height;
		}
		
		protected var highlight:ButtonHighlight;
		protected var highlightSize:Rectangle;
		
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.PLAY;
	}
}