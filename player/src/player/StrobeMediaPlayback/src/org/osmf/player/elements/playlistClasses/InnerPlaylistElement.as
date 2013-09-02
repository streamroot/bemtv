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
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.player.elements.ErrorElement;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	
	/**
	 * Defines a media element that manages a list of child media elements that
	 * play back one at a time. Contrary to a serial element, each child's traits
	 * are reflected in isolation.
	 * 
	 * Class is used by the outward facing PlaylistElement, that proxies this
	 * element (for that is how the LoadFromDocumentElement works).
	 */	
	public class InnerPlaylistElement extends ProxyElementEx
	{
		/**
		 * Constructor.
		 * 
		 * @param elements the playlist consists of.
		 * @param playlistMetadata as present on the outer playlist element.
		 * 
		 */		
		public function InnerPlaylistElement(playlistMetadata:PlaylistMetadata, errorElementConstructorFunction:Function)
		{
			this.playlistMetadata = playlistMetadata;
			this.errorElementConstructorFunction = errorElementConstructorFunction;
			
			super(null);
			
			if (playlistMetadata == null)
			{
				throw new ArgumentError();
			}
			
			// The load and play-trait are fixed traits that stay on the element, always.
			// The reason for the play trait to be static, is that adding and removing the
			// trait results in media player applying the auto-play setting whenever the
			// trait reappears:
			
			loadTrait = new PlaylistLoadTrait(null, null);
			addTrait(loadTrait.traitType, loadTrait);
			
			playTrait = new PlaylistPlayTrait();
			addTrait(playTrait.traitType, playTrait);
			
			// The time and audio trait are dynamic: they appear on the element whenever the
			// active child element exposes the traits:
			
			timeTrait = new PlaylistTimeTrait();
			timeTrait.addEventListener(PlaylistTraitEvent.ENABLED_CHANGE, onTimeTraitEnabledChange);
			timeTrait.addEventListener(PlaylistTraitEvent.ACTIVE_ITEM_COMPLETE, onTimeTraitActiveItemComplete);
			
			audioTrait = new PlaylistAudioTrait();
			audioTrait.addEventListener(PlaylistTraitEvent.ENABLED_CHANGE, onAudioTraitEnabledChange);
			
			// Set the active child:
			activeMediaElement = playlistMetadata.currentElement;
		}
		
		/**
		 * Defines the currently active element in the list.
		 */		
		public function set activeMediaElement(value:MediaElement):void
		{
			if (value != _activeMediaElement)
			{
				var oldElement:MediaElement = _activeMediaElement;
				
				loadTrait.mediaElement = value;
				timeTrait.mediaElement = value;
				playTrait.mediaElement = value;
//				playTrait.pause();
//				playTrait.play();
				audioTrait.mediaElement = value;
				_activeMediaElement = value;
				playlistMetadata.currentElement = value;
				proxiedElement = value;
				
				if (value != null)
				{
					// Listen to errors coming from the active element. Use the highest
					// priority possible, so we can catch the error, deal with it, and
					// cancel further propagation:
					value.addEventListener
						( MediaErrorEvent.MEDIA_ERROR
						, onActiveChildMediaError
						, false, int.MAX_VALUE
						);
				}
				
				if (oldElement != null)
				{
					// Remove the error listener:
					oldElement.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onActiveChildMediaError);
					
					// Make sure that the item that was previously playing
					// rewinds:
					var oldPlayTrait:PlayTrait
						= oldElement.getTrait(MediaTraitType.PLAY)
						as PlayTrait;
					
					var oldSeekTrait:SeekTrait
						= oldElement.getTrait(MediaTraitType.SEEK)
						as SeekTrait;
					playlistMetadata.switching = true;
					if (oldSeekTrait && oldSeekTrait.canSeekTo(0))
					{
						oldSeekTrait.addEventListener
							( SeekEvent.SEEKING_CHANGE
							, function (event:SeekEvent):void
								{
									if (event.seeking == false)
									{
										stopOldElement();
										oldSeekTrait.removeEventListener(SeekEvent.SEEKING_CHANGE, arguments.callee);
									}
								}
							);
						oldSeekTrait.seek(0);
					}
					else
					{
						stopOldElement();
					}
					
					function stopOldElement():void
					{				
						// WORKARROUND: a workarround against a bug which prevented blocked
						// the playback after swtiching very fast forward and back. 
						// See details here on the bug ST-134 - The player doesn't start playing 
						// the next movie when going back and forward in the playlist
						var workarroundTimer:Timer = new Timer(500, 1);
						workarroundTimer.addEventListener(TimerEvent.TIMER, 
							function(event:Event):void
							{
								if (oldPlayTrait && oldPlayTrait.playState == PlayState.PLAYING)
								{										
									oldPlayTrait.stop();									
								}
								playlistMetadata.switching = false;
							}
						);
						workarroundTimer.start();
					}
				}
			}
		}
		
		public function get activeMediaElement():MediaElement
		{
			return _activeMediaElement;
		}
		
		/**
		 * Utility function that activates the next media element in line, if
		 * there is a next media element.
		 */		
		public function activateNextElement():MediaElement
		{		
			var nextElement:MediaElement = playlistMetadata.nextElement;
			if (nextElement)
			{
				activeMediaElement = nextElement;
			}
			return nextElement;
		}
		
		/**
		 * Utility function that activates the previous media element in line, if
		 * there is a next previous element.
		 */	
		public function activatePreviousElement():MediaElement
		{
			var previousElement:MediaElement = playlistMetadata.previousElement;
			if (previousElement)
			{ 
				activeMediaElement = previousElement;
			}
			return previousElement;
		}
		
		// Internals
		//
		
		private var playlistMetadata:PlaylistMetadata;
		private var errorElementConstructorFunction:Function;
		
		private var _activeMediaElement:MediaElement;
		
		private var loadTrait:PlaylistLoadTrait;
		private var playTrait:PlaylistPlayTrait;
		private var timeTrait:PlaylistTimeTrait;
		private var audioTrait:PlaylistAudioTrait;
		private var switchOver:Boolean = true;
		
		private function blockTrait(traitType:String, block:Boolean = true):void
		{
			var blockedTraits:Vector.<String> = this.blockedTraits.concat();
			var index:Number = blockedTraits.indexOf(traitType);
			
			if (index == -1 && block == true)
			{
				blockedTraits.push(traitType);
				this.blockedTraits = blockedTraits;
			}
			else if (index > -1 && block == false)
			{
				blockedTraits.splice(index,1);
				this.blockedTraits = blockedTraits;
			}
		}
		
		private function unblockTrait(traitType:String):void
		{
			blockTrait(traitType, false);
		}
		
		private function onPlayTraitEnabledChange(event:Event):void
		{
			if (playTrait.enabled)
			{
				addTrait(playTrait.traitType, playTrait);
				unblockTrait(playTrait.traitType);
			}
			else
			{
				blockTrait(playTrait.traitType);
				removeTrait(playTrait.traitType);
			}
		}
		
		private function onTimeTraitEnabledChange(event:Event):void
		{
			if (timeTrait.enabled)
			{
				addTrait(timeTrait.traitType, timeTrait);
				unblockTrait(timeTrait.traitType);
			}
			else
			{
				blockTrait(timeTrait.traitType);
				removeTrait(timeTrait.traitType);
			}
		}
		
		private function onTimeTraitActiveItemComplete(event:Event):void
		{
			// Continue with the next element:
			if (activateNextElement() == null)
			{
				// There's no next element: make sure we set the first element active:
				if (playlistMetadata.indexOf(_activeMediaElement) != 0)
				{
					activeMediaElement = playlistMetadata.elementAt(0);
				}
				
				// This is the last element: stop, and signal completion:	
				playTrait.stop();
				timeTrait.signalCompletion();
			}
		}
		
		private function onAudioTraitEnabledChange(event:PlaylistTraitEvent):void
		{
			if (audioTrait.enabled)
			{
				addTrait(audioTrait.traitType, audioTrait);
				unblockTrait(audioTrait.traitType);
			}
			else
			{
				blockTrait(audioTrait.traitType);
				removeTrait(audioTrait.traitType);
			}
		}
		
		private function onActiveChildMediaError(event:MediaErrorEvent):void
		{
			// If we support replacing the failed element by another element,
			// than go ahead and do so. We swallow the error:
			if (errorElementConstructorFunction != null)
			{
				// Prevent the error from being propagated:
				event.stopImmediatePropagation();
				
				// Construct an error element:
				var errorElement:MediaElement = errorElementConstructorFunction(event.error);
				
				// Replace the failed media element with the error element:
				var activeMediaElementIndex:Number = playlistMetadata.indexOf(_activeMediaElement);
				playlistMetadata.updateElementAt(activeMediaElementIndex, errorElement);
				activeMediaElement = errorElement;
			}
		}
	}
}