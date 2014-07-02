package org.mangui.chromeless {
    import flash.net.URLStream;

    import org.mangui.HLS.parsing.Level;
    import org.mangui.HLS.*;
    import org.mangui.HLS.utils.*;

    import flash.display.*;
    import flash.events.*;
    import flash.external.ExternalInterface;
    import flash.geom.Rectangle;
    import flash.media.Video;
    import flash.media.SoundTransform;
    import flash.media.StageVideo;
    import flash.media.StageVideoAvailability;
    import flash.utils.setTimeout;

    public class ChromelessPlayer extends Sprite {
        /** reference to the framework. **/
        private var _hls : HLS;
        /** Sheet to place on top of the video. **/
        private var _sheet : Sprite;
        /** Reference to the stage video element. **/
        private var _stageVideo : StageVideo = null;
        /** Reference to the video element. **/
        private var _video : Video = null;
        /** Video size **/
        private var _videoWidth : Number = 0;
        private var _videoHeight : Number = 0;
        /** current media position */
        private var _media_position : Number;
        private var _duration : Number;

        /** Initialization. **/
        public function ChromelessPlayer() : void {
            // Set stage properties
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.fullScreenSourceRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, _onStageVideoState);
            stage.addEventListener(Event.RESIZE, _onStageResize);
            // Draw sheet for catching clicks
            _sheet = new Sprite();
            _sheet.graphics.beginFill(0x000000, 0);
            _sheet.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            _sheet.addEventListener(MouseEvent.CLICK, _clickHandler);
            _sheet.buttonMode = true;
            addChild(_sheet);
            // Connect getters to JS.
            ExternalInterface.addCallback("getLevel", _getLevel);
            ExternalInterface.addCallback("getLevels", _getLevels);
            ExternalInterface.addCallback("getMetrics", _getMetrics);
            ExternalInterface.addCallback("getDuration", _getDuration);
            ExternalInterface.addCallback("getPosition", _getPosition);
            ExternalInterface.addCallback("getState", _getState);
            ExternalInterface.addCallback("getType", _getType);
            ExternalInterface.addCallback("getmaxBufferLength", _getmaxBufferLength);
            ExternalInterface.addCallback("getminBufferLength", _getminBufferLength);
            ExternalInterface.addCallback("getbufferLength", _getbufferLength);
            ExternalInterface.addCallback("getLogDebug", _getLogDebug);
            ExternalInterface.addCallback("getLogDebug2", _getLogDebug2);
            ExternalInterface.addCallback("getflushLiveURLCache", _getflushLiveURLCache);
            ExternalInterface.addCallback("getstartFromLowestLevel", _getstartFromLowestLevel);
            ExternalInterface.addCallback("getseekFromLowestLevel", _getseekFromLowestLevel);
            ExternalInterface.addCallback("getJSURLStream", _getJSURLStream);
            ExternalInterface.addCallback("getPlayerVersion", _getPlayerVersion);
            ExternalInterface.addCallback("getAudioTrackList", _getAudioTrackList);
            ExternalInterface.addCallback("getAudioTrackId", _getAudioTrackId);
            // Connect calls to JS.
            ExternalInterface.addCallback("playerLoad", _load);
            ExternalInterface.addCallback("playerPlay", _play);
            ExternalInterface.addCallback("playerPause", _pause);
            ExternalInterface.addCallback("playerResume", _resume);
            ExternalInterface.addCallback("playerSeek", _seek);
            ExternalInterface.addCallback("playerStop", _stop);
            ExternalInterface.addCallback("playerVolume", _volume);
            ExternalInterface.addCallback("playerSetLevel", _setLevel);
            ExternalInterface.addCallback("playerSmoothSetLevel", _smoothSetLevel);
            ExternalInterface.addCallback("playerSetmaxBufferLength", _setmaxBufferLength);
            ExternalInterface.addCallback("playerSetminBufferLength", _setminBufferLength);
            ExternalInterface.addCallback("playerSetflushLiveURLCache", _setflushLiveURLCache);
            ExternalInterface.addCallback("playerSetstartFromLowestLevel", _setstartFromLowestLevel);
            ExternalInterface.addCallback("playerSetseekFromLowestLevel", _setseekFromLowestLevel);
            ExternalInterface.addCallback("playerSetLogDebug", _setLogDebug);
            ExternalInterface.addCallback("playerSetLogDebug2", _setLogDebug2);
            ExternalInterface.addCallback("playerSetAudioTrack", _setAudioTrack);
            ExternalInterface.addCallback("playerSetJSURLStream", _setJSURLStream);

            setTimeout(_pingJavascript, 50);
        };

        /** Notify javascript the framework is ready. **/
        private function _pingJavascript() : void {
            ExternalInterface.call("onHLSReady", ExternalInterface.objectID);
        };

        /** Forward events from the framework. **/
        private function _completeHandler(event : HLSEvent) : void {
            if (ExternalInterface.available) {
                ExternalInterface.call("onComplete");
            }
        };

        private function _errorHandler(event : HLSEvent) : void {
            if (ExternalInterface.available) {
                ExternalInterface.call("onError", event.message);
            }
        };

        private function _fragmentHandler(event : HLSEvent) : void {
            if (ExternalInterface.available) {
                ExternalInterface.call("onFragment", event.metrics.bandwidth, event.metrics.level, stage.stageWidth);
            }
        };

        private function _manifestHandler(event : HLSEvent) : void {
            _duration = event.levels[0].duration;
            if (ExternalInterface.available) {
                ExternalInterface.call("onManifest", event.levels[0].duration);
            }
        };

        private function _mediaTimeHandler(event : HLSEvent) : void {
            _duration = event.mediatime.duration;
            _media_position = event.mediatime.position;
            if (ExternalInterface.available) {
                ExternalInterface.call("onPosition", event.mediatime.position, event.mediatime.duration, event.mediatime.live_sliding);
            }

            var videoWidth : Number = _video ? _video.videoWidth : _stageVideo.videoWidth;
            var videoHeight : Number = _video ? _video.videoHeight : _stageVideo.videoHeight;

            if (videoWidth && videoHeight) {
                var changed : Boolean = _videoWidth != videoWidth || _videoHeight != videoHeight;
                if (changed) {
                    _videoHeight = videoHeight;
                    _videoWidth = videoWidth;
                    _resize();
                    if (ExternalInterface.available) {
                        ExternalInterface.call("onVideoSize", _videoWidth, _videoHeight);
                    }
                }
            }
        };

        private function _stateHandler(event : HLSEvent) : void {
            if (ExternalInterface.available) {
                ExternalInterface.call("onState", event.state);
            }
        };

        private function _switchHandler(event : HLSEvent) : void {
            if (ExternalInterface.available) {
                ExternalInterface.call("onSwitch", event.level);
            }
        };

        private function _audioTracksListChange(event : HLSEvent) : void {
            if (ExternalInterface.available) {
                ExternalInterface.call("onAudioTracksListChange", _getAudioTrackList());
            }
        }

        private function _audioTrackChange(event : HLSEvent) : void {
            if (ExternalInterface.available) {
                ExternalInterface.call("onAudioTrackChange", event.audioTrack);
            }
        }

        /** Javascript getters. **/
        private function _getLevel() : Number {
            return _hls.level;
        };

        private function _getLevels() : Vector.<Level> {
            return _hls.levels;
        };

        private function _getMetrics() : Object {
            return _hls.metrics;
        };

        private function _getDuration() : Number {
            return _duration;
        };

        private function _getPosition() : Number {
            return _hls.position;
        };

        private function _getState() : String {
            return _hls.state;
        };

        private function _getType() : String {
            return _hls.type;
        };

        private function _getbufferLength() : Number {
            return _hls.bufferLength;
        };

        private function _getmaxBufferLength() : Number {
            return _hls.maxBufferLength;
        };

        private function _getminBufferLength() : Number {
            return _hls.minBufferLength;
        };

        private function _getflushLiveURLCache() : Boolean {
            return _hls.flushLiveURLCache;
        };

        private function _getstartFromLowestLevel() : Boolean {
            return _hls.startFromLowestLevel;
        };

        private function _getseekFromLowestLevel() : Boolean {
            return _hls.seekFromLowestLevel;
        };

        private function _getLogDebug() : Boolean {
            return Log.LOG_DEBUG_ENABLED;
        };

        private function _getLogDebug2() : Boolean {
            return Log.LOG_DEBUG2_ENABLED;
        };

        private function _getJSURLStream() : Boolean {
            return (_hls.URLstream is JSURLStream);
        };

        private function _getPlayerVersion() : Number {
            return 2;
        };

        private function _getAudioTrackList() : Array {
            var list : Array = [];
            var vec : Vector.<HLSAudioTrack> = _hls.audioTracks;
            for (var i : Object in vec) {
                list.push(vec[i]);
            }
            return list;
        };

        private function _getAudioTrackId() : Number {
            return _hls.audioTrack;
        };

        /** Javascript calls. **/
        private function _load(url : String) : void {
            _hls.load(url);
        };

        private function _play() : void {
            _hls.stream.play();
        };

        private function _pause() : void {
            _hls.stream.pause();
        };

        private function _resume() : void {
            _hls.stream.resume();
        };

        private function _seek(position : Number) : void {
            _hls.stream.seek(position);
        };

        private function _stop() : void {
            _hls.stream.close();
        };

        private function _volume(percent : Number) : void {
            _hls.stream.soundTransform = new SoundTransform(percent / 100);
        };

        private function _setLevel(level : Number) : void {
            _smoothSetLevel(level);
            if (!isNaN(_media_position) && level != -1) {
                _hls.stream.seek(_media_position);
            }
        };

        private function _smoothSetLevel(level: Number) : void {
            if (level != _hls.level) {
              _hls.level = level;
            }
        };

        private function _setmaxBufferLength(new_len : Number) : void {
            _hls.maxBufferLength = new_len;
        };

        private function _setminBufferLength(new_len : Number) : void {
            _hls.minBufferLength = new_len;
        };

        private function _setflushLiveURLCache(flushLiveURLCache : Boolean) : void {
            _hls.flushLiveURLCache = flushLiveURLCache;
        };

        private function _setstartFromLowestLevel(startFromLowestLevel : Boolean) : void {
            _hls.startFromLowestLevel = startFromLowestLevel;
        };

        private function _setseekFromLowestLevel(seekFromLowestLevel : Boolean) : void {
            _hls.seekFromLowestLevel = seekFromLowestLevel;
        };

        private function _setLogDebug(debug : Boolean) : void {
            Log.LOG_DEBUG_ENABLED = debug;
        };

        private function _setLogDebug2(debug2 : Boolean) : void {
            Log.LOG_DEBUG2_ENABLED = debug2;
        };

        private function _setJSURLStream(jsURLstream : Boolean) : void {
            if (jsURLstream) {
                _hls.URLstream = JSURLStream as Class;
            } else {
                _hls.URLstream = URLStream as Class;
            }
        };

        private function _setAudioTrack(val : Number) : void {
            if (val == _hls.audioTrack) return;
            _hls.audioTrack = val;
            if (!isNaN(_media_position)) {
                _hls.stream.seek(_media_position);
            }
        };

        /** Mouse click handler. **/
        private function _clickHandler(event : MouseEvent) : void {
            if (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE || stage.displayState == StageDisplayState.FULL_SCREEN) {
                stage.displayState = StageDisplayState.NORMAL;
            } else {
                stage.displayState = StageDisplayState.FULL_SCREEN;
            }
        };

        /** StageVideo detector. **/
        private function _onStageVideoState(event : StageVideoAvailabilityEvent) : void {
            var available : Boolean = (event.availability == StageVideoAvailability.AVAILABLE);
            _hls = new HLS();
            _hls.addEventListener(HLSEvent.PLAYBACK_COMPLETE, _completeHandler);
            _hls.addEventListener(HLSEvent.ERROR, _errorHandler);
            _hls.addEventListener(HLSEvent.FRAGMENT_LOADED, _fragmentHandler);
            _hls.addEventListener(HLSEvent.MANIFEST_LOADED, _manifestHandler);
            _hls.addEventListener(HLSEvent.MEDIA_TIME, _mediaTimeHandler);
            _hls.addEventListener(HLSEvent.STATE, _stateHandler);
            _hls.addEventListener(HLSEvent.QUALITY_SWITCH, _switchHandler);
            _hls.addEventListener(HLSEvent.AUDIO_TRACKS_LIST_CHANGE, _audioTracksListChange);
            _hls.addEventListener(HLSEvent.AUDIO_TRACK_CHANGE, _audioTrackChange);

            if (available && stage.stageVideos.length > 0) {
                _stageVideo = stage.stageVideos[0];
                _stageVideo.viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
                _stageVideo.attachNetStream(_hls.stream);
            } else {
                _video = new Video(stage.stageWidth, stage.stageHeight);
                addChild(_video);
                _video.smoothing = true;
                _video.attachNetStream(_hls.stream);
            }
            stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, _onStageVideoState);
        };

        private function _onStageResize(event : Event) : void {
            stage.fullScreenSourceRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            _sheet.width = stage.stageWidth;
            _sheet.height = stage.stageHeight;
            _resize();
        };

        private function _resize() : void {
            var rect : Rectangle;
            rect = ScaleVideo.resizeRectangle(_videoWidth, _videoHeight, stage.stageWidth, stage.stageHeight);
            // resize video
            if (_video) {
                _video.width = rect.width;
                _video.height = rect.height;
                _video.x = rect.x;
                _video.y = rect.y;
            } else if (_stageVideo) {
                _stageVideo.viewPort = rect;
            }
        }
    }
}
