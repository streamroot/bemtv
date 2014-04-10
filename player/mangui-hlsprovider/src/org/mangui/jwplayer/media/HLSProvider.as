package org.mangui.jwplayer.media {
    import org.mangui.HLS.parsing.Level;
    import org.mangui.HLS.*;
    import org.mangui.HLS.utils.Log;
    import org.mangui.HLS.utils.ScaleVideo;

    import com.longtailvideo.jwplayer.events.MediaEvent;
    import com.longtailvideo.jwplayer.model.PlayerConfig;
    import com.longtailvideo.jwplayer.model.PlaylistItem;
    import com.longtailvideo.jwplayer.media.*;
    import com.longtailvideo.jwplayer.player.PlayerState;
    import com.longtailvideo.jwplayer.utils.RootReference;

    import flash.display.DisplayObject;
    import flash.geom.Rectangle;
    import flash.media.SoundTransform;
    import flash.media.Video;
    import flash.media.StageVideo;
    import flash.system.Capabilities;
    import flash.events.Event;

    /** JW Player provider for hls streaming. **/
    public class HLSProvider extends MediaProvider {
        /** Reference to the framework. **/
        protected var _hls : HLS;
        /** Current quality level. **/
        protected var _level : Number;
        /** Reference to the quality levels. **/
        protected var _levels : Vector.<Level>;
        /** Reference to the video object. **/
        private var _video : Video;
        /** Reference to the stage video element. **/
        private var _stageVideo : StageVideo;
        /** Whether or not StageVideo is enabled (not working with JW5) **/
        protected var _stageEnabled : Boolean = false;
        /** current position **/
        protected var _media_position : Number;
        /** Video Original size **/
        private var _videoWidth : Number = 0;
        private var _videoHeight : Number = 0;
        private var _seekInLiveDurationThreshold : Number = 60;

        public function HLSProvider() {
            super('hls');
        };

        /** Forward completes from the framework. **/
        private function _completeHandler(event : HLSEvent) : void {
            complete();
        };

        /** Forward playback errors from the framework. **/
        private function _errorHandler(event : HLSEvent) : void {
            super.error(event.message);
        };

        /** Forward QOS metrics on fragment load. **/
        protected function _fragmentHandler(event : HLSEvent) : void {
            _level = event.metrics.level;
            sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata:{bandwidth:Math.round(event.metrics.bandwidth / 1024), droppedFrames:_hls.stream.info.droppedFrames, currentLevel:(_level + 1) + ' of ' + _levels.length + ' (' + Math.round(_levels[_level].bitrate / 1024) + 'kbps, ' + _levels[_level].width + 'px)', width:_videoWidth}});
        };

        /** Update video A/R on manifest load. **/
        private function _manifestHandler(event : HLSEvent) : void {
            _levels = event.levels;
            // only report position/duration/buffer for VOD playlist and live playlist with duration > _seekInLiveDurationThreshold
            if (_hls.type == HLSTypes.VOD || _levels[0].duration > _seekInLiveDurationThreshold) {
                item.duration = _levels[0].duration;
            } else {
                item.duration = -1;
            }
            sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position:0, duration:item.duration});
            _hls.addEventListener(HLSEvent.MEDIA_TIME, _mediaTimeHandler);
            /* start playback on manifest load */
            if (item.start != 0) {
                _hls.stream.seek(item.start);
            } else {
                _hls.stream.play();
            }
        };

        /** Update playback position. **/
        private function _mediaTimeHandler(event : HLSEvent) : void {
            // only report position/duration/buffer for VOD playlist and live playlist with duration > _seekInLiveDurationThreshold
            if (_hls.type == HLSTypes.VOD || event.mediatime.duration > _seekInLiveDurationThreshold) {
                item.duration = event.mediatime.duration;
                _media_position = Math.max(0, event.mediatime.position);
                var _bufferPercent : Number = 100 * (_media_position + event.mediatime.buffer) / event.mediatime.duration;
                sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {bufferPercent:_bufferPercent, offset:0, position:_media_position, duration:event.mediatime.duration});
            }
            var videoWidth : Number;
            var videoHeight : Number;
            if (_stageVideo) {
                videoWidth = _stageVideo.videoWidth;
                videoHeight = _stageVideo.videoHeight;
            } else {
                videoWidth = _video.videoWidth;
                videoHeight = _video.videoHeight;
            }

            if (videoWidth && videoHeight) {
                if (_videoWidth != videoWidth || _videoHeight != videoHeight) {
                    _videoHeight = videoHeight;
                    _videoWidth = videoWidth;
                    Log.info("video size changed to " + _videoWidth + "/" + _videoHeight);
                    // force resize to adjust video A/R
                    resize(_width, _height);
                }
            }
        };

        /** Forward state changes from the framework. **/
        private function _stateHandler(event : HLSEvent) : void {
            switch(event.state) {
                case HLSStates.IDLE:
                    setState(PlayerState.IDLE);
                    break;
                case HLSStates.PLAYING_BUFFERING:
                case HLSStates.PAUSED_BUFFERING:
                    setState(PlayerState.BUFFERING);
                    break;
                case HLSStates.PLAYING:
                    _video.visible = true;
                    setState(PlayerState.PLAYING);
                    break;
                case HLSStates.PAUSED:
                    setState(PlayerState.PAUSED);
                    break;
            }
        };

        private function _audioHandler(e : Event) : void {
            media = null;
            // sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED);
            // dispatchEvent(new MediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED));
        }

        /** Set the volume on init. **/
        override public function initializeMediaProvider(cfg : PlayerConfig) : void {
            super.initializeMediaProvider(cfg);
            _hls = new HLS();
            _hls.stream.soundTransform = new SoundTransform(cfg.volume / 100);
            _hls.addEventListener(HLSEvent.PLAYBACK_COMPLETE, _completeHandler);
            _hls.addEventListener(HLSEvent.ERROR, _errorHandler);
            _hls.addEventListener(HLSEvent.FRAGMENT_LOADED, _fragmentHandler);
            _hls.addEventListener(HLSEvent.MANIFEST_LOADED, _manifestHandler);
            _hls.addEventListener(HLSEvent.STATE, _stateHandler);
            _hls.addEventListener(HLSEvent.AUDIO_ONLY, _audioHandler);

            // Allow stagevideo to be disabled by user config
            if (cfg.hasOwnProperty('stagevideo') && cfg['stagevideo'].toString() == "false") {
                _stageEnabled = false;
            }
            _video = new Video(320, 240);
            _video.smoothing = true;
            // Use stageVideo when available
            if (_stageEnabled && RootReference.stage.stageVideos.length > 0) {
                _stageVideo = RootReference.stage.stageVideos[0];
                _stageVideo.viewPort = new Rectangle(0, 0, 320, 240);
                _stageVideo.attachNetStream(_hls.stream);
                Log.info("stage video enabled");
            } else {
                _video.attachNetStream(_hls.stream);
            }

            _level = 0;
            var value : Object;

            // parse configuration parameters
            value = cfg.hls_debug;
            if (value != null) {
                Log.info("hls_debug:" + value);
                Log.LOG_DEBUG_ENABLED = value as Boolean;
            }

            value = cfg.hls_debug2;
            if (value != null) {
                Log.info("hls_debug2:" + value);
                Log.LOG_DEBUG2_ENABLED = value as Boolean;
            }

            value = cfg.hls_minbufferlength;
            if (value != null) {
                Log.info("hls_minbufferlength:" + value);
                _hls.minBufferLength = value as Number;
            }

            value = cfg.hls_maxbufferlength;
            if (value != null) {
                Log.info("hls_maxbufferlength:" + value);
                _hls.maxBufferLength = value as Number;
            }

            value = cfg.hls_startfromlowestlevel;
            if (value != null) {
                Log.info("hls_startfromlowestlevel:" + value);
                _hls.startFromLowestLevel = value as Boolean;
            }

            value = cfg.hls_seekfromlowestlevel;
            if (value != null) {
                Log.info("hls_seekfromlowestlevel:" + value);
                _hls.seekFromLowestLevel = value as Boolean;
            }

            value = cfg.hls_live_flushurlcache;
            if (value != null) {
                Log.info("hls_live_flushurlcache:" + value);
                _hls.flushLiveURLCache = value as Boolean;
            }

            value = cfg.hls_live_seekdurationthreshold;
            if (value != null) {
                Log.info("hls_live_seekdurationthreshold:" + value);
                _seekInLiveDurationThreshold = value as Number;
            }
            mute(cfg.mute);
        };

        /** Check that Flash Player version is sufficient (10.1 or above) **/
        private function _checkVersion() : Number {
            var versionStr : String = Capabilities.version;
            var verArray : Array = versionStr.split(/\s|,/);
            var versionNum : Number = Number(String(verArray[1] + "." + verArray[2]));
            return versionNum;
        }

        /** Load a new playlist item **/
        override public function load(itm : PlaylistItem) : void {
            // Check flash player version
            var ver : Number = _checkVersion();
            var minVersion : Number = 10.1;
            if ( ver < minVersion ) {
                sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message:"HLS streaming requires Flash Player 10.1 at mimimum"});
            } else {
                super.load(itm);
                play();
            }
        };

        /** Get the video object. **/
        override public function get display() : DisplayObject {
            return _video;
        };

        /** Resume playback of a paused item. **/
        override public function play() : void {
            if (state == PlayerState.PAUSED) {
                _hls.stream.resume();
            } else {
                setState(PlayerState.BUFFERING);
                _hls.load(item.file);
            }
        };

        /** Pause a playing item. **/
        override public function pause() : void {
            _hls.stream.pause();
        };

        /** Do a resize on the video. **/
        override public function resize(width : Number, height : Number) : void {
            Log.info("resize video from [" + _videoWidth + "," + _videoHeight + "]" + "to [" + width + "," + height + "]");
            _width = width;
            _height = height;
            if (_videoWidth && _videoHeight) {
                var rect : Rectangle = ScaleVideo.resizeRectangle(_videoWidth, _videoHeight, width, height);
                if (_stageVideo) {
                    _stageVideo.viewPort = rect;
                } else {
                    _video.x = rect.x;
                    _video.y = rect.y;
                    _video.width = rect.width;
                    _video.height = rect.height;
                }
            }
        };

        /** Seek to a certain position in the item. **/
        override public function seek(pos : Number) : void {
            _hls.stream.seek(pos);
        };

        /** Change the playback volume of the item. **/
        override public function setVolume(vol : Number) : void {
            _hls.stream.soundTransform = new SoundTransform(vol / 100);
            super.setVolume(vol);
        };

        /** Stop playback. **/
        override public function stop() : void {
            _hls.stream.close();
            super.stop();
            _hls.removeEventListener(HLSEvent.MEDIA_TIME, _mediaTimeHandler);
            _level = 0;
        };
    }
}