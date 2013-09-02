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

package org.osmf.player.chrome
{
	import flash.display.DisplayObject;
	
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.widgets.AutoHideWidget;
	import org.osmf.player.chrome.widgets.FullScreenEnterButton;
	import org.osmf.player.chrome.widgets.FullScreenLeaveButton;
	import org.osmf.player.chrome.widgets.MuteButton;
	import org.osmf.player.chrome.widgets.PauseButton;
	import org.osmf.player.chrome.widgets.PlayButton;
	import org.osmf.player.chrome.widgets.PlaylistNextButton;
	import org.osmf.player.chrome.widgets.PlaylistPreviousButton;
	import org.osmf.player.chrome.widgets.QualityIndicator;
	import org.osmf.player.chrome.widgets.ScrubBar;
	import org.osmf.player.chrome.widgets.TimeViewWidget;
	import org.osmf.player.chrome.widgets.Widget;
	import org.osmf.player.chrome.widgets.WidgetIDs;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;

	/**
	 * ControlBar contains all the control widgets and is responsible for their layout.
	 */ 
	public class ControlBar extends AutoHideWidget implements IControlBar
	{
		// Overrides
		//
	
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			id = WidgetIDs.CONTROL_BAR;
			face = AssetIDs.CONTROL_BAR_BACKDROP;
			fadeSteps = 6;			
			
			layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			layoutMetadata.verticalAlign = VerticalAlign.TOP;
			layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			super.configure(xml, assetManager);
			
			// Left margin
			var leftMargin:Widget = new Widget();
			leftMargin.face = AssetIDs.CONTROL_BAR_BACKDROP_LEFT;
			leftMargin.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			
			addChildWidget(leftMargin);
			
			// Spacer
			var beforePlaySpacer:Widget = new Widget();
			beforePlaySpacer.width = 6;			
			addChildWidget(beforePlaySpacer);
			
			var leftControls:Widget = new Widget();
			leftControls.layoutMetadata.percentHeight = 100;
			leftControls.layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			leftControls.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			
			// Play/pause
			var playButton:PlayButton = new PlayButton();
			playButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE
			playButton.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			leftControls.addChildWidget(playButton);
			
			var pauseButton:PauseButton = new PauseButton();
			pauseButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE
			pauseButton.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			leftControls.addChildWidget(pauseButton);
			
			// Previous/Next
			var previousButton:PlaylistPreviousButton = new PlaylistPreviousButton();
			previousButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE
			previousButton.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			leftControls.addChildWidget(previousButton);
			
			var nextButton:PlaylistNextButton = new PlaylistNextButton();
			nextButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE
			nextButton.layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;
			leftControls.addChildWidget(nextButton);
			
			addChildWidget(leftControls);		
			
			// Spacer
			var afterPlaySpacer:Widget = new Widget();
			afterPlaySpacer.width = 10;			
			
			addChildWidget(afterPlaySpacer);
			
			// Scrub bar
			var scrubBar:ScrubBar = new ScrubBar();		
			scrubBar.id = WidgetIDs.SCRUB_BAR;
			scrubBar.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			scrubBar.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			scrubBar.layoutMetadata.percentWidth = 100;
			addChildWidget(scrubBar);
			
			// Right side
			var rightControls:Widget = new Widget();
			rightControls.layoutMetadata.percentHeight = 100;
			rightControls.layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			rightControls.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			rightControls.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;			
			
			// Spacer
			var afterScrubSpacer:Widget = new Widget();
			afterScrubSpacer.width = 5;
			rightControls.addChildWidget(afterScrubSpacer);
			
			// Time view
			var timeViewWidget:TimeViewWidget = new TimeViewWidget();
			timeViewWidget.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			timeViewWidget.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;	
			rightControls.addChildWidget(timeViewWidget);
			
			// HD indicator
			var hdIndicator:QualityIndicator = new QualityIndicator();
			hdIndicator.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			hdIndicator.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			rightControls.addChildWidget(hdIndicator);
			
			// Spacer
			var afterTimeSpacer:Widget = new Widget();
			afterTimeSpacer.width = 5;
			rightControls.addChildWidget(afterTimeSpacer);
			
			// Mute/unmute
			var muteButton:MuteButton = new MuteButton();
			muteButton.id = WidgetIDs.MUTE_BUTTON;
			muteButton.volumeSteps = 3;
			muteButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			muteButton.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			rightControls.addChildWidget(muteButton);
			
			// Spacer
			var afterVolumeSpacer:Widget = new Widget();
			afterVolumeSpacer.width = 11;
			rightControls.addChildWidget(afterVolumeSpacer);
			
			// FullScreen			
			var fullscreenLeaveButton:FullScreenLeaveButton = new FullScreenLeaveButton();
			fullscreenLeaveButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			fullscreenLeaveButton.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			rightControls.addChildWidget(fullscreenLeaveButton);
		
			fullscreenEnterButton.id = WidgetIDs.FULL_SCREEN_ENTER_BUTTON; 
			fullscreenEnterButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			fullscreenEnterButton.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			rightControls.addChildWidget(fullscreenEnterButton);
			
			addChildWidget(rightControls);
			
			// Spacer
			var afterFullscreenSpacer:Widget = new Widget();
			afterFullscreenSpacer.layoutMetadata.width = 13;
			addChildWidget(afterFullscreenSpacer);

			var filler:Widget = new Widget();

			var rightMargin:Widget = new Widget();
			rightMargin.face = AssetIDs.CONTROL_BAR_BACKDROP_RIGHT;
			rightMargin.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			addChildWidget(rightMargin);				


			configureWidgets
				(	[ leftMargin, beforePlaySpacer, pauseButton, playButton, previousButton, nextButton, afterPlaySpacer
					, leftControls		
					, scrubBar, afterScrubSpacer
					, timeViewWidget, afterTimeSpacer
					, hdIndicator, muteButton, afterVolumeSpacer
					, fullscreenEnterButton, fullscreenLeaveButton, afterFullscreenSpacer
					, rightControls, rightMargin
					]
				);
			
			measure();
		}

		// Internals
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
		
		private var fullscreenEnterButton:FullScreenEnterButton = new FullScreenEnterButton();
		
		private var playTrait:PlayTrait;
		
		private var scrubBarLiveTrack:DisplayObject;
		
		private var lastWidth:Number;
		private var lastHeight:Number;
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.PLAY;
	}
}