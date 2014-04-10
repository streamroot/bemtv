package org.mangui.HLS.streaming {
    import org.mangui.HLS.*;
    import org.mangui.HLS.parsing.*;
    import org.mangui.HLS.utils.*;

    import flash.events.*;
    import flash.net.*;
    import flash.utils.*;

    /** Loader for hls manifests. **/
    public class ManifestLoader {
        /** Reference to the hls framework controller. **/
        private var _hls : HLS;
        /** levels vector. **/
        private var _levels : Vector.<Level>;
        /** Object that fetches the manifest. **/
        private var _urlloader : URLLoader;
        /** Link to the M3U8 file. **/
        private var _url : String;
        /** are all playlists filled ? **/
        private var _canStart : Boolean;
        /** Timeout ID for reloading live playlists. **/
        private var _timeoutID : Number;
        /** Streaming type (live, ondemand). **/
        private var _type : String;
        /** last reload manifest time **/
        private var _reload_playlists_timer : uint;
        /** current level **/
        private var _current_level : Number;
        /** reference to manifest being loaded **/
        private var _manifest_loading : Manifest;
        /** flush live URL cache **/
        private var _flushLiveURLCache : Boolean = false;

        /** Setup the loader. **/
        public function ManifestLoader(hls : HLS) {
            _hls = hls;
            _hls.addEventListener(HLSEvent.STATE, _stateHandler);
            _hls.addEventListener(HLSEvent.QUALITY_SWITCH, _levelSwitchHandler);
            _levels = new Vector.<Level>();
            _urlloader = new URLLoader();
            _urlloader.addEventListener(Event.COMPLETE, _loaderHandler);
            _urlloader.addEventListener(IOErrorEvent.IO_ERROR, _errorHandler);
            _urlloader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _errorHandler);
        };

        /** Loading failed; return errors. **/
        private function _errorHandler(event : ErrorEvent) : void {
            var txt : String;
            if (event is SecurityErrorEvent) {
                var error : SecurityErrorEvent = event as SecurityErrorEvent;
                txt = "Cannot load M3U8: crossdomain access denied:" + error.text;
            } else if (event is IOErrorEvent && _levels.length) {
                Log.warn("I/O Error while trying to load Playlist, retry in 2s");
                _timeoutID = setTimeout(_loadActiveLevelPlaylist, 2000);
            } else {
                txt = "Cannot load M3U8: " + event.text;
            }
            _hls.dispatchEvent(new HLSEvent(HLSEvent.ERROR, txt));
        };

        /** Return the current manifest. **/
        public function get levels() : Vector.<Level> {
            return _levels;
        };

        /** Return the stream type. **/
        public function get type() : String {
            return _type;
        };

        /** Load the manifest file. **/
        public function load(url : String) : void {
            _close();
            _url = url;
            _levels = new Vector.<Level>();
            _current_level = 0;
            _canStart = false;
            _reload_playlists_timer = getTimer();
            _urlloader.load(new URLRequest(url));
        };

        /** Manifest loaded; check and parse it **/
        private function _loaderHandler(event : Event) : void {
            var loader : URLLoader = URLLoader(event.target);
            _parseManifest(String(loader.data));
        };

        /** parse a playlist **/
        private function _parseLevelPlaylist(string : String, url : String, index : Number) : void {
            if (string != null && string.length != 0) {
                Log.debug("level " + index + " playlist:\n" + string);
                var frags : Vector.<Fragment> = Manifest.getFragments(string, url);
                // set fragment and update sequence number range
                _levels[index].updateFragments(frags);
                _levels[index].targetduration = Manifest.getTargetDuration(string);
                _hls.dispatchEvent(new HLSEvent(HLSEvent.PLAYLIST_DURATION_UPDATED, _levels[index].duration));
            }

            // Check whether the stream is live or not finished yet
            if (Manifest.hasEndlist(string)) {
                _type = HLSTypes.VOD;
            } else {
                _type = HLSTypes.LIVE;
                var timeout : Number = Math.max(100, _reload_playlists_timer + 1000 * _levels[index].averageduration - getTimer());
                Log.debug("Level " + index + " Live Playlist parsing finished: reload in " + timeout.toFixed(0) + " ms");
                _timeoutID = setTimeout(_loadActiveLevelPlaylist, timeout);
            }
            if (!_canStart) {
                _canStart = (_levels[index].fragments.length > 0);
                if (_canStart) {
                    Log.debug("first level filled with at least 1 fragment, notify event");
                    _hls.dispatchEvent(new HLSEvent(HLSEvent.MANIFEST_LOADED, _levels));
                }
            }
            _hls.dispatchEvent(new HLSEvent(HLSEvent.LEVEL_UPDATED, index));
            _manifest_loading = null;
        };

        /** Parse First Level Playlist **/
        private function _parseManifest(string : String) : void {
            // Check for M3U8 playlist or manifest.
            if (string.indexOf(Manifest.HEADER) == 0) {
                // 1 level playlist, create unique level and parse playlist
                if (string.indexOf(Manifest.FRAGMENT) > 0) {
                    var level : Level = new Level();
                    level.url = _url;
                    _levels.push(level);
                    Log.debug("1 Level Playlist, load it");
                    _parseLevelPlaylist(string, _url, 0);
                } else if (string.indexOf(Manifest.LEVEL) > 0) {
                    Log.debug("adaptive playlist:\n" + string);
                    // adaptative playlist, extract levels from playlist, get them and parse them
                    _levels = Manifest.extractLevels(string, _url);
                    _loadActiveLevelPlaylist();
                    if (string.indexOf(Manifest.ALTERNATE_AUDIO) > 0) {
                        Log.debug("alternate audio level found");
                        // parse alternate audio tracks
                        var altAudiolevels : Vector.<AltAudioTrack> = Manifest.extractAltAudioTracks(string, _url);
                        _hls.dispatchEvent(new HLSEvent(HLSEvent.ALT_AUDIO_TRACKS_LIST_CHANGE, altAudiolevels));
                    }
                }
            } else {
                var message : String = "Manifest is not a valid M3U8 file" + _url;
                _hls.dispatchEvent(new HLSEvent(HLSEvent.ERROR, message));
            }
        };

        /** load/reload active M3U8 playlist **/
        private function _loadActiveLevelPlaylist() : void {
            _reload_playlists_timer = getTimer();
            // load active M3U8 playlist only
            _manifest_loading = new Manifest();
            _manifest_loading.loadPlaylist(_levels[_current_level].url, _parseLevelPlaylist, _errorHandler, _current_level, _type, _flushLiveURLCache);
        };

        /** When level switch occurs, assess the need of (re)loading new level playlist **/
        private function _levelSwitchHandler(event : HLSEvent) : void {
            if (_current_level != event.level) {
                _current_level = event.level;
                Log.debug("switch to level " + _current_level);
                if (_type == HLSTypes.LIVE || _levels[_current_level].fragments.length == 0) {
                    Log.debug("(re)load Playlist");
                    clearTimeout(_timeoutID);
                    _timeoutID = setTimeout(_loadActiveLevelPlaylist, 0);
                }
            }
        };

        private function _close() : void {
            Log.debug("cancel any manifest load in progress");
            clearTimeout(_timeoutID);
            try {
                _urlloader.close();
                if (_manifest_loading) {
                    _manifest_loading.close();
                }
            } catch(e : Error) {
            }
        }

        /** When the framework idles out, stop reloading manifest **/
        private function _stateHandler(event : HLSEvent) : void {
            if (event.state == HLSStates.IDLE) {
                _close();
            }
        };

        public function set flushLiveURLCache(val : Boolean) : void {
            _flushLiveURLCache = val;
        }

        public function get flushLiveURLCache() : Boolean {
            return _flushLiveURLCache;
        }
    }
}