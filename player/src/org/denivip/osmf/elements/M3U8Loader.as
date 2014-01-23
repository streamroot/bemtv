package org.denivip.osmf.elements
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	import org.denivip.osmf.elements.m3u8Classes.M3U8PlaylistParser;
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
		private var _parser:M3U8PlaylistParser = null;
		private var _loadTime:int = 0;
		private var _playlistLoader:URLLoader = null;
        private var _errorHit:Boolean = false;  // So we only handle HTTP errors once; handling stuff twice dorks things.
		
		public function M3U8Loader(){
			super();
		}

        public static function canHandle(resource:MediaResourceBase):Boolean
        {
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
		
		override public function canHandleResource(resource:MediaResourceBase):Boolean{
            return canHandle(resource);
		}
		
		private function onError(e:ErrorEvent):void
		{
            if( !_errorHit) {
                _errorHit = true;
                updateLoadTrait(_loadTrait, LoadState.LOAD_ERROR);
                _loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(0, 'This video is not available.')));
            }
		}
		
		private function onComplete(e:Event):void
		{
			removeListeners();
			
			try
            {
				CONFIG::LOGGING
				{
					_loadTime = getTimer() - _loadTime;
					var url:String = _loadTrait.resource['url'];
					logger.info("Playlist {0} loaded", url);
					logger.info("size = {0}Kb", (_playlistLoader.bytesLoaded/1024).toFixed(3));
					logger.info("load time = {0} sec", (_loadTime/1000));
				}
				
				var resData:String = String((e.target as URLLoader).data);
				
				_parser = new M3U8PlaylistParser();
				
				_parser.addEventListener(ParseEvent.PARSE_COMPLETE, parseComplete);
				_parser.addEventListener(ParseEvent.PARSE_ERROR, parseError);
				
				_parser.parse(resData, URLResource(_loadTrait.resource));
			}catch(err:Error){
				updateLoadTrait(_loadTrait, LoadState.LOAD_ERROR);
				dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(err.errorID, err.message)));
			}
		}
		
		private function onHTTPStatus(event:flash.events.HTTPStatusEvent):void 
		{
			if( event.status >= 400 && !_errorHit )
			{
				// some 400-level fail, let's forward this out to jscript land
				_errorHit = true;
				updateLoadTrait(_loadTrait, LoadState.LOAD_ERROR);
				_loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(event.status, "")));
			}
		}
		
		private function removeListeners():void
		{
			_playlistLoader.removeEventListener(Event.COMPLETE, onComplete);
			_playlistLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_playlistLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			_playlistLoader.removeEventListener(flash.events.HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
		}
		
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			if( _playlistLoader != null )
			{
				// There's some previous request that is lingering in abject misery--kill it dead.  This is
				// important because otherwise you can have strange race conditions happen when multiple 
				// executeLoad calls are fired in rapid succession.
				// Remove all listeners, close it (which under the hood cancels everything), set to null.
				this.removeListeners();
				_playlistLoader.close();
				_playlistLoader = null;
			}

            // Reset our error hit logic since we're trying again.
            _errorHit = false;
			
			if( _parser != null )
			{
				// If there's an outstanding parser, also kill that dead.
				removeParserListeners();
				_parser = null;
			}
			
			_loadTrait = loadTrait;
			updateLoadTrait(loadTrait, LoadState.LOADING);
			
			_playlistLoader = new URLLoader();
			_playlistLoader.addEventListener(Event.COMPLETE, onComplete);
			_playlistLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_playlistLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			_playlistLoader.addEventListener(flash.events.HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
            _playlistLoader.load(new URLRequest(URLResource(loadTrait.resource).url));
			
			CONFIG::LOGGING
            {
                _loadTime = getTimer();
            }
		}
		
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
		}
		
		private function removeParserListeners():void
		{
			_parser.removeEventListener(ParseEvent.PARSE_COMPLETE, parseComplete);
			_parser.removeEventListener(ParseEvent.PARSE_ERROR, parseError);
		}
		
		private function parseComplete(event:ParseEvent):void
		{
			removeParserListeners();
			finishPlaylistLoading(MediaResourceBase(event.data));
		}
		
		private function parseError(event:ParseEvent):void{
			removeParserListeners();
		}
		
		private function finishPlaylistLoading(resource:MediaResourceBase):void{
			try{
				var loadedElem:MediaElement = new VideoElement(null, new HTTPStreamingHLSNetLoader());
				loadedElem.resource = resource;
				VideoElement(loadedElem).smoothing = true;
				
				LoadFromDocumentLoadTrait(_loadTrait).mediaElement = loadedElem;
				
				updateLoadTrait(_loadTrait, LoadState.READY);
			}catch(e:Error){
				updateLoadTrait(_loadTrait, LoadState.LOAD_ERROR);
				_loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(e.errorID, e.message)));
			}
		}
		
		CONFIG::LOGGING
		{
			protected var logger:Logger = Log.getLogger("org.denivip.osmf.elements.M3U8Loader") as Logger;
		}
	}
}