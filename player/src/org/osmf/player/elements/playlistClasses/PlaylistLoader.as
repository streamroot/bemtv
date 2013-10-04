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
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.osmf.elements.DurationElement;
	import org.osmf.elements.proxyClasses.LoadFromDocumentLoadTrait;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.MediaTypeUtil;
	import org.osmf.media.URLResource;
	import org.osmf.net.StreamType;
	import org.osmf.player.chrome.AssetsProvider;
	import org.osmf.player.elements.ErrorElement;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.URL;

	/**
	 * Defines the loader class that reads a playlist, feeds it to a parser, and instantiates
	 * a resulting InnerPlaylistElement.
	 */	
	public class PlaylistLoader extends LoaderBase
	{
		// Public interface
		//
		
		public function PlaylistLoader
			( factory:MediaFactory = null
			, resourceConstructorFunction:Function = null
			, errorElementConstructorFunction:Function = null
			)
		{
			super();
			
			supportedMimeTypes.push(PLAIN_TEXT_MIME_TYPE);
			
			this.parser = new PlaylistParser(resourceConstructorFunction);
			this.factory = factory || new DefaultMediaFactory();
			this.errorElementConstructorFunction = errorElementConstructorFunction;
		}
		
		public function get playlistElement():InnerPlaylistElement
		{
			return _playlistElement;
		}
		
		public function get playlistMetadata():PlaylistMetadata
		{
			return _playlistMetadata;
		}
		
		// Overrides
		//
		
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			var supported:int
				= MediaTypeUtil
				. checkMetadataMatchWithResource
					( resource
					, new Vector.<String>()
					, supportedMimeTypes
					);
			
			if (supported == MediaTypeUtil.METADATA_MATCH_FOUND)
			{
				return true;
			}
			else if (resource is URLResource)
			{
				var urlResource:URLResource = URLResource(resource);
				var extension:String = new URL(urlResource.url).extension;
				extension = extension ? extension.toLocaleLowerCase() : null;
				return extension == M3U_EXTENSION;
			}		
			else
			{
				return false;
			}
		}
		
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			updateLoadTrait(loadTrait, LoadState.LOADING);
			
			var playlistLoader:URLLoader = new URLLoader(new URLRequest(URLResource(loadTrait.resource).url));
			playlistLoader.addEventListener(Event.COMPLETE, onComplete);
			playlistLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			playlistLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			
			function onError(event:ErrorEvent):void
			{				
				playlistLoader.removeEventListener(Event.COMPLETE, onComplete);
				playlistLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				playlistLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);		
				
				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR); 				
				loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(0, event.text)));
			}
			
			function onComplete(event:Event):void
			{	
				playlistLoader.removeEventListener(Event.COMPLETE, onComplete);
				playlistLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				playlistLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);		
				
				processPlaylistContent(event.target.data, loadTrait);
			}			
		}
		
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);					
		}
		
		// Internals
		//
		
		/* static */
		private static const PLAIN_TEXT_MIME_TYPE:String = "text/plain";
		private static const M3U_EXTENSION:String = "m3u";
		
		private var parser:PlaylistParser;
		private var factory:MediaFactory;
		private var errorElementConstructorFunction:Function;
		private var supportedMimeTypes:Vector.<String> = new Vector.<String>();
		
		private var _playlistMetadata:PlaylistMetadata;
		private var _playlistElement:InnerPlaylistElement;
		
		internal function processPlaylistContent(contents:String, loadTrait:LoadTrait):void
		{
			var playlist:Vector.<MediaResourceBase>;
			
			try
			{					
				playlist = parser.parse(contents);
			}
			catch (parseError:Error)
			{					
				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
				loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(parseError.errorID, parseError.message)));
			}
			
			if (playlist != null && playlist.length > 0)
			{
				try
				{
					var mediaElements:Vector.<MediaElement> = new Vector.<MediaElement>();
					_playlistMetadata = new PlaylistMetadata();
					
					var firstMediaElement:MediaElement;
					for each (var resource:MediaResourceBase in playlist)
					{
						var mediaElement:MediaElement =	factory.createMediaElement(resource);
						if (mediaElement == null)
						{
							var urlResource:URLResource = resource as URLResource;
							mediaElement
								= new DurationElement
									( 5
									, new ErrorElement
										( "Playlist element failed playback:\n"
										+ "Incompatible resource"
										+ (urlResource ? " : '" + urlResource.url + "'" : ".")
										)
									);
						}
						
						firstMediaElement ||= mediaElement;
						
						mediaElements.push(mediaElement);
						_playlistMetadata.addElement(mediaElement);
					}
					
					_playlistMetadata.currentElement = firstMediaElement;
					_playlistElement = new InnerPlaylistElement(_playlistMetadata, errorElementConstructorFunction);
					
					LoadFromDocumentLoadTrait(loadTrait).mediaElement = _playlistElement;
					
					dispatchEvent(new Event(Event.COMPLETE));
					
					updateLoadTrait(loadTrait, LoadState.READY);
				}
				catch (error:Error)
				{					
					updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
					loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(error.errorID, error.message)));
				}	
			}
			else
			{
				// TODO: handle failure.
			}		
		}
	}
}