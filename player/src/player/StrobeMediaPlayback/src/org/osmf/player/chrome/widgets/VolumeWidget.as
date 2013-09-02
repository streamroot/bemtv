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
	import flash.events.MouseEvent;
	
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.events.ScrubberEvent;
	import org.osmf.events.AudioEvent;
	import org.osmf.layout.LayoutMode;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.MediaTraitType;

	public class VolumeWidget extends Widget
	{
		public var track:String = AssetIDs.VOLUME_BAR_TRACK;
		public var trackBottom:String = AssetIDs.VOLUME_BAR_TRACK_END;
		
		public var sliderUpFace:String = AssetIDs.VOLUME_BAR_SLIDER_NORMAL;
		public var sliderDownFace:String = AssetIDs.VOLUME_BAR_SLIDER_DOWN;
		
		public var sliderStart:Number = 10.0;
		public var sliderEnd:Number = 83.0;
		

		public function VolumeWidget()
		{
			super();
			mouseEnabled = true;
						
			face = AssetIDs.VOLUME_BAR_BACKDROP;
			layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			
			volumeClickArea = new Sprite();
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(MouseEvent.CLICK, onMouseClick);
			
			addChild(volumeClickArea);

		}
		
		public function get slider():Slider
		{
			return _slider;
		}

		// Overrides
		//

		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);	
			
			volumeTrack = assetManager.getDisplayObject(track) || new Sprite();
			volumeTrackBottom = assetManager.getDisplayObject(trackBottom) || new Sprite();
			sliderFace = assetManager.getDisplayObject(sliderUpFace) || new Sprite();

			volumeTrack.height = 0.0;
			
			// Vertical slider
			_slider = new Slider(sliderFace, sliderFace, sliderFace);
			_slider.enabled = true;
			_slider.y = sliderStart;
			_slider.origin = sliderStart;
			_slider.rangeY = sliderEnd - sliderStart - _slider.height / 2;
			_slider.rangeX = 0.0;
			_slider.addEventListener(ScrubberEvent.SCRUB_UPDATE, onSliderUpdate);
			_slider.addEventListener(ScrubberEvent.SCRUB_END, onSliderEnd);

			_slider.mouseEnabled = true;
			
			volumeClickArea.x = width / 2.0 - _slider.width / 2.0;
			volumeClickArea.graphics.clear();
			volumeClickArea.graphics.beginFill(0xFFFFFF, 0);
			volumeClickArea.graphics.drawRect(0.0, sliderStart, _slider.width, sliderEnd - sliderStart + _slider.height / 2.0);
			volumeClickArea.graphics.endFill();
			volumeClickArea.height = sliderEnd - sliderStart + _slider.height / 2.0;
			
			volumeTrackBottom.x = volumeClickArea.width / 2.0 - volumeTrackBottom.width / 2.0;
			volumeTrackBottom.y = sliderEnd;
			volumeTrack.x = volumeTrackBottom.x;
			
			volumeClickArea.addChild(volumeTrackBottom);
			volumeClickArea.addChild(volumeTrack);
			volumeClickArea.addChild(_slider);
		}
				
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
		
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void
		{
			visible = true;
			audible = media ? media.getTrait(MediaTraitType.AUDIO) as AudioTrait : null;
			audible.addEventListener(AudioEvent.MUTED_CHANGE, onMutedChange);
			audible.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);

			onMutedChange();
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{
			visible = false;	
		}
		
		// Internals
		//
		
		private function onMutedChange(event:AudioEvent = null):void
		{
			updateSliderPosition(audible.muted ? 0.0 : audible.volume);
		}		
		
		private function onVolumeChange(event:AudioEvent = null):void
		{
			updateSliderPosition(event.volume);
		}		
		
		private function onSliderUpdate(event:ScrubberEvent = null):void
		{		
			if (audible)
			{				
				var newVolume:Number = 1.0 - (slider.y - sliderStart) / (sliderEnd - sliderStart - slider.height);		
				audible.volume = newVolume;
				audible.muted = newVolume <= 0.0;
				if(!audible.muted)
				{
					volumeTrack.height = Math.max(0.0, sliderEnd - _slider.y - _slider.height / 2.0);
					volumeTrack.y = _slider.y + _slider.height / 2.0;
				}
			}

		}
		
		private function updateSliderPosition(volume:Number):void
		{
			if (volume <= 0)
			{
				_slider.y = sliderEnd - slider.height / 2.0;
				volumeTrack.height = 0.0;
				volumeTrack.y = sliderEnd;
			}
			else
			{
				_slider.y = sliderEnd - slider.height - volume * (sliderEnd - sliderStart- slider.height);
				volumeTrack.height = Math.max(0.0, sliderEnd - _slider.y - _slider.height / 2.0);
				volumeTrack.y = _slider.y + _slider.height / 2.0;
			}	
				
		}
		
		private function onSliderEnd(event:ScrubberEvent):void
		{
			onSliderUpdate();
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			event.stopPropagation();
			
			// Make sure we clicked inside the volume track
			if(mouseY > (sliderStart - _slider.height / 2.0) && (_slider.y + _slider.mouseY  < sliderEnd + _slider.height / 2.0))
			{
				_slider.y = volumeClickArea.mouseY - _slider.height / 2.0;
				slider.start(false);
			}
		}
		
		private function onMouseClick(event:MouseEvent):void
		{
			event.stopPropagation();
			// Make sure we clicked inside the volume track
			if(mouseY > (sliderStart - _slider.height / 2.0) && (_slider.y + _slider.mouseY  < sliderEnd + _slider.height / 2.0))
			{
				_slider.y = volumeClickArea.mouseY - _slider.height / 2.0;
				onSliderUpdate();
			}
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			// stop event from propagating back to parent
			event.stopPropagation();
			if(mouseY > (sliderStart - _slider.height / 2.0) && (_slider.y + _slider.mouseY  < sliderEnd + _slider.height / 2.0))				
			{
				if (_slider.sliding)
				{ 
					onSliderUpdate();
				}
				else if (event.buttonDown)
				{
					updateSliderPosition(audible.volume);
					_slider.start(false);
				}
			}
		}
						
		private var _slider:Slider;
		
		private var volumeClickArea:Sprite;
		private var volumeTrack:DisplayObject;
		private var volumeTrackBottom:DisplayObject;
		private var sliderFace:DisplayObject;
		private var audible:AudioTrait;
		
		/* static */
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.AUDIO;

	}
}