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
	
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	/**
	 * Defines the play trait for a playlist element. Serves to keep state when the active
	 * media element of a playlist changes from one to the next.
	 */	
	internal class PlaylistPlayTrait extends PlayTrait
	{
		public function PlaylistPlayTrait()
		{
			super();
		}
		
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
				
				updatePlayTrait();
			}
		}
		
		public function get enabled():Boolean
		{
			return _playTrait != null;
		}
		
		override protected function playStateChangeStart(newPlayState:String):void
		{
			super.playStateChangeStart(newPlayState);
			if (_playTrait && _playTrait.playState != newPlayState)
			{
				switch (newPlayState)
				{
					case PlayState.PAUSED:
						_playTrait.pause();
						break;
					case PlayState.PLAYING:
						_playTrait.play();
						break;
					case PlayState.STOPPED:
						_playTrait.stop();
						break;
				}
			}
		}
		
		// Internals
		//
		
		private var _mediaElement:MediaElement;
		private var _playTrait:PlayTrait;
		
		private function set playTrait(value:PlayTrait):void
		{
			if (value != _playTrait)
			{
				var oldTrait:PlayTrait = _playTrait;
				_playTrait = value;
				
				if (!(_playTrait && oldTrait))
				{
					dispatchEvent(new PlaylistTraitEvent(PlaylistTraitEvent.ENABLED_CHANGE));
				}
			}
		}
		
		private function onMediaElementTraitsChange(event:MediaElementEvent):void
		{
			updatePlayTrait
				(	event.type == MediaElementEvent.TRAIT_REMOVE
				&&	event.traitType == MediaTraitType.PLAY
				);
		}
		
		private function updatePlayTrait(pendingRemoval:Boolean = false):void
		{
			var newPlayTrait:PlayTrait
				= _mediaElement
					? pendingRemoval
						? null
						: _mediaElement.getTrait(MediaTraitType.PLAY) as PlayTrait
					: null;
			
			if (_playTrait != newPlayTrait)
			{
				if (_playTrait)
				{
					_playTrait.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, onCanPauseChange);
				}
				
				if (newPlayTrait)
				{
					newPlayTrait.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, onCanPauseChange);
				}
				
				playTrait = newPlayTrait;
				
				if (newPlayTrait && playState != newPlayTrait.playState)
				{
					switch (playState)
					{
						case PlayState.PAUSED:
							newPlayTrait.pause();
							break;
						case PlayState.PLAYING:
							newPlayTrait.play();
							break;
						case PlayState.STOPPED:
							newPlayTrait.stop();
							break;
					}
				}
				
				if (newPlayTrait == null)
				{
					setCanPause(false);
				}
			}
		}
		
		private function onCanPauseChange(event:PlayEvent):void
		{
			setCanPause(event.canPause);
		}
	}
}