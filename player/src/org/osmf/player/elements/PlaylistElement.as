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

package org.osmf.player.elements
{
	import flash.events.Event;
	
	import org.osmf.elements.LoadFromDocumentElement;
	import org.osmf.events.MetadataEvent;
	import org.osmf.media.MediaFactory;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.StreamType;
	import org.osmf.player.elements.playlistClasses.PlaylistLoader;
	import org.osmf.player.elements.playlistClasses.PlaylistMetadata;
	import org.osmf.player.elements.playlistClasses.ProxyMetadataEx;
	
	/**
	 * Defines a media element that reads a playlist (so far the only supported
	 * format is m3u) and represents the media in the playlist sequentially.
	 * 
	 * The class monitors its metadata for "gotoNext" and "gotoPrevious" values
	 * being set to true on its PlaylistMetadata object.
	 * 
	 * Since this class is LoadFromDocumentElement derived, we need an inner
	 * element that acts as the proxied element. This object is of type
	 * InnerPlaylistElement. Refer to PlaylistLoader to see the inner object
	 * instantiated.
	 */	
	public class PlaylistElement extends LoadFromDocumentElement
	{
		/**
		 * Constructor.
		 * 
		 * @loader The loader that the playlist element should use. When null,
		 * a PlaylistLoader instance is used.
		 */		
		public function PlaylistElement(loader:PlaylistLoader = null)
		{
			this.loader = loader || new PlaylistLoader();
			loader.addEventListener(Event.COMPLETE, onLoaderComplete);
			
			super(null, loader);
		}
		
		/**
		 * Override that plugs in workaround class ProxyMetadataEx, that fixes OSMF
		 * bug 933.
		 */		
		override protected function createMetadata():Metadata
		{
			return new ProxyMetadataEx();
		}
		
		// Internals
		//
		
		private var loader:PlaylistLoader;
		private var playlistMetadata:PlaylistMetadata;
		
		private function onLoaderComplete(event:Event):void
		{
			// Watch for metadata value changes: a change to the value under keys
			// "gotoNext" or "gotoPrevious" will result in the next or previous
			// element being activated.
			playlistMetadata = loader.playlistMetadata;
			playlistMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataValueChange);
			
			metadata.addValue(PlaylistMetadata.NAMESPACE, playlistMetadata);
		}
		
		private function onMetadataValueChange(event:MetadataEvent):void
		{
			if (event.key == PlaylistMetadata.GOTO_NEXT && event.value == true)
			{
				// Lower the flag:
				playlistMetadata.addValue(PlaylistMetadata.GOTO_NEXT, false);
				loader.playlistElement.activateNextElement();
			}
			else if (event.key == PlaylistMetadata.GOTO_PREVIOUS && event.value == true)
			{
				// Lower the flag:
				playlistMetadata.addValue(PlaylistMetadata.GOTO_PREVIOUS, false);
				loader.playlistElement.activatePreviousElement();
			}
		}
		
	}
}