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

package org.osmf.player.elements.playlistClasses
{
	import flash.events.Event;
	
	import org.osmf.events.AudioEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * Defines the audio trait for a playlist element. Serves to keep state when the
	 * active media element of a playlist changes from one to the next.
	 */	
	internal class PlaylistAudioTrait extends AudioTrait
	{
		public function set mediaElement(value:MediaElement):void
		{
			if (value != _mediaElement)
			{
				if (_mediaElement)
				{
					_mediaElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementTraitsChange);
					_mediaElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaElementTraitsChange);
				}
				
				_mediaElement = value;
				
				if (_mediaElement)
				{
					_mediaElement.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementTraitsChange);
					_mediaElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaElementTraitsChange);
				}
				
				updateAudioTrait();
			}
		}
			
		public function get enabled():Boolean
		{
			return _audioTrait != null;
		}
		
		// Overrides
		//
		
		override protected function mutedChangeStart(newMutedValue:Boolean):void
		{
			if (_audioTrait && _audioTrait.muted != newMutedValue)
			{
				_audioTrait.muted = newMutedValue;
			}
		}
		
		override protected function panChangeEnd():void
		{
			if (_audioTrait && _audioTrait.pan != pan)
			{
				_audioTrait.pan = pan;
			}
			
			super.panChangeEnd();
		}
		
		override protected function volumeChangeEnd():void
		{
			if (_audioTrait && _audioTrait.volume != volume)
			{
				_audioTrait.volume = volume;
			}
			
			super.volumeChangeEnd();
		}
		
		// Internals
		//
		
		private var _mediaElement:MediaElement;
		private var _audioTrait:AudioTrait;
		
		private function set audioTrait(value:AudioTrait):void
		{
			if (value != _audioTrait)
			{
				var oldTrait:AudioTrait = _audioTrait;
				_audioTrait = value;
				
				if (!(_audioTrait && oldTrait))
				{
					dispatchEvent(new PlaylistTraitEvent(PlaylistTraitEvent.ENABLED_CHANGE));
				}
			}
		}
		
		private function onMediaElementTraitsChange(event:MediaElementEvent):void
		{
			updateAudioTrait
				(	event.type == MediaElementEvent.TRAIT_REMOVE
				&&	event.traitType == MediaTraitType.AUDIO
				);
		}
		
		private function updateAudioTrait(pendingRemoval:Boolean = false):void
		{
			var newAudioTrait:AudioTrait
				= _mediaElement
					? pendingRemoval
						? null
						: _mediaElement.getTrait(MediaTraitType.AUDIO) as AudioTrait
					: null;
			
			if (_audioTrait != newAudioTrait)
			{
				if (_audioTrait)
				{
					_audioTrait.removeEventListener(AudioEvent.MUTED_CHANGE, onAudioTraitMutedChange);
					_audioTrait.removeEventListener(AudioEvent.PAN_CHANGE, onAudioTraitPanChange);
					_audioTrait.removeEventListener(AudioEvent.VOLUME_CHANGE, onAudioTraitVolumeChange);
				}
				
				audioTrait = newAudioTrait;
				
				if (newAudioTrait)
				{
					newAudioTrait.muted = muted;
					newAudioTrait.pan = pan;
					newAudioTrait.volume = volume;
					
					newAudioTrait.addEventListener(AudioEvent.MUTED_CHANGE, onAudioTraitMutedChange);
					newAudioTrait.addEventListener(AudioEvent.PAN_CHANGE, onAudioTraitPanChange);
					newAudioTrait.addEventListener(AudioEvent.VOLUME_CHANGE, onAudioTraitVolumeChange);
				}
			}
		}
		
		private function onAudioTraitMutedChange(event:AudioEvent):void
		{
			if (muted != _audioTrait.muted)
			{
				muted = _audioTrait.muted;
			}
		}
		
		private function onAudioTraitPanChange(event:AudioEvent):void
		{
			if (pan != _audioTrait.pan)
			{
				pan = _audioTrait.pan;
			}
		}
		
		private function onAudioTraitVolumeChange(event:AudioEvent):void
		{
			if (volume != _audioTrait.volume)
			{
				volume = _audioTrait.volume;
			}
		}
	}
}