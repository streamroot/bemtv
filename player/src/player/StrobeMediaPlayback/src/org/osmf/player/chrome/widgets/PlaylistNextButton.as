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
	
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.Metadata;
	import org.osmf.player.chrome.assets.AssetIDs;

	public class PlaylistNextButton extends ButtonWidget
	{
		// Public Interface
		//
		
		public function PlaylistNextButton()
		{
			super();
			
			upFace 			= AssetIDs.NEXT_BUTTON_NORMAL;
			downFace 		= AssetIDs.NEXT_BUTTON_DOWN;
			overFace 		= AssetIDs.NEXT_BUTTON_OVER;
			disabledFace 	= AssetIDs.NEXT_BUTTON_DISABLED;
			
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
					? media.getMetadata("http://www.osmf.org.player/1.0/playlist")
					: null;
				
			if (playlistMetadata)
			{
				playlistMetadata.addValue("gotoNext", true);
			}
		}
		
		// Internals
		//
		
		
		
		private function onPlaylistMetadataChange(event:MediaElementEvent = null):void
		{
			var playlistMetadata:Metadata
				= media
					? media.getMetadata("http://www.osmf.org.player/1.0/playlist")
					: null;
				
				visible = playlistMetadata != null;
				if (playlistMetadata)
				{
					playlistMetadata.addEventListener
						( MetadataEvent.VALUE_CHANGE
						, onPlaylistMetadataValueChange
						);
					
					enabled = playlistMetadata.getValue("nextElement") != null;
				}
		}
		
		private function onPlaylistMetadataValueChange(event:MetadataEvent):void
		{
			var playlistMetadata:Metadata = event.target as Metadata;
			enabled = playlistMetadata.getValue("nextElement") != null 
				&& !playlistMetadata.getValue("switching");
		}
	}
}