package org.denivip.osmf.elements
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	import org.denivip.osmf.elements.m3u8Classes.M3U8Playlist;
	import org.denivip.osmf.elements.m3u8Classes.M3U8PlaylistParser;
	import org.denivip.osmf.logging.HLSLogger;
	import org.denivip.osmf.net.httpstreaming.hls.HTTPStreamingHLSNetLoader;
	import org.osmf.elements.VideoElement;
	import org.osmf.elements.proxyClasses.LoadFromDocumentLoadTrait;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.ParseEvent;
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	
	/**
	 * Loader for .m3u8 playlist file.
	 * Works like a F4MLoader
	 */
	public class M3U8Loader extends LoaderBase
	{
		
		private var _loadTrait:LoadTrait;
		private var _parser:M3U8PlaylistParser;
		
		public function M3U8Loader(){
			super();
		}
		
		override public function canHandleResource(resource:MediaResourceBase):Boolean{
			if (resource !== null && resource is URLResource) {
				var urlResource:URLResource = URLResource(resource);
				if (urlResource.url.search(/(https?|file)\:\/\/.*?\.m3u8(\?.*)?/i) !== -1) {
					return true;
				}
				
				var contentType:Object = urlResource.getMetadataValue("content-type");
				if (contentType && contentType is String) {
					// If the filename doesn't include a .m3u8 extension, but
					// explicit content-type metadata is found on the
					// URLResource, we can handle it.  Must be either of:
					// - "application/x-mpegURL"
					// - "vnd.apple.mpegURL"
					if ((contentType as String).search(/(application\/x-mpegURL|vnd.apple.mpegURL)/i) !== -1) {
						return true;
					}
				}
			}
			return false;
		}
		
		override protected function executeLoad(loadTrait:LoadTrait):void{
			_loadTrait = loadTrait;
			
			updateLoadTrait(loadTrait, LoadState.LOADING);
			
			var playlistLoader:URLLoader = new URLLoader(new URLRequest(URLResource(loadTrait.resource).url));
			playlistLoader.addEventListener(Event.COMPLETE, onComplete);
			playlistLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			playlistLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			
			CONFIG::LOGGING
			{
				var loadTime:int = getTimer();
			}
			// inline functions =) (it's shi... but i don't like 100500 service functions into one class)
			function onError(e:ErrorEvent):void{
				playlistLoader.removeEventListener(Event.COMPLETE, onComplete);
				playlistLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				playlistLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
				
				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
				loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(0, e.text)));
			}
			
			function onComplete(e:Event):void{
				playlistLoader.removeEventListener(Event.COMPLETE, onComplete);
				playlistLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				playlistLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
				
				try{
					CONFIG::LOGGING
					{
						loadTime = getTimer() - loadTime;
						logger.info("Playlist {0} loaded", URLResource(loadTrait.resource).url);
						logger.info("size = {0}Kb", (playlistLoader.bytesLoaded/1024).toFixed(3));
						logger.info("load time = {0} sec", (loadTime/1000));
					}
					
					var resData:String = String((e.target as URLLoader).data);
					
					_parser = new M3U8PlaylistParser();
					
					_parser.addEventListener(ParseEvent.PARSE_COMPLETE, parseComplete);
					_parser.addEventListener(ParseEvent.PARSE_ERROR, parseError);
					
					_parser.parse(resData, URLResource(loadTrait.resource));
				}catch(err:Error){
					updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
					dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(err.errorID, err.message)));
				}
			}
		}
		
		override protected function executeUnload(loadTrait:LoadTrait):void{
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
		}
		
		private function parseComplete(event:ParseEvent):void{
			_parser.removeEventListener(ParseEvent.PARSE_COMPLETE, parseComplete);
			_parser.removeEventListener(ParseEvent.PARSE_ERROR, parseError);
			
			finishPlaylistLoading(MediaResourceBase(event.data));
		}
		
		private function parseError(event:ParseEvent):void{
			_parser.removeEventListener(ParseEvent.PARSE_COMPLETE, parseComplete);
			_parser.removeEventListener(ParseEvent.PARSE_ERROR, parseError);
		}
		
		private function finishPlaylistLoading(resource:MediaResourceBase):void{
			try{
				/*
				CONFIG::LOGGING
				{
					logger.info("Playlist ({0}) size:", playlist.url);
					logger.info("chanks num = {0}", playlist.streamItems.length);
					logger.info("duration = {0}", playlist.isLive ? 'live' : playlist.duration);
				}
				*/
				var loadedElem:MediaElement = new VideoElement(null, new HTTPStreamingHLSNetLoader());
				loadedElem.resource = resource;
				
				LoadFromDocumentLoadTrait(_loadTrait).mediaElement = loadedElem;
				
				updateLoadTrait(_loadTrait, LoadState.READY);
			}catch(e:Error){
				updateLoadTrait(_loadTrait, LoadState.LOAD_ERROR);
				_loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(e.errorID, e.message)));
			}
		}
		
		CONFIG::LOGGING
		{
			protected var logger:HLSLogger = Log.getLogger("org.denivip.osmf.elements.M3U8Loader") as HLSLogger;
		}
	}
}