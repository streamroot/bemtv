package org.mangui.HLS.streaming {
    import flash.events.NetStatusEvent;
    import flash.events.Event;
    import flash.events.TimerEvent;

    import org.mangui.HLS.*;
    import org.mangui.HLS.muxing.*;
    import org.mangui.HLS.streaming.*;
    import org.mangui.HLS.utils.*;

    import flash.net.*;
    import flash.utils.*;

    /** Class that keeps the buffer filled. **/
    public class HLSNetStream extends NetStream {
        /** Reference to the framework controller. **/
        private var _hls : HLS;
        /** FLV tags buffer vector **/
        private var _flvTagBuffer : Vector.<Tag>;
        /** FLV tags buffer duration **/
        private var _flvTagBufferDuration : Number;
        /** The fragment loader. **/
        private var _fragmentLoader : FragmentLoader;
        /** means that last fragment of a VOD playlist has been loaded */
        private var _reached_vod_end : Boolean;
        /** Timer used to check buffer and position. **/
        private var _timer : Timer;
        /** requested start position **/
        private var _seek_position_requested : Number;
        /** real start position , retrieved from first fragment **/
        private var _seek_position_real : Number;
        /** is a seek operation in progress ? **/
        private var _seek_in_progress : Boolean;
        /** Current play position (relative position from beginning of sliding window) **/
        private var _playback_current_position : Number;
        /** playlist sliding (non null for live playlist) **/
        private var _playlist_sliding_duration : Number;
        /** total duration of buffered data before last discontinuity */
        private var _buffered_before_last_continuity : Number;
        /** buffer min PTS since last discontinuity  */
        private var _buffer_cur_min_pts : Number;
        /** buffer max PTS since last discontinuity  */
        private var _buffer_cur_max_pts : Number;
        /** previous buffer time. **/
        private var _last_buffer : Number;
        /** Current playback state. **/
        private var _state : String;
        /** max buffer length (default 60s)**/
        private var _buffer_max_len : Number = 60;
        /** min buffer length (default 3s)**/
        private var _buffer_min_len : Number = 3;
        /** playlist duration **/
        private var _playlist_duration : Number = 0;

        /** Create the buffer. **/
        public function HLSNetStream(connection : NetConnection, hls : HLS, fragmentLoader : FragmentLoader) : void {
            super(connection);
            super.bufferTime = 0.1;
            _hls = hls;
            _fragmentLoader = fragmentLoader;
            _hls.addEventListener(HLSEvent.LAST_VOD_FRAGMENT_LOADED, _lastVODFragmentLoadedHandler);
            _hls.addEventListener(HLSEvent.PLAYLIST_DURATION_UPDATED, _playlistDurationUpdated);
            _setState(HLSStates.IDLE);
            _timer = new Timer(100, 0);
            _timer.addEventListener(TimerEvent.TIMER, _checkBuffer);
        };

        /** Check the bufferlength. **/
        private function _checkBuffer(e : Event) : void {
            var playback_absolute_position : Number;
            var playback_relative_position : Number;
            var buffer : Number = this.bufferLength;
            // Calculate the buffer and position.
            if (_seek_in_progress) {
                playback_relative_position = playback_absolute_position = _seek_position_requested;
            } else {
                /** Absolute playback position (start position + play time) **/
                playback_absolute_position = super.time + _seek_position_real;
                /** Relative playback position (Absolute Position - playlist sliding, non null for Live Playlist) **/
                playback_relative_position = playback_absolute_position - _playlist_sliding_duration;
            }
            // only send media time event if data has changed
            if (playback_relative_position != _playback_current_position || buffer != _last_buffer) {
                _playback_current_position = playback_relative_position;
                _last_buffer = buffer;
                _hls.dispatchEvent(new HLSEvent(HLSEvent.MEDIA_TIME, new HLSMediatime(_playback_current_position, _playlist_duration, buffer, _playlist_sliding_duration)));
            }

            // Set playback state. no need to check buffer status if first fragment not yet received
            if (!_seek_in_progress) {
                // check low buffer condition
                if (buffer < _buffer_min_len) {
                    if (buffer <= 0.1) {
                        if (_reached_vod_end) {
                            // reach end of playlist + playback complete (as buffer is empty).
                            // stop timer, report event and switch to IDLE mode.
                            _timer.stop();
                            Log.debug("reached end of VOD playlist, notify playback complete");
                            _hls.dispatchEvent(new HLSEvent(HLSEvent.PLAYBACK_COMPLETE));
                            _setState(HLSStates.IDLE);
                            return;
                        } else {
                            // pause Netstream in really low buffer condition
                            super.pause();
                        }
                    }
                    // dont switch to buffering state in case we reached end of a VOD playlist
                    if (!_reached_vod_end) {
                        if (_state == HLSStates.PLAYING) {
                            // low buffer condition and play state. switch to play buffering state
                            _setState(HLSStates.PLAYING_BUFFERING);
                        } else if (_state == HLSStates.PAUSED) {
                            // low buffer condition and pause state. switch to paused buffering state
                            _setState(HLSStates.PAUSED_BUFFERING);
                        }
                    }
                }
                // in case buffer is full enough or if we have reached end of VOD playlist
                if (buffer >= _buffer_min_len || _reached_vod_end) {
                    // no more in low buffer state
                    if (_state == HLSStates.PLAYING_BUFFERING) {
                        super.resume();
                        _setState(HLSStates.PLAYING);
                    } else if (_state == HLSStates.PAUSED_BUFFERING) {
                        _setState(HLSStates.PAUSED);
                    }
                }
            }
            // in case any data available in our FLV buffer, append into NetStream
            if (_flvTagBuffer.length) {
                if (_seek_in_progress) {
                    /* this is our first injection after seek(),
                    let's flush netstream now
                    this is to avoid black screen during seek command */
                    super.close();
                    super.play(null);
                    super.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
                    // immediatly pause NetStream, it will be resumed when enough data will be buffered in the NetStream
                    super.pause();
                    _seek_in_progress = false;
                    // dispatch event to mimic NetStream behaviour
                    dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, {code:"NetStream.Seek.Notify", level:"status"}));
                }
                // Log.debug("appending data into NetStream");
                while (0 < _flvTagBuffer.length) {
                    var tagBuffer : Tag = _flvTagBuffer.shift();
                    // append data until we drain our _buffer
                    try {
                        if (tagBuffer.type == Tag.DISCONTINUITY) {
                            super.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
                            super.appendBytes(FLV.getHeader());
                        } else {
                            super.appendBytes(tagBuffer.data);
                        }
                    } catch (error : Error) {
                        _errorHandler(new Error(tagBuffer.type + ": " + error.message));
                    }
                    // Last tag done? Then append sequence end.
                    if (_reached_vod_end && _flvTagBuffer.length == 0) {
                        super.appendBytesAction(NetStreamAppendBytesAction.END_SEQUENCE);
                        super.appendBytes(new ByteArray());
                    }
                }
                // FLV tag buffer drained, reset its duration
                _flvTagBufferDuration = 0;
            }
        };

        /** Dispatch an error to the controller. **/
        private function _errorHandler(error : Error) : void {
            _hls.dispatchEvent(new HLSEvent(HLSEvent.ERROR, error.toString()));
        };

        /** Return the current playback state. **/
        public function get position() : Number {
            return _playback_current_position;
        };

        /** Return the current playback state. **/
        public function get state() : String {
            return _state;
        };

        /** Add a fragment to the buffer. **/
        private function _loaderCallback(tags : Vector.<Tag>, min_pts : Number, max_pts : Number, hasDiscontinuity : Boolean, start_position : Number) : void {
            /* PTS of first FLV tag that will be pushed into FLV tag buffer */
            var first_pts : Number;

            if (_seek_position_real == Number.NEGATIVE_INFINITY) {
                /* 
                 * compute r
                 * 
                 *    real seek       requested seek                 Frag 
                 *     position           position                    End
                 *        *------------------*-------------------------
                 *        <------------------>
                 *             seek_offset
                 *
                 * real seek position is the start offset of the first received fragment after seek command. (= fragment start offset).
                 * seek offset is the diff between the requested seek position and the real seek position
                 */
                if (_seek_position_requested < start_position ||
                    _seek_position_requested >= start_position+ ((max_pts-min_pts)/1000)) {
                    _seek_position_real = start_position;
                    first_pts = min_pts;
                } else {
                    _seek_position_real = _seek_position_requested;
                    first_pts = min_pts + 1000 * (_seek_position_real - start_position);
                }
            } else {
                /* whole fragment will be injected */
                first_pts = min_pts;
                /* check live playlist sliding here :
                _seek_position_real + getTotalBufferedDuration()  should be the start_position
                 * /of the new fragment if the playlist was not sliding
                => live playlist sliding is the difference between the new start position  and this previous value */
                _playlist_sliding_duration = (_seek_position_real + getTotalBufferedDuration()) - start_position;
            }
            /* if first fragment loaded, or if discontinuity, record discontinuity start PTS, and insert discontinuity TAG */
            if (hasDiscontinuity) {
                _buffered_before_last_continuity += (_buffer_cur_max_pts - _buffer_cur_min_pts);
                _buffer_cur_min_pts = first_pts;
                _buffer_cur_max_pts = max_pts;
                _flvTagBuffer.push(new Tag(Tag.DISCONTINUITY, first_pts, first_pts, false));
            } else {
                // same continuity than previously, update its max PTS
                _buffer_cur_max_pts = max_pts;
            }

            tags.sort(_sortTagsbyDTS);

            if (_seek_in_progress) {
                /* accurate seeking : 
                 * analyze fragment tags and look for last keyframe before seek position.
                 * in schema below, we seek at t=17s, in a fragment starting at t=10s, ending at t=20s
                 * this fragment contains 4 keyframes.
                 *  timestamp of the last keyframe before seek position is @ t=16s
                 * 
                 *                             seek_pts
                 *  K----------K------------K------*-----K---------|
                 *  10s       13s          16s    17s    18s      20s
                 *  
                 *  
                 */
                var i : Number = 0;
                var keyframe_pts : Number;
                for (i = 0; i < tags.length; i++) {
                    // look for last keyframe with pts <= seek_pts
                    if (tags[i].keyframe == true && tags[i].pts <= first_pts && tags[i].type.indexOf("AVC") != -1)
                        keyframe_pts = tags[i].pts;
                }

                for (i = 0; i < tags.length; i++) {
                    if (tags[i].pts >= first_pts) {
                        _flvTagBuffer.push(tags[i]);
                    } else {
                        switch(tags[i].type) {
                            case Tag.AAC_HEADER:
                            case Tag.AVC_HEADER:
                                tags[i].pts = tags[i].dts = first_pts;
                                _flvTagBuffer.push(tags[i]);
                                break;
                            case Tag.AVC_NALU:
                                /* only append video tags starting from last keyframe before seek position to avoid playback artifacts
                                 *  rationale of this is that there can be multiple keyframes per segment. if we append all keyframes
                                 *  in NetStream, all of them will be displayed in a row and this will introduce some playback artifacts
                                 *  */
                                if (tags[i].pts >= keyframe_pts) {
                                    tags[i].pts = tags[i].dts = first_pts;
                                    _flvTagBuffer.push(tags[i]);
                                }
                                break;
                            default:
                                break;
                        }
                    }
                }
            } else {
                // not after seek, push all FLV tags
                for (i = 0; i < tags.length; i++) {
                    _flvTagBuffer.push(tags[i]);
                }
            }
            _flvTagBufferDuration += (max_pts - first_pts) / 1000;
            Log.debug("Loaded position/duration/sliding/discontinuity:" + start_position.toFixed(2) + "/" + ((max_pts - min_pts) / 1000).toFixed(2) + "/" + _playlist_sliding_duration.toFixed(2) + "/" + hasDiscontinuity);
        };

        /** return total buffered duration since seek() call, needed to compute live playlist sliding  */
        private function getTotalBufferedDuration() : Number {
            return (_buffered_before_last_continuity + _buffer_cur_max_pts - _buffer_cur_min_pts) / 1000;
        }

        private function _lastVODFragmentLoadedHandler(event : HLSEvent) : void {
            Log.debug("last fragment loaded");
            _reached_vod_end = true;
        }

        private function _playlistDurationUpdated(event : HLSEvent) : void {
            _playlist_duration = event.duration;
        }

        /** Change playback state. **/
        private function _setState(state : String) : void {
            if (state != _state) {
                Log.debug('[STATE] from ' + _state + ' to ' + state);
                _state = state;
                _hls.dispatchEvent(new HLSEvent(HLSEvent.STATE, _state));
            }
        };

        /** Sort the buffer by tag. **/
        private function _sortTagsbyDTS(x : Tag, y : Tag) : Number {
            if (x.dts < y.dts) {
                return -1;
            } else if (x.dts > y.dts) {
                return 1;
            } else {
                if (x.type == Tag.AVC_HEADER || x.type == Tag.AAC_HEADER) {
                    return -1;
                } else if (y.type == Tag.AVC_HEADER || y.type == Tag.AAC_HEADER) {
                    return 1;
                } else {
                    if (x.type == Tag.AVC_NALU) {
                        return -1;
                    } else if (y.type == Tag.AVC_NALU) {
                        return 1;
                    } else {
                        return 0;
                    }
                }
            }
        };

        override public function play(...args) : void {
            var _playStart : Number;
            if (args.length >= 2) {
                _playStart = Number(args[1]);
            } else {
                _playStart = -1;
            }
            Log.info("HLSNetStream:play(" + _playStart + ")");
            seek(_playStart);
        }

        override public function play2(param : NetStreamPlayOptions) : void {
            Log.info("HLSNetStream:play2(" + param.start + ")");
            seek(param.start);
        }

        /** Pause playback. **/
        override public function pause() : void {
            Log.info("HLSNetStream:pause");
            if (_state == HLSStates.PLAYING) {
                super.pause();
                _setState(HLSStates.PAUSED);
            } else if (_state == HLSStates.PLAYING_BUFFERING) {
                super.pause();
                _setState(HLSStates.PAUSED_BUFFERING);
            }
        };

        /** Resume playback. **/
        override public function resume() : void {
            Log.info("HLSNetStream:resume");
            if (_state == HLSStates.PAUSED) {
                super.resume();
                _setState(HLSStates.PLAYING);
            } else if (_state == HLSStates.PAUSED_BUFFERING) {
                // dont resume NetStream here, it will be resumed by Timer. this avoids resuming playback while seeking is in progress
                _setState(HLSStates.PLAYING_BUFFERING);
            }
        };

        /** get Buffer Length  **/
        override public function get bufferLength() : Number {
            /* remaining buffer is total duration buffered since beginning minus playback time */
            if (_seek_in_progress) {
                return _flvTagBufferDuration;
            } else {
                return super.bufferLength + _flvTagBufferDuration;
            }
        };

        /** get min Buffer Length  **/
        public function get minBufferLength() : Number {
            return _buffer_min_len;
        };

        /** set min Buffer Length  **/
        public function set minBufferLength(new_len : Number) : void {
            if (new_len < 0.1) {
                new_len = 0.1;
            }
            _buffer_min_len = new_len;
        };

        /** get max Buffer Length  **/
        public function get maxBufferLength() : Number {
            return _buffer_max_len;
        };

        /** set max Buffer Length  **/
        public function set maxBufferLength(new_len : Number) : void {
            _buffer_max_len = new_len;
        };

        /** Start playing data in the buffer. **/
        override public function seek(position : Number) : void {
            Log.info("HLSNetStream:seek(" + position + ")");
            _fragmentLoader.stop();
            _fragmentLoader.seek(position, _loaderCallback);
            _flvTagBuffer = new Vector.<Tag>();
            _flvTagBufferDuration = _buffered_before_last_continuity = _buffer_cur_min_pts = _buffer_cur_max_pts = _playlist_sliding_duration = 0;
            _seek_position_requested = Math.max(position,0);
            _seek_position_real = Number.NEGATIVE_INFINITY;
            _seek_in_progress = true;
            _reached_vod_end = false;
            /* if HLS was in paused state before seeking, 
             * switch to paused buffering state
             * otherwise, switch to playing buffering state
             */
            switch(_state) {
                case HLSStates.PAUSED:
                case HLSStates.PAUSED_BUFFERING:
                    _setState(HLSStates.PAUSED_BUFFERING);
                    break;
                case HLSStates.IDLE:
                case HLSStates.PLAYING:
                case HLSStates.PLAYING_BUFFERING:
                default:
                    _setState(HLSStates.PLAYING_BUFFERING);
                    break;
            }
            /* always pause NetStream while seeking, even if we are in play state
             * in that case, NetStream will be resumed after first fragment loading
             */
            super.pause();
            _timer.start();
        };

        /** Stop playback. **/
        override public function close() : void {
            Log.info("HLSNetStream:close");
            super.close();
            _timer.stop();
            _setState(HLSStates.IDLE);
        };
    }
}