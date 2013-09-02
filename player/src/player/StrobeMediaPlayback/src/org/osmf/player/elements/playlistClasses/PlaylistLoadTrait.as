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
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * Defines the load trait for a playlist element. Serves to keep state when the active
	 * media element of a playlist changes from one to the next.
	 */	
	internal class PlaylistLoadTrait extends LoadTrait
	{
		public function PlaylistLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
		{
			super(loader, resource);
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
					
				updateLoadTrait();
			}
		}
		
		override public function load():void
		{
			if	(	loadState != LoadState.LOADING
				&&	loadState != LoadState.READY
				)
			{
				setLoadState(LoadState.LOADING);
				if (loadTrait)
				{
					loadTrait.load();
				}
			}
		}
		
		override public function get bytesLoaded():Number
		{
			return loadTrait ? loadTrait.bytesLoaded : NaN;
		}
		
		override public function get bytesTotal():Number
		{
			return loadTrait ? loadTrait.bytesTotal : NaN;
		}
		
		// Internals
		//
		
		private var _mediaElement:MediaElement;
		private var loadTrait:LoadTrait;
		
		private function onLoadStateChange(event:LoadEvent):void
		{
			// Forward the load-state, unless there was an error: in that case, the media element
			// will be showing an internal error element, hence loading is to be considered successful
			// to the outside world:
			setLoadState(event.loadState == LoadState.LOAD_ERROR ? LoadState.READY : event.loadState);
		}
		
		private function onBytesTotalChange(event:LoadEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		private function onBytesLoadedChange(event:LoadEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		private function onMediaElementTraitsChange(event:MediaElementEvent):void
		{
			updateLoadTrait
				(	event.type == MediaElementEvent.TRAIT_REMOVE
				&&	event.traitType == MediaTraitType.LOAD
				);
		}
		
		private function updateLoadTrait(pendingRemoval:Boolean = false):void
		{
			var newLoadTrait:LoadTrait
				= _mediaElement
					? pendingRemoval
						? null
						: _mediaElement.getTrait(MediaTraitType.LOAD) as LoadTrait
					: null;
			
			if (loadTrait != newLoadTrait)
			{
				if (loadTrait)
				{
					loadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
					loadTrait.removeEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);
					loadTrait.removeEventListener(LoadEvent.BYTES_LOADED_CHANGE, onBytesLoadedChange);
				}
				
				if (newLoadTrait)
				{
					newLoadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
					newLoadTrait.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);
					newLoadTrait.addEventListener(LoadEvent.BYTES_LOADED_CHANGE, onBytesLoadedChange);
				}
				
				var oldLoadTrait:LoadTrait = loadTrait;
				loadTrait = newLoadTrait;
				
				if (newLoadTrait)
				{
					if	(	loadState != LoadState.UNINITIALIZED
						&&	loadState != LoadState.UNLOADING
						&&	newLoadTrait.loadState != LoadState.LOADING
						&&	newLoadTrait.loadState != LoadState.READY
						)
					{
						newLoadTrait.load();
					}
					else
					{
						setLoadState(newLoadTrait.loadState);
					}
				}
			}
		}
	}
}