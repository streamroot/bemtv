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
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	
	/**
	 * Defines the time trait for a playlist element. Serves to keep state when the active
	 * media element of a playlist changes from one to the next.
	 */	
	internal class PlaylistTimeTrait extends TimeTrait
	{
		public function PlaylistTimeTrait(duration:Number=NaN)
		{
			super(duration);
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
				
				updateTimeTrait();
			}
		}
		
		public function get enabled():Boolean
		{
			return _timeTrait != null;
		}
		
		public function signalCompletion():void
		{
			signalComplete();
		}
		
		// Overrides
		//
		
		override public function get currentTime():Number
		{
			return _timeTrait ? _timeTrait.currentTime : 0;
		}
		
		// Internals
		//
		
		private var _mediaElement:MediaElement;
		private var _timeTrait:TimeTrait;
		
		private function set timeTrait(value:TimeTrait):void
		{
			if (value != _timeTrait)
			{
				var oldTrait:TimeTrait = _timeTrait;
				_timeTrait = value;
				
				if (!(_timeTrait && oldTrait))
				{
					dispatchEvent(new PlaylistTraitEvent(PlaylistTraitEvent.ENABLED_CHANGE));
				}
			}
		}
		
		private function onMediaElementTraitsChange(event:MediaElementEvent):void
		{
			updateTimeTrait
				(	event.type == MediaElementEvent.TRAIT_REMOVE
				&&	event.traitType == MediaTraitType.TIME
				);
		}
		
		private function updateTimeTrait(pendingRemoval:Boolean = false):void
		{
			var newTimeTrait:TimeTrait
				 = _mediaElement
					 	? pendingRemoval
							? null
							: _mediaElement.getTrait(MediaTraitType.TIME) as TimeTrait
						: null;
				 
			if (_timeTrait != newTimeTrait)
			{
				if (_timeTrait)
				{
					_timeTrait.removeEventListener(TimeEvent.COMPLETE, onTimeTraitComplete);
					_timeTrait.removeEventListener(TimeEvent.DURATION_CHANGE, onTimeTraitDurationChange);
				}
				
				timeTrait = newTimeTrait;
				
				if (_timeTrait)
				{
					_timeTrait.addEventListener(TimeEvent.COMPLETE, onTimeTraitComplete);
					_timeTrait.addEventListener(TimeEvent.DURATION_CHANGE, onTimeTraitDurationChange);
					
					setDuration(_timeTrait.duration);
				}
				else
				{
					setDuration(NaN);
				}
			}
		}
		
		private function onTimeTraitComplete(event:TimeEvent):void
		{
			dispatchEvent(new PlaylistTraitEvent(PlaylistTraitEvent.ACTIVE_ITEM_COMPLETE));
		}
		
		private function onTimeTraitDurationChange(event:TimeEvent):void
		{
			setDuration(event.time);
		}
	}
}