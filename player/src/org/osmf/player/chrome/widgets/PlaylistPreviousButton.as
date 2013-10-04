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
	import flash.events.MouseEvent;
	
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.Metadata;
	
	public class PlaylistPreviousButton extends ButtonWidget
	{
		public function PlaylistPreviousButton()
		{
			super();

			upFace 			= AssetIDs.PREVIOUS_BUTTON_NORMAL;
			downFace 		= AssetIDs.PREVIOUS_BUTTON_DOWN;
			overFace 		= AssetIDs.PREVIOUS_BUTTON_OVER;
			disabledFace	= AssetIDs.PREVIOUS_BUTTON_DISABLED; 
			
			visible = false;
		}
		
		// Overrides
		//
		
		override protected function processMediaElementChange(oldMediaElement:MediaElement):void
		{
			if (oldMediaElement != null)
			{
				oldMediaElement.removeEventListener(MediaElementEvent.METADATA_ADD, onPlaylistMetadataChange);
				oldMediaElement.removeEventListener(MediaElementEvent.METADATA_REMOVE, onPlaylistMetadataChange);
			}
			if (media != null)
			{
				media.addEventListener(MediaElementEvent.METADATA_ADD, onPlaylistMetadataChange);
				media.addEventListener(MediaElementEvent.METADATA_REMOVE, onPlaylistMetadataChange);
			}
			onPlaylistMetadataChange();
		}
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			var playlistMetadata:Metadata
				= media
					? media.getMetadata(PLAYLIST_METADATA_NS)
					: null;
			
			if (playlistMetadata)
			{
				playlistMetadata.addValue(GOTO_PREVIOUS, true);
			}
		}
		
		// Internals
		//
		
		private function onPlaylistMetadataChange(event:MediaElementEvent = null):void
		{
			var playlistMetadata:Metadata
				= media
					? media.getMetadata(PLAYLIST_METADATA_NS)
					: null;
			
			visible = playlistMetadata != null;
			if (playlistMetadata)
			{
				playlistMetadata.addEventListener
					( MetadataEvent.VALUE_CHANGE
					, onPlaylistMetadataValueChange
					);
				
				enabled = playlistMetadata.getValue(PREVIOUS_ELEMENT) != null
					&& !playlistMetadata.getValue(SWITCHING);
			}
		}
		
		private function onPlaylistMetadataValueChange(event:MetadataEvent):void
		{
			var playlistMetadata:Metadata = event.target as Metadata;
			enabled = playlistMetadata.getValue(PREVIOUS_ELEMENT) != null 
				&& !playlistMetadata.getValue(SWITCHING);
		}
		
		/* static */
		private static const PLAYLIST_METADATA_NS:String = "http://www.osmf.org.player/1.0/playlist";
		private static const PREVIOUS_ELEMENT:String = "previousElement";
		private static const GOTO_PREVIOUS:String = "gotoPrevious"; 
		public static const SWITCHING:String = "switching";
	}
}