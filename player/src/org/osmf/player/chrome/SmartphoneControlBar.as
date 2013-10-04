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
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.assets.FontAsset;
	import org.osmf.player.chrome.widgets.AutoHideWidget;
	import org.osmf.player.chrome.widgets.BackButton;
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
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;

	/**
	 * MobileControlBar
	 * @author johncblandii
	 */
	public class SmartphoneControlBar extends AutoHideWidget implements IControlBar{
		
		// OVERRIDES
		//
		override public function configure(xml:XML, assetManager:AssetsManager):void{
			id = WidgetIDs.CONTROL_BAR;
			fadeSteps = 6;
			face = AssetIDs.CONTROL_BAR_BACKDROP;
			
			layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			layoutMetadata.layoutMode = LayoutMode.NONE;
			layoutMetadata.height = 220;
			
			FontAsset(assetManager.getAsset(AssetIDs.DEFAULT_FONT)).resource.size = 16;
			FontAsset(assetManager.getAsset(AssetIDs.DEFAULT_FONT_BOLD)).resource.size = 16;
			
			super.configure(xml, assetManager);
			
			// Top Row Controls 
			var controlsTop:Widget = new Widget();
			controlsTop.layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			controlsTop.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			controlsTop.layoutMetadata.verticalAlign = VerticalAlign.TOP;
			controlsTop.layoutMetadata.top = 40;
			controlsTop.layoutMetadata.left = 40;
			controlsTop.layoutMetadata.right = 40;
					
			// Current time
			var currentTime:CurrentTimeWidget = new CurrentTimeWidget();
			currentTime.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			currentTime.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			controlsTop.addChildWidget(currentTime);
			
			var beforeScrubBarMargin:Widget = getSpacer(20);
			controlsTop.addChildWidget(beforeScrubBarMargin);
			
			// Scrub bar
			var scrubBar:ScrubBar = new ScrubBar();
			scrubBar.id = WidgetIDs.SCRUB_BAR;
			scrubBar.includeTimeHint = false;
			scrubBar.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			scrubBar.layoutMetadata.verticalAlign = VerticalAlign.TOP;
			scrubBar.layoutMetadata.percentWidth = 100;
			controlsTop.addChildWidget(scrubBar);
			
			var afterScrubBarMargin:Widget = getSpacer(20);
			controlsTop.addChildWidget(afterScrubBarMargin);
			
			// Duration
			var totalTime:TotalTimeWidget = new TotalTimeWidget();
			totalTime.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			totalTime.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			controlsTop.addChildWidget(totalTime);
				
			addChildWidget(controlsTop);
				
			// Bottom row Controls
			var controlsBottom:Widget = new Widget();
			controlsBottom.layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			controlsBottom.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			controlsBottom.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			controlsBottom.layoutMetadata.bottom = 20;
				
			// Back
			var backButton:BackButton = new BackButton();
			backButton.layoutMetadata.verticalAlign = VerticalAlign.TOP;
			backButton.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			backButton.addEventListener(MouseEvent.ROLL_OVER, showHighlight, false, 0, true);
			backButton.addEventListener(MouseEvent.ROLL_OUT, removeHighlight, false, 0, true);
			controlsBottom.addChildWidget(backButton);
			
			// separator
			var afterBackSeparator:Widget = getSeparator();
			controlsBottom.addChildWidget(afterBackSeparator);
		
			// Play/pause
			var playButton:PlayButton = new PlayButton();
			playButton.layoutMetadata.verticalAlign = VerticalAlign.TOP;
			playButton.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			playButton.addEventListener(MouseEvent.ROLL_OVER, showHighlight, false, 0, true);
			playButton.addEventListener(MouseEvent.ROLL_OUT, removeHighlight, false, 0, true);
			controlsBottom.addChildWidget(playButton);
			
			var pauseButton:PauseButton = new PauseButton();
			pauseButton.layoutMetadata.verticalAlign = VerticalAlign.TOP;
			pauseButton.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			pauseButton.addEventListener(MouseEvent.ROLL_OVER, showHighlight, false, 0, true);
			pauseButton.addEventListener(MouseEvent.ROLL_OUT, removeHighlight, false, 0, true);
			controlsBottom.addChildWidget(pauseButton);
			
			// separator
			var afterPlayPauseSeparator:Widget = getSeparator();
			controlsBottom.addChildWidget(afterPlayPauseSeparator);
			
			// FullScreen
			var fullscreenLeaveButton:FullScreenLeaveButton = new FullScreenLeaveButton();
			fullscreenLeaveButton.twoStepFullScreen = true;
			fullscreenLeaveButton.layoutMetadata.verticalAlign = VerticalAlign.TOP;	
			fullscreenLeaveButton.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			fullscreenLeaveButton.addEventListener(MouseEvent.ROLL_OVER, showHighlight, false, 0, true);
			fullscreenLeaveButton.addEventListener(MouseEvent.ROLL_OUT, removeHighlight, false, 0, true);
			controlsBottom.addChildWidget(fullscreenLeaveButton);
			
			var fullscreenEnterButton:FullScreenEnterButton = new FullScreenEnterButton();
			fullscreenEnterButton.twoStepFullScreen = true;
			fullscreenEnterButton.id = WidgetIDs.FULL_SCREEN_ENTER_BUTTON;
			fullscreenEnterButton.layoutMetadata.verticalAlign = VerticalAlign.TOP;
			fullscreenEnterButton.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			fullscreenEnterButton.addEventListener(MouseEvent.ROLL_OVER, showHighlight, false, 0, true);
			fullscreenEnterButton.addEventListener(MouseEvent.ROLL_OUT, removeHighlight, false, 0, true);
			controlsBottom.addChildWidget(fullscreenEnterButton);
			
			addChildWidget(controlsBottom);
			
			// Configure
			configureWidgets
				(	[controlsTop, currentTime, beforeScrubBarMargin, scrubBar, afterScrubBarMargin, totalTime,
					 controlsBottom, backButton, afterBackSeparator, playButton, pauseButton, afterPlayPauseSeparator, fullscreenLeaveButton, fullscreenEnterButton]
				);
			
			measure();
			
			highlight = new ButtonHighlight(assetManager);
		}
		
		protected function removeHighlight(event:Event=null):void{
			if(highlight.parent) removeChild(highlight);
		}
		
		protected function showHighlight(event:Event):void{
			if(isNaN(event.target.width) || isNaN(event.target.height)) return;
			addChildAt(highlight, 1);
			
			//calculate it once [cut down on calculations]
			if(!highlightSize) highlightSize = new Rectangle(0, 0, highlight.width/2, highlight.height/2);
			
			highlight.x = (event.target.parent.x+event.target.x+event.target.width/2)-highlightSize.width;
			highlight.y = (event.target.parent.y+event.target.y+event.target.height/2)-highlightSize.height;
		}
		
		override protected function onAutoHideTimer(event:Event):void{
			if(playTrait && (playTrait.playState == PlayState.PAUSED || playTrait.playState == PlayState.STOPPED)) return;
			super.onAutoHideTimer(event);
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void{
			super.processRequiredTraitsAvailable(element);
			playTrait = element.getTrait(MediaTraitType.PLAY) as PlayTrait;
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
		
		protected function getSeparator():Widget{
			var widget:Widget = new Widget();
			widget.face = AssetIDs.BUTTON_SEPARATOR;
			return widget;
		}
		
		protected function getMargin(face:String, horizontalAlign:String, assetManager:AssetsManager):Widget{
			var margin:Widget = new Widget();
			margin.face = face;
			margin.layoutMetadata.horizontalAlign = horizontalAlign;
			margin.layoutMetadata.verticalAlign = VerticalAlign.TOP;
			return margin;
		}
		
		protected function getSpacer(value:Number=10, direction:String="horizontal"):Widget{
			var spacer:Widget = new Widget();
			if(direction == "horizontal") spacer.width = value;
			else spacer.height = value;
			return spacer;
		}
		
		protected var playTrait:PlayTrait;
		
		protected var highlight:ButtonHighlight;
		protected var highlightSize:Rectangle;
		
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.PLAY;
	}
}