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
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.layout.LayoutTargetSprite;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.assets.FontAsset;
	import org.osmf.player.chrome.events.ScrubberEvent;
	import org.osmf.player.chrome.hint.Hint;
	import org.osmf.player.chrome.hint.WidgetHint;
	import org.osmf.player.chrome.metadata.ChromeMetadata;
	import org.osmf.player.chrome.utils.FormatUtils;
	import org.osmf.player.chrome.utils.MediaElementUtils;
	import org.osmf.player.media.StrobeMediaPlayer;
	import org.osmf.player.metadata.MediaMetadata;
	import org.osmf.traits.DVRTrait;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	
	
	/**
	 * ScrubBar widget is responsible for setting up the scrub bar UI and behaviour.
	 */ 
	public class ScrubBar extends Widget
	{
		public var track:String = AssetIDs.SCRUB_BAR_TRACK;
		public var trackLeft:String = AssetIDs.SCRUB_BAR_TRACK_LEFT;
		public var trackRight:String = AssetIDs.SCRUB_BAR_TRACK_RIGHT;
		public var loadedTrack:String = AssetIDs.SCRUB_BAR_LOADED_TRACK;
		public var loadedTrackEnd:String = AssetIDs.SCRUB_BAR_LOADED_TRACK_END;
		public var playedTrack:String = AssetIDs.SCRUB_BAR_PLAYED_TRACK;
		public var playedTrackSeeking:String = AssetIDs.SCRUB_BAR_PLAYED_TRACK_SEEKING;
		public var dvrLiveTrack:String = AssetIDs.SCRUB_BAR_DVR_LIVE_TRACK;
		public var dvrLiveInactiveTrack:String = AssetIDs.SCRUB_BAR_DVR_LIVE_INACTIVE_TRACK;
		
		public var font:String = AssetIDs.DEFAULT_FONT;
		public var scrubberUp:String = AssetIDs.SCRUB_BAR_SCRUBBER_NORMAL;
		public var scrubberDown:String = AssetIDs.SCRUB_BAR_SCRUBBER_DOWN;
		public var scrubberOver:String = AssetIDs.SCRUB_BAR_SCRUBBER_OVER;
		public var scrubberDisabled:String = AssetIDs.SCRUB_BAR_SCRUBBER_DISABLED;
		public var timeHint:String = AssetIDs.SCRUB_BAR_TIME_HINT;
		public var liveOnlyTrack:String = AssetIDs.SCRUB_BAR_LIVE_ONLY_TRACK;
		public var liveOnlyInactiveTrack:String = AssetIDs.SCRUB_BAR_LIVE_ONLY_INACTIVE_TRACK;
		
		public var includeTimeHint:Boolean = true;
		
		// Constructor
		//
		
		public function ScrubBar()
		{
			scrubBarClickArea = new Sprite();
			scrubBarClickArea.addEventListener(MouseEvent.MOUSE_DOWN, onTrackMouseDown);
			scrubBarClickArea.addEventListener(MouseEvent.MOUSE_UP, onTrackMouseUp);
			scrubBarClickArea.addEventListener(MouseEvent.MOUSE_OVER, onTrackMouseOver);
			scrubBarClickArea.addEventListener(MouseEvent.MOUSE_MOVE, onTrackMouseMove);
			scrubBarClickArea.addEventListener(MouseEvent.MOUSE_OUT, onTrackMouseOut);
			
			addChild(scrubBarClickArea);
			
			currentPositionTimer = new Timer(CURRENT_POSITION_UPDATE_INTERVAL);
			currentPositionTimer.addEventListener(TimerEvent.TIMER, updateScrubberPosition);
			
			super();
		}
		
		// Overrides
		//
				
		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean=true):void
		{
			if (availableWidth == 0.0 || availableHeight == 0.0)
			{
				return;
			}
			
			if (scrubber.width != scrubberWidth || lastWidth != availableWidth || lastHeight != availableHeight)
			{
				lastWidth = availableWidth;
				lastHeight = availableHeight;
				
				scrubBarWidth = Math.max(10.0, availableWidth);
				scrubberWidth = scrubber.width;
			
				scrubBarTrack.x = scrubBarTrackLeft.width;
				scrubBarTrack.y = scrubBarTrackLeft.y; 
				scrubBarTrack.width = scrubBarWidth - scrubBarTrackLeft.width - scrubBarTrackRight.width;
				
				scrubBarLiveOnlyTrack.x = scrubBarTrack.x;
				scrubBarLiveOnlyTrack.y = scrubBarTrack.y + 2.0; 
				scrubBarLiveOnlyTrack.width = scrubBarWidth - scrubBarTrackLeft.width - scrubBarTrackRight.width; 
				
				scrubBarLiveOnlyInactiveTrack.x = scrubBarTrack.x;
				scrubBarLiveOnlyInactiveTrack.y = scrubBarTrack.y + 2.0; 
				scrubBarLiveOnlyInactiveTrack.width = scrubBarWidth - scrubBarTrackLeft.width - scrubBarTrackRight.width; 
				
				scrubBarTrackRight.x = scrubBarTrack.width + scrubBarTrackLeft.width;
				scrubBarTrackRight.y = scrubBarTrackLeft.y;

				scrubberStart = scrubBarTrackLeft.x - scrubber.width / 2.0;
				scrubberEnd = scrubBarTrackRight.x + scrubBarTrackRight.width - scrubber.width / 2.0;

				scrubBarLoadedTrack.x = scrubBarTrack.x;
				scrubBarLoadedTrack.y = scrubBarTrack.y;
				scrubBarLoadedTrack.width = 0.0;
				scrubBarLoadedTrackEnd.x = scrubBarTrack.x;
				scrubBarLoadedTrackEnd.y = scrubBarTrack.y;
				
				scrubBarPlayedTrackSeeking.x = scrubBarPlayedTrack.x = scrubBarTrack.x;
				scrubBarPlayedTrackSeeking.y = scrubBarPlayedTrack.y = scrubBarTrack.y;
				scrubBarPlayedTrackSeeking.width = scrubBarPlayedTrack.width = 0.0;
				
				scrubber.rangeY = 0.0;
				scrubber.rangeX = scrubberEnd - scrubberStart;

				// DVR support
				if (dvrTrait && dvrTrait.isRecording)
				{
					scrubBarDVRLiveInactiveTrack.y = scrubBarTrack.y + 2.0;
					scrubBarDVRLiveInactiveTrack.x = scrubBarTrack.width + scrubBarTrackLeft.width - scrubBarLiveTrackWidth;
					
					scrubBarDVRLiveTrack.y = scrubBarTrack.y + 2.0;
					scrubBarDVRLiveTrack.x = scrubBarTrack.width + scrubBarTrackLeft.width - scrubBarLiveTrackWidth;
						
					if (_live)
					{
						scrubBarDVRLiveTrack.visible = true;
						scrubBarDVRLiveInactiveTrack.visible = false;
					}
					else
					{
						scrubBarDVRLiveTrack.visible = false;
						scrubBarDVRLiveInactiveTrack.visible = true;
					}
					// When the DVR is present, we need to adjusts the scrubBarWidth & scrubberEnd used for computing the cursor time 
					// by extracting the width of the DVR bar 
					scrubberEnd -= scrubBarLiveTrackWidth;
				}
				else
				{
					scrubBarDVRLiveTrack.visible = false;
					scrubBarDVRLiveInactiveTrack.visible = false;
					
					if (media && streamType != StreamType.LIVE)
					{
						var metadata:Metadata = media ? media.getMetadata(ChromeMetadata.CHROME_METADATA_KEY) : null;
						if (metadata != null)
						{
							metadata.removeValue(ChromeMetadata.LIVE);
						}
					}
				}
				
				//if the scrubber is the larger of the two, center the scrubber on the scrubBar
				scrubber.y = scrubber.height > scrubBarTrack.height ? (scrubBarTrack.y+(scrubBarTrack.height/2))-(scrubber.height/2) : scrubBarTrack.y;
				scrubber.origin = scrubberStart; 
				
				highlight.y = (scrubber.y+scrubber.height/2)-(highlight.height/2);
				
				scrubBarClickArea.x = scrubBarTrack.x;
				scrubBarClickArea.y = scrubber.height > scrubBarTrack.height ? scrubber.y : scrubBarTrack.y;
				scrubBarClickArea.graphics.clear();
				scrubBarClickArea.graphics.beginFill(0xFFFFFF, 0.0);
				scrubBarClickArea.graphics.drawRect(0.0, 0.0, scrubBarTrack.width, Math.max(scrubBarTrack.height, scrubber.height));
				scrubBarClickArea.graphics.endFill();
				
				updateScrubberPosition();
				updateState();
			}
		}		
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);
									
			scrubBarTrack = assetManager.getDisplayObject(track) || new Sprite();
			addChild(scrubBarTrack);
			
			scrubBarLiveOnlyTrack = assetManager.getDisplayObject(liveOnlyTrack) || new Sprite();
			scrubBarLiveOnlyTrack.visible = false;
			addChild(scrubBarLiveOnlyTrack);
			
			scrubBarLiveOnlyInactiveTrack = assetManager.getDisplayObject(liveOnlyInactiveTrack) || new Sprite();
			scrubBarLiveOnlyInactiveTrack.visible = false;
			addChild(scrubBarLiveOnlyInactiveTrack);
						
			scrubBarLoadedTrack = assetManager.getDisplayObject(loadedTrack) || new Sprite();
			addChild(scrubBarLoadedTrack);

			scrubBarLoadedTrackEnd = assetManager.getDisplayObject(loadedTrackEnd) || new Sprite();
			addChild(scrubBarLoadedTrackEnd);

			scrubBarPlayedTrack = assetManager.getDisplayObject(playedTrack) || new Sprite();
			addChild(scrubBarPlayedTrack);
		
			scrubBarPlayedTrackSeeking = assetManager.getDisplayObject(playedTrackSeeking) || new Sprite();
			addChild(scrubBarPlayedTrackSeeking);
			
			// TODO: DVR tracks - we need a separate Widget for this.
			scrubBarDVRLiveTrack = assetManager.getDisplayObject(dvrLiveTrack) || new Sprite();			
			scrubBarDVRLiveInactiveTrack = assetManager.getDisplayObject(dvrLiveInactiveTrack) || new Sprite();
			scrubBarDVRLiveInactiveTrack.visible = false;
			addChild(scrubBarDVRLiveInactiveTrack);
			// WORKAROUND: Cache the scrubBarLiveTrackWidth as a workarround for the SWF symbols getting resized when added to stage.
			scrubBarLiveTrackWidth = scrubBarDVRLiveTrack.width;
			
			// Initialize the DVR handlers
			scrubBarDVRLiveInactiveTrack.addEventListener(MouseEvent.CLICK, goToLive);		
			
			scrubBarDVRLiveTrack.addEventListener(MouseEvent.MOUSE_MOVE, onTrackMouseMove);
			scrubBarDVRLiveTrack.addEventListener(MouseEvent.MOUSE_OUT, onTrackMouseOut);
			scrubBarDVRLiveInactiveTrack.addEventListener(MouseEvent.MOUSE_MOVE, onTrackMouseMove);
			scrubBarDVRLiveInactiveTrack.addEventListener(MouseEvent.MOUSE_OUT, onTrackMouseOut);	
			
			// Start with the non-live live track - it will get the live view on play. 
			// Note that the current use of alpha is a temporary workarround for the lack of a special asset. 
			scrubBarDVRLiveTrack.visible = false;
			scrubBarDVRLiveInactiveTrack.visible = false;
			
			addChild(scrubBarDVRLiveTrack);
			
			scrubBarTrackLeft = assetManager.getDisplayObject(trackLeft) || new Sprite();			
			addChild(scrubBarTrackLeft);
			
			scrubBarTrackRight = assetManager.getDisplayObject(trackRight) || new Sprite();			
			addChild(scrubBarTrackRight);
			
			scrubber
				= new Slider
					( assetManager.getDisplayObject(scrubberUp)
					, assetManager.getDisplayObject(scrubberDown)
					, assetManager.getDisplayObject(scrubberDisabled)
					, assetManager.getDisplayObject(scrubberOver)
					);

			scrubber.addEventListener(MouseEvent.MOUSE_MOVE, onTrackMouseMove);
			scrubber.addEventListener(MouseEvent.MOUSE_OUT, onScrubberOut);
			scrubber.addEventListener(MouseEvent.MOUSE_OVER, onScrubberOver);
			
			scrubber.enabled = false;
			scrubber.addEventListener(ScrubberEvent.SCRUB_START, onScrubberStart);
			scrubber.addEventListener(ScrubberEvent.SCRUB_UPDATE, onScrubberUpdate);
			scrubber.addEventListener(ScrubberEvent.SCRUB_END, onScrubberEnd);
			
			addChild(scrubber);
			
			highlight = new ButtonHighlight(assetManager);
			
			measure();
			updateState();
			
			if(includeTimeHint){
				scrubBarHint = new TimeHintWidget();
				scrubBarHint.face = timeHint;
				scrubBarHint.autoSize = true;
				scrubBarHint.tintColor = tintColor;
				scrubBarHint.configure(<default/>, assetManager);
			}
		}
				
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
		
		override protected function processRequiredTraitsAvailable(media:MediaElement):void
		{
			updateState();
		}
		
		override protected function processRequiredTraitsUnavailable(media:MediaElement):void
		{
			updateState();
		}
		
		override protected function onMediaElementTraitAdd(event:MediaElementEvent):void
		{
			if (event.traitType == MediaTraitType.PLAY)
			{
				// Prepare for getting the player to the Live content directly (UX rule)
				var playTrait:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
				if (playTrait.playState != PlayState.PLAYING)
				{
					started = false;
					playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onFirstPlayStateChange);
				}
				else
				{
					started = true;
					goToLive();
				}
				playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
				
				if (media)
				{										
					if (streamType == StreamType.LIVE)
					{
						updateLiveBar(playTrait.playState == PlayState.PLAYING);
						
						var metadata:Metadata = new Metadata();
						metadata.addValue(ChromeMetadata.LIVE, true)
						media.addMetadata(ChromeMetadata.CHROME_METADATA_KEY, metadata);		
					}
				}
			}
			if (event.traitType == MediaTraitType.SEEK)
			{
				playTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
				if (playTrait && playTrait.playState == PlayState.PLAYING)
				{
					goToLive();
				}
			}			
		
			updateState(); 
		}
		 
		override protected function onMediaElementTraitRemove(event:MediaElementEvent):void
		{
			updateState();
		}
		
		override public function set media(value:MediaElement):void
		{
			super.media = value;
			if (media == null) return;
			// WORKAROUND: Dispatch TRAIT_ADD events for the traits that the media already has
			for each(var traitType:String in value.traitTypes)
			{
				var traitAddEvent:MediaElementEvent = new MediaElementEvent(MediaElementEvent.TRAIT_ADD, false, false, traitType);						
				onMediaElementTraitAdd(traitAddEvent);
			}
			media.metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataValueChange);			
		}
		
		// Internals
		//
		private function onMetadataValueChange(event:MetadataEvent):void
		{
			var metadata:Metadata = event.target as Metadata;		
			var mediaMetadata:MediaMetadata;
			mediaMetadata = metadata.getValue(MediaMetadata.ID) as MediaMetadata;
			mediaPlayer = mediaMetadata.mediaPlayer;
			updateLiveBar(mediaPlayer.playing);
		}
		
		private function onFirstPlayStateChange(event:PlayEvent):void
		{
			if (event.playState == PlayState.PLAYING)
			{
				started = true;
				updateState();
				var playTrait:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
				if (playTrait)
				{
					playTrait.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onFirstPlayStateChange);
					if (dvrTrait && dvrTrait.isRecording)
					{					
						// Starts the player on Live content directly (UX rule)
						live = true;
					}		
				}
			}
			updateLiveBar(event.playState == PlayState.PLAYING);
		}
		
		private function onPlayStateChange(event:PlayEvent):void
		{
			updateTimerState();
			if (event.playState != PlayState.PLAYING)
			{
				if (dvrTrait)
				{
					live = false;
				}
			}
			updateLiveBar(event.playState == PlayState.PLAYING);		
		}
		
		private function updateLiveBar(playing:Boolean):void
		{
			if (streamType == StreamType.LIVE)
			{
				scrubBarPlayedTrack.visible = false;
				scrubBarLoadedTrackEnd.visible = false;
				
				scrubber.visible = false;
				scrubber.enabled = false;
				
				if (playing)
				{
					setChildIndex(scrubBarLiveOnlyTrack, 10);
					scrubBarLiveOnlyTrack.visible = true;
					scrubBarLiveOnlyInactiveTrack.visible = false;
				}
				else
				{
					scrubBarLiveOnlyTrack.visible = false;
					scrubBarLiveOnlyInactiveTrack.visible = true;					
				}
			}	
			else
			{
				scrubBarLiveOnlyTrack.visible = false;
				scrubBarLiveOnlyInactiveTrack.visible = false;	
				if (playing)
				{
					scrubBarPlayedTrack.visible = true;
					scrubBarLoadedTrackEnd.visible = true;
				}
			}
		}
		
		private function updateState():void
		{
			visible = media != null;
			enabled = media ? media.hasTrait(MediaTraitType.SEEK) : false;
		
			if (streamType == StreamType.LIVE || !started)
			{
				updateLiveBar(started);
			}
			else
			{							
				scrubBarLoadedTrack.visible = media ? media.hasTrait(MediaTraitType.LOAD) : false;
				scrubBarLoadedTrackEnd.visible = media ? media.hasTrait(MediaTraitType.LOAD) : false;
				scrubBarPlayedTrack.visible = media ? media.hasTrait(MediaTraitType.PLAY) : false;
				if (scrubber)
				{
					scrubber.enabled = media ? media.hasTrait(MediaTraitType.SEEK) : false;
					scrubber.visible = true;
				}	
			}
			updateTimerState();
		}
		
		private function updateTimerState():void
		{
			var timeTrait:TimeTrait = media ? media.getTrait(MediaTraitType.TIME) as TimeTrait : null;
			if (timeTrait == null)
			{
				currentPositionTimer.stop();
				
				resetUI();
			}
			else
			{ 
				var playTrait:PlayTrait = media ? media.getTrait(MediaTraitType.PLAY) as PlayTrait : null;
				if (playTrait && !currentPositionTimer.running)
				{
					currentPositionTimer.start();
				}
			}
		}		
		
		private function updateScrubberPosition(event:Event = null):void
		{
			var timeTrait:TimeTrait = media ? media.getTrait(MediaTraitType.TIME) as TimeTrait : null;			
			if (timeTrait != null && timeTrait.duration)
			{
				var loadTrait:LoadTrait = media ? media.getTrait(MediaTraitType.LOAD) as LoadTrait : null;
				var seekTrait:SeekTrait = media ? media.getTrait(MediaTraitType.SEEK) as SeekTrait : null;
				var duration:Number = timeTrait.duration;
			
				var position:Number = isNaN(seekToTime) ? timeTrait.currentTime : seekToTime;
				if (dvrTrait && live) 
				{
					// Since we play the live content the scrubber position is fixed.
					scrubber.x = scrubBarDVRLiveTrack.x - scrubber.width / 2.0 + scrubBarLiveTrackWidth / 2.0;
				}
				else
				{				
					var scrubberX:Number
					= 	scrubberStart
						+ 	(	(scrubberEnd - scrubberStart)
							* position
						)
						/ duration
						||	scrubberStart; // Default value if calc. returns NaN.
					
					scrubber.x = Math.min(scrubberEnd, Math.max(scrubberStart, scrubberX));
					if (loadTrait)
					{
						scrubBarLoadedTrack.width 
							=  ((scrubberEnd - scrubberStart) - scrubBarTrackLeft.width - scrubBarTrackRight.width) 
							* ((loadTrait.bytesTotal && loadTrait.bytesLoaded) 
								? (Math.min(1.0, loadTrait.bytesLoaded / loadTrait.bytesTotal)) 
								: seekTrait ? 1.0 : 0.0);
						scrubBarLoadedTrackEnd.x = scrubBarLoadedTrack.x + scrubBarLoadedTrack.width;
					}
				}
				
				highlight.x = (scrubber.x+scrubber.width/2)-(highlight.width/2);
				scrubBarPlayedTrackSeeking.width = scrubBarPlayedTrack.width = Math.max(0, scrubber.x+(scrubber.width/2));
			}
			else
			{
				resetUI();
			}
		}

		private function seekToX(relativePositition:Number):void
		{
			if (!started)
			{
				return;
			}
			var timeTrait:TimeTrait = media ? media.getTrait(MediaTraitType.TIME) as TimeTrait : null;
			var seekTrait:SeekTrait = media ? media.getTrait(MediaTraitType.SEEK) as SeekTrait : null;
			var playTrait:PlayTrait = media ? media.getTrait(MediaTraitType.PLAY) as PlayTrait : null;
			if (timeTrait && seekTrait)
			{
				if (dvrTrait && dvrTrait.isRecording && relativePositition > scrubBarDVRLiveTrack.x)
				{
					goToLive();
				}
				else
				{
					live = false;
					
					if (relativePositition == -4.0)
					{
						// Set the time to 0 for this position. Fix for ST-176: For long movies, one cannot rewind to the beginning of the movie by scrubbing the cursor
						time = 0.0;
					}
					else
					{
						var time:Number = timeTrait.duration * ((relativePositition - scrubberStart) / (scrubberEnd - scrubberStart));
					}
					
					if (seekTrait.canSeekTo(time)) 
					{
						if (playTrait && playTrait.playState == PlayState.STOPPED)
						{
							// If the stream is stopped when playing it will always start from 0, regardless of this seek,
							// so we make sure the stream is not stopped. We need to check if the element at hand can pause,
							// though:
							if (playTrait.canPause)
							{
								playTrait.play();
								playTrait.pause();
							}
						}
						seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
						seekToTime = time;
						seekTrait.seek(time);
						scrubber.x = Math.max(scrubberStart, scrubberStart + relativePositition);
						highlight.x = (scrubber.x+scrubber.width/2)-(highlight.width/2);
						scrubBarPlayedTrackSeeking.width = scrubBarPlayedTrack.width = scrubber.x + (scrubber.width/2);
					}
				}
			}
		}
		
		private function onSeekingChange(event:SeekEvent):void
		{
			if (event.seeking == false)
			{
				var seekTrait:SeekTrait = event.target as SeekTrait;
				seekTrait.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
				
				updateScrubberPosition();
				seekToTime = NaN;			
			}
		}
		
		private function onScrubberUpdate(event:ScrubberEvent = null):void
		{
			showTimeHint();
			seekToX(scrubber.x);
		}
		
		private function onScrubberOver(event:Event):void{
			addChildAt(highlight, getChildIndex(scrubber)-1); //add it one below the scrubber
		}
		
		private function onScrubberOut(event:MouseEvent):void{
			onTrackMouseOut(event);
			if(highlight.parent) removeChild(highlight);
		}
		
		private function onScrubberStart(event:ScrubberEvent):void
		{
			onScrubberOver(null);
			var playTrait:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
			if (playTrait)
			{
				preScrubPlayState = playTrait.playState;
				if (playTrait.canPause && playTrait.playState != PlayState.PAUSED)
				{
					playTrait.pause();
				}
			}
			
			scrubBarPlayedTrackSeeking.visible = scrubBarPlayedTrack.visible; //only show it if the played track is showing
		}
		
		private function onScrubberEnd(event:ScrubberEvent):void
		{
			onScrubberOut(null);
			seekToX(scrubber.x);
			if (preScrubPlayState)
			{
				var playable:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
				if (playable)
				{
					if (playable.playState != preScrubPlayState)
					{
						switch (preScrubPlayState)
						{
							case PlayState.STOPPED:
								playable.stop();
								break;
							case PlayState.PLAYING:
								playable.play();
								break;
						}
					}
				}
			}
			
			scrubBarPlayedTrackSeeking.visible = false;
		}
		
		private function onTrackMouseDown(event:MouseEvent):void
		{
			seekToX(mouseX - scrubber.width / 2.0);			
			showTimeHint();			
		}
		
		private function onTrackMouseUp(event:MouseEvent):void
		{
			scrubber.stop();		
		}
		
		private function onTrackMouseOver(event:MouseEvent):void
		{
			showTimeHint();
		}
		
		private function onTrackMouseMove(event:MouseEvent):void
		{
			showTimeHint();
			if (event.buttonDown && !scrubber.sliding)
			{
				scrubber.start();			
			}
		}
		
		private function onTrackMouseOut(event:MouseEvent):void
		{
			try
			{
				if (event.relatedObject != scrubber && (event.relatedObject is DisplayObject) && !contains(event.relatedObject) || event.relatedObject == this)
				{
					WidgetHint.getInstance(this, true).hide();			
				}
			}
			catch (e:Error)
			{
				// also hide the tooltip if the related object is null 
				WidgetHint.getInstance(this, true).hide();			
			}
		}
		
		
		private function showTimeHint():void
		{
			if (streamType == StreamType.LIVE)
			{
				// Don't show the time hint for the LIVE streams.
				return;
			}
			if (scrubBarClickArea.mouseX >= 0.0 && scrubBarClickArea.mouseX <= scrubBarClickArea.width)
			{
				var timeTrait:TimeTrait = media ? media.getTrait(MediaTraitType.TIME) as TimeTrait : null;
				if (timeTrait)
				{
					var time:Number = timeTrait.duration * ((mouseX - scrubber.width / 2.0 - scrubberStart) / (scrubberEnd - scrubberStart));
					
					var dvrLive:Boolean = dvrTrait && dvrTrait.isRecording && mouseX > scrubBarDVRLiveTrack.x;
					var currentTimeString:String = FormatUtils.formatTimeStatus(time, timeTrait.duration)[0];
					
					if(scrubBarHint){
						scrubBarHint.text = dvrLive 
							? TIME_LIVE
							: currentTimeString;
						
						WidgetHint.getInstance(this, true).widget 
							? WidgetHint.getInstance(this, true).updatePosition()
							: WidgetHint.getInstance(this, true).widget = scrubBarHint;
					}
				}
			}
		}
		
		private function resetUI():void
		{
			if (scrubber)
			{
				scrubber.x = scrubberStart;
				highlight.x = (scrubber.x+scrubber.width/2)-(highlight.width/2);
			}
			scrubBarPlayedTrackSeeking.width = scrubBarPlayedTrack.width = 0.0;
		}
		
		private function getBufferTime():Number
		{
			var result:Number = 0.0;			
			var loadTrait:NetStreamLoadTrait = media.getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
			if (loadTrait && loadTrait.netStream)
			{
				result = loadTrait.netStream.bufferTime;
			}
			return result;
		}
		
		private function goToLive(event:Event=null):void
		{
			var mediaMetadata:MediaMetadata;
			mediaMetadata = media.metadata.getValue(MediaMetadata.ID) as MediaMetadata;
			var mediaPlayer:StrobeMediaPlayer;
			mediaPlayer = mediaMetadata.mediaPlayer;
			if (mediaPlayer.snapToLive())
			{
				live = true;
			}
		}

		private function get live():Boolean
		{	
			var mediaMetadata:MediaMetadata;
			mediaMetadata = media.metadata.getValue(MediaMetadata.ID) as MediaMetadata;
			if (mediaMetadata != null)
			{
				var mediaPlayer:StrobeMediaPlayer;
				mediaPlayer = mediaMetadata.mediaPlayer;
				return mediaPlayer.isLive;
			}
			return false;
		}
		
		private function set live(value:Boolean):void
		{
			if (dvrTrait == null) return;
			if (!dvrTrait.isRecording) return;
			
			var mediaMetadata:MediaMetadata;
			mediaMetadata = media.metadata.getValue(MediaMetadata.ID) as MediaMetadata;
			var mediaPlayer:StrobeMediaPlayer;
			mediaPlayer = mediaMetadata.mediaPlayer;
			mediaPlayer.isDVRLive = value;
			_live = value;
			if (_live)
			{
				scrubBarDVRLiveTrack.visible = true;
				scrubBarDVRLiveInactiveTrack.visible = false;
			}
			else
			{
				scrubBarDVRLiveTrack.visible = false;
				scrubBarDVRLiveInactiveTrack.visible = true;
			}
			
			// WORKARROUND: In a playlist the childIndex of the dvrLive bar gets bigger then the scrubBarPlayed track, 
			// and this causes "The scrubber isn't positioned at the beginning of the live section when paused inside DVR"
			if (getChildIndex(scrubBarPlayedTrack) < getChildIndex(scrubBarDVRLiveInactiveTrack))
			{
				setChildIndex(scrubBarPlayedTrack, getChildIndex(scrubBarDVRLiveInactiveTrack));
			}
		}
		
		private function get streamType():String
		{			
			if (media == null)
			{
				return "";
			}
			
			return MediaElementUtils.getStreamType(media);
		}
		
		private function get dvrTrait():DVRTrait
		{
			return media ? media.getTrait(MediaTraitType.DVR) as DVRTrait : null;
		}
		
		override public function get height():Number{
			return scrubBarTrack ? scrubBarTrack.height : super.height; 
		}
		
		private var _live:Boolean = false;
		private var highlight:ButtonHighlight;
		private var scrubber:Slider;
		private var scrubBarClickArea:Sprite;
		
		private var scrubBarHint:TimeHintWidget;
		
		private var scrubberStart:Number;
		private var scrubberEnd:Number;
		
		private var scrubBarWidth:Number;
		private var scrubberWidth:Number;
		
		private var currentPositionTimer:Timer;
		
		private var scrubBarTrack:DisplayObject;
		private var scrubBarLoadedTrack:DisplayObject;
		private var scrubBarLoadedTrackEnd:DisplayObject;
		private var scrubBarPlayedTrack:DisplayObject;
		private var scrubBarPlayedTrackSeeking:DisplayObject;
		private var scrubBarTrackLeft:DisplayObject;
		private var scrubBarTrackRight:DisplayObject;
		private var scrubBarDVRLiveTrack:DisplayObject;
		private var scrubBarDVRLiveInactiveTrack:DisplayObject;		
		private var scrubBarLiveOnlyTrack:DisplayObject;
		private var scrubBarLiveOnlyInactiveTrack:DisplayObject;
		
		private var preScrubPlayState:String;
		
		private var lastWidth:Number;
		private var lastHeight:Number;
		
		private var seekToTime:Number;
		private var started:Boolean;
		
		/**
		 * Cache the scrubBarLiveTrackWidth as a workarround for the SWF symbols getting resized when added to stage.
		 */
		private var scrubBarLiveTrackWidth:Number;
		private var mediaPlayer:StrobeMediaPlayer;
		
		/* static */
		
		private static const TIME_LIVE:String = "Live";
		
		private static const CURRENT_POSITION_UPDATE_INTERVAL:int = 100;
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.TIME;
		_requiredTraits[1] = MediaTraitType.DVR;
		
	}
}
