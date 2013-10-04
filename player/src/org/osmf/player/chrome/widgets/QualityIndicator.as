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
	import __AS3__.vec.Vector;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.metadata.MediaMetadata;
	import org.osmf.player.metadata.ResourceMetadata;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.traits.MediaTraitType;
	
	
	public class QualityIndicator extends Widget
	{
		// Public Interface
		//
		
		public var hdOnFace:String = AssetIDs.HD_ON;
		public var hdOffFace:String = AssetIDs.HD_OFF;
		
		// Overrides
		//
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			hdOn = assetManager.getDisplayObject(hdOnFace);
			hdOff = assetManager.getDisplayObject(hdOffFace);
			
			face = hdOffFace;
			
			super.configure(xml, assetManager);
		}
		
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
		
		override protected function processMediaElementChange(oldElement:MediaElement):void
		{
			visibilityDeterminingEventHandler();
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void
		{
			dynamicStream = element.getTrait(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait;
			dynamicStream.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, visibilityDeterminingEventHandler);
			dynamicStream.addEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, visibilityDeterminingEventHandler);
			
			displayObjectTrait = element.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
			displayObjectTrait.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
			
			visibilityDeterminingEventHandler();
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{
			if (dynamicStream)
			{
				dynamicStream.removeEventListener(DynamicStreamEvent.SWITCHING_CHANGE, visibilityDeterminingEventHandler);
				dynamicStream.removeEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, visibilityDeterminingEventHandler);
				dynamicStream = null;
			}
			if (displayObjectTrait)
			{
				displayObjectTrait.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
				displayObjectTrait = null;
			}
			visibilityDeterminingEventHandler();
		}
		
		// Internals
		//
		private function onMediaSizeChange(event:DisplayObjectEvent):void
		{
			if (visible)
			{
				var mediaMetadata:MediaMetadata = media.metadata.getValue(MediaMetadata.ID) as MediaMetadata;
				var face:DisplayObject = null;
				face = event.newHeight > mediaMetadata.mediaPlayer.highQualityThreshold					
					? hdOn
					: hdOff;
				
				if (numChildren > 0 && getChildAt(0) != face)
				{
					removeChildAt(0);
				}
				
				if (face && contains(face) == false)
				{
					addChildAt(face, 0);
				}
				
				width = face ? face.width + (layoutMetadata.paddingRight || 0) : 0;
				height = face ? face.height : 0;
				
				measure();
			}
		}
		
		private function visibilityDeterminingEventHandler(event:Event = null):void
		{
			visible = media != null && dynamicStream != null;
			if (visible)
			{
				var face:DisplayObject = null;
				
				// Try to use the height from the resource metadata. 
				// Note that OSMF doesn't propagate the w/h of dynamic streams in DynamicStreamTrait.
				var mediaMetadata:MediaMetadata = media.metadata.getValue(MediaMetadata.ID) as MediaMetadata;
				if (mediaMetadata)
				{
					var resourceMetadata:ResourceMetadata = mediaMetadata.resourceMetadata;
					var h:int = 0;
					
					if (resourceMetadata.streamItems)
					{
						h = resourceMetadata.streamItems[dynamicStream.currentIndex].height;
					}
					
					if (h > 0)
					{
						face = h > mediaMetadata.mediaPlayer.highQualityThreshold					
							? hdOn
							: hdOff;
					}
				}
				
				// Use the middle as a fallback implementation if the dynamic streams metadata is not available.
				if (face == null)
				{
					face = (dynamicStream.currentIndex + 1) > (dynamicStream.numDynamicStreams/2)
							? hdOn
							: hdOff;
				}
				
				if (numChildren > 0 && getChildAt(0) != face)
				{
					removeChildAt(0);
				}
				
				if (face && contains(face) == false)
				{
					addChildAt(face, 0);
				}
					
				width = face ? face.width + (layoutMetadata.paddingRight || 0) : 0;
				height = face ? face.height : 0;
				
				measure();
			}
		}
		
		private var dynamicStream:DynamicStreamTrait;
		private var displayObjectTrait:DisplayObjectTrait;
		private var hdOn:DisplayObject;
		private var hdOff:DisplayObject;
		
		/* static */
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.DYNAMIC_STREAM;
		_requiredTraits[1] = MediaTraitType.DISPLAY_OBJECT;
	}
}