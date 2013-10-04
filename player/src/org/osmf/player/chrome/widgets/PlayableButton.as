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
	import flash.events.Event;
	
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;
	
	public class PlayableButton extends ButtonWidget
	{
		// Protected
		//
		
		protected function get playable():PlayTrait
		{
			return _playable;
		}
		
		// Overrides
		//
		
		override protected function get requiredTraits():Vector.<String>
		{
			return _requiredTraits;
		}
		
		override protected function processMediaElementChange(oldMediaElement:MediaElement):void
		{
			setPlayable(media ? media.getTrait(MediaTraitType.PLAY) as PlayTrait : null);
		}
		
		override protected function onMediaElementTraitAdd(event:MediaElementEvent):void
		{
			if (event.traitType == MediaTraitType.PLAY)
			{
				setPlayable(media.getTrait(MediaTraitType.PLAY) as PlayTrait);
			}	
			
			super.onMediaElementTraitAdd(event);
		}
		
		override protected function onMediaElementTraitRemove(event:MediaElementEvent):void
		{
			if ((event.traitType == MediaTraitType.PLAY) && _playable)
			{
				setPlayable(null);
			}
			
			super.onMediaElementTraitRemove(event);
		}
		
		override protected function processRequiredTraitsAvailable(element:MediaElement):void
		{
			setPlayable(media.getTrait(MediaTraitType.PLAY) as PlayTrait);
		}
		
		override protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{
			setPlayable(null);
		}
		
		// Stubs
		//
		
		protected function visibilityDeterminingEventHandler(event:Event = null):void
		{	
		}
		
		// Internals
		//
		
		private var _playable:PlayTrait;
		
		/* static */
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.PLAY;
		
		private function setPlayable(value:PlayTrait):void
		{
			if (value != _playable)
			{
				if (_playable != null)
				{
					_playable.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
					_playable.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
					_playable = null;
				}
				
				_playable = value;
				
				if (_playable)
				{
					_playable.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
					_playable.addEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
				}
			}
			visibilityDeterminingEventHandler();
		}
	}
}