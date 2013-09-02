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
 **********************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import org.osmf.events.AudioEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.media.MediaElement;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.hint.WidgetHint;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.MediaTraitType;
	
	
	public class MuteButton extends ButtonWidget
	{
		public var volumeWidgetFace:String = AssetIDs.VOLUME_BAR_BACKDROP;
		
		// The 3 items below seem to be unused:
		public var sliderUpFace:String = AssetIDs.VOLUME_BAR_SLIDER_NORMAL;
		public var sliderDownFace:String = AssetIDs.VOLUME_BAR_SLIDER_DOWN;
		public var sliderOverFace:String = AssetIDs.VOLUME_BAR_SLIDER_OVER;
		
		public var upMuteFace:String = AssetIDs.UNMUTE_BUTTON_NORMAL;
		public var downMuteFace:String = AssetIDs.UNMUTE_BUTTON_DOWN;
		public var overMuteFace:String = AssetIDs.UNMUTE_BUTTON_OVER;
		
		public var steppedButtonFaces:Array
			=	[ 	{ up: AssetIDs.VOLUME_BUTTON_LOW_NORMAL
					, down: AssetIDs.VOLUME_BUTTON_LOW_DOWN
					, over: AssetIDs.VOLUME_BUTTON_LOW_OVER
					}
				,	{ up: AssetIDs.VOLUME_BUTTON_MED_NORMAL
					, down: AssetIDs.VOLUME_BUTTON_MED_DOWN
					, over: AssetIDs.VOLUME_BUTTON_MED_OVER
					}
				,	{ up: AssetIDs.VOLUME_BUTTON_HIGH_NORMAL
					, down: AssetIDs.VOLUME_BUTTON_HIGH_DOWN
					, over: AssetIDs.VOLUME_BUTTON_HIGH_OVER
					}
				];
		
		public var volumeSteps:uint = 0;

		public function MuteButton(includeVolume:Boolean=true)
		{
			super();
			
			_includeVolume = includeVolume;
			
			upFace = AssetIDs.VOLUME_BUTTON_NORMAL;
			downFace = AssetIDs.VOLUME_BUTTON_DOWN;
			overFace = AssetIDs.VOLUME_BUTTON_OVER;
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}		
		
		// Overrides
		//

		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);
			
			if(!_includeVolume) return;
			
			volumeWidget = new VolumeWidget();
						
			volumeWidget.configure(xml, assetManager);
			volumeWidget.layoutMetadata.layoutMode = LayoutMode.VERTICAL;
			volumeWidget.layoutMetadata.width = layoutMetadata.width;
		}
		
		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean=true):void
		{
			WidgetHint.getInstance(this).hide();
			measure();
			super.layout(Math.max(measuredWidth, availableWidth), Math.max(measuredHeight, availableHeight));
		}
		
		
		override public function set media(value:MediaElement):void
		{
			if (value != null)
			{
				super.media = value;
				
				if (volumeWidget)
				{					
					// Forward the media element to the volume Widget
					volumeWidget.media = media;
				}				
			}
		}
		
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void
		{
			visible = true;
			audible = element.getTrait(MediaTraitType.AUDIO) as AudioTrait;
			if (audible)
			{
				audible.addEventListener(AudioEvent.MUTED_CHANGE, onMutedChange);
				audible.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
			}
			onMutedChange();
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{
			WidgetHint.getInstance(this).hide();
			visible = false;
			if (audible)
			{
				audible.removeEventListener(AudioEvent.MUTED_CHANGE, onMutedChange);
				audible = null;
			}
		}
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			// Mute only when clicking on the button itself, not on the volume slider
			if (event.localY >= 0 && (event.localY <= height || isNaN(height)))
			{
				if(audible) audible.muted = !audible.muted;
			}
			else
			{
				if(volumeWidget) volumeWidget.dispatchEvent(event);
			}
		}
		
		override protected function onMouseOut(event:MouseEvent):void
		{
			if(volumeWidget && !volumeWidget.slider.sliding)
			{
				// Hide the volume widget only if we finished dragging
				WidgetHint.getInstance(this).hide();
				super.onMouseOut(event);
			}
		}

		override protected function setFace(face:DisplayObject):void
		{
			if (face)
			{
				super.setFace(face);
			}
		}

		override protected function onMouseOver(event:MouseEvent):void
		{
			WidgetHint.getInstance(this).horizontalAlign = HorizontalAlign.CENTER;
			if(volumeWidget) WidgetHint.getInstance(this).widget = volumeWidget;
			
			if (volumeWidget && volumeWidget.slider.sliding)
			{
				setFace(down);
			}
			else
			{
				super.onMouseOver(event);
			}
		}


		// Internals
		//
		
		protected var audible:AudioTrait;
		protected var widgetHint:WidgetHint;
		protected var _volumeWidget:VolumeWidget;
		public function get volumeWidget():VolumeWidget{ return _volumeWidget; }
		public function set volumeWidget(value:VolumeWidget):void{ _volumeWidget = value; }

		protected function onMutedChange(event:AudioEvent = null):void
		{
			if (audible.muted)
			{
				currentFaceIndex = -1;
				up = assetManager.getDisplayObject(upMuteFace);
				down = assetManager.getDisplayObject(downMuteFace);
				over = assetManager.getDisplayObject(overMuteFace);
				if(volumeWidget) setFace(volumeWidget.slider.sliding ? down : (event ? over : up));
			}
			else
			{
				onVolumeChange();
			}
		}
		
		protected function onVolumeChange(event:AudioEvent = null):void
		{
			if(volumeSteps > 0)
			{
				var faceIndex:uint = Math.min(volumeSteps, Math.ceil(audible.volume / volumeSteps*10))
				if 	(	faceIndex - 1 != currentFaceIndex
					&&	faceIndex > 0
					&&	faceIndex <= steppedButtonFaces.length
					)
				{
					currentFaceIndex = faceIndex - 1;
					
					up = assetManager.getDisplayObject(steppedButtonFaces[currentFaceIndex].up);
					down = assetManager.getDisplayObject(steppedButtonFaces[currentFaceIndex].down);
					over = assetManager.getDisplayObject(steppedButtonFaces[currentFaceIndex].over);
					
					if(volumeWidget) setFace(volumeWidget.slider.sliding ? down : (event ? over : up));
				}
			}
		}
				
		protected function onMouseMove(event:MouseEvent):void
		{
			if (WidgetHint.getInstance(this).widget)
			{
				WidgetHint.getInstance(this).updatePosition();
			}
			else
			{
				WidgetHint.getInstance(this).horizontalAlign = HorizontalAlign.CENTER;
				if(volumeWidget) WidgetHint.getInstance(this).widget = volumeWidget;
			}
			
			if (event.localY < 0)
			{
				// Forward event to volume widget
				if(volumeWidget) volumeWidget.dispatchEvent(event.clone());  
			}
			else
			{
				if(volumeWidget) volumeWidget.slider.stop();
			}
		}
		
		override protected function onMouseDown(event:MouseEvent):void
		{
			if (event.localY < 0)
			{
				// Forward event to volume widget
				if(volumeWidget) volumeWidget.dispatchEvent(event);
			}
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			// update face
			setFace(over);
		}
		
		 		
		private var currentFaceIndex:int;
		
		protected var _includeVolume:Boolean = true;
		
		/* static */
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.AUDIO;
	}
}
