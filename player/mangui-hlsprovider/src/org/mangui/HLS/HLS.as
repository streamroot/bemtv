package org.mangui.HLS {
    import flash.net.URLStream;

    import org.mangui.HLS.parsing.Level;
    import org.mangui.HLS.streaming.*;
    import org.mangui.HLS.utils.*;

    import flash.events.*;
    import flash.net.NetStream;
    import flash.net.NetConnection;

    /** Class that manages the streaming process. **/
    public class HLS extends EventDispatcher {
        /** The quality monitor. **/
        private var _fragmentLoader : FragmentLoader;
        /** The manifest parser. **/
        private var _manifestLoader : ManifestLoader;
        /** HLS NetStream **/
        private var _hlsNetStream : HLSNetStream;
        /** HLS URLStream **/
        private var _hlsURLStream : Class;
        private var _client : Object = {};

        /** Create and connect all components. **/
        public function HLS() : void {
            var connection : NetConnection = new NetConnection();
            connection.connect(null);
            _manifestLoader = new ManifestLoader(this);
            _hlsURLStream = URLStream as Class;
            // default loader
            _fragmentLoader = new FragmentLoader(this);
            _hlsNetStream = new HLSNetStream(connection, this, _fragmentLoader);
        };

        /** Forward internal errors. **/
        override public function dispatchEvent(event : Event) : Boolean {
            if (event.type == HLSEvent.ERROR) {
                Log.error(HLSEvent(event).message);
                _hlsNetStream.close();
            }
            return super.dispatchEvent(event);
        };

        /** Return the playback quality level of last loaded fragment **/
        public function get level() : Number {
            return _fragmentLoader.level;
        };

        /*  set playback quality level (-1 for automatic level selection) */
        public function set level(level : Number) : void {
            _fragmentLoader.level = level;
        };

        /* check if we are in autolevel mode */
        public function get autolevel() : Boolean {
            return _fragmentLoader.autolevel;
        };

        /** Return bitrate level lists. **/
        public function get levels() : Vector.<Level> {
            return _manifestLoader.levels;
        };

        /** Return metrics info **/
        public function get metrics() : HLSMetrics {
            return _fragmentLoader.metrics;
        };

        /** Return the current playback position. **/
        public function get position() : Number {
            return _hlsNetStream.position;
        };

        /** Return the current playback state. **/
        public function get state() : String {
            return _hlsNetStream.state;
        };

        /** Return the type of stream (VOD/LIVE). **/
        public function get type() : String {
            return _manifestLoader.type;
        };

        /** Load and parse a new HLS URL **/
        public function load(url : String) : void {
            _hlsNetStream.close();
            _manifestLoader.load(url);
        };

        /** return HLS NetStream **/
        public function get stream() : NetStream {
            return _hlsNetStream;
        }

        public function get client() : Object {
            return _client;
        }

        public function set client(value : Object) : void {
            _client = value;
        }

        /** get current Buffer Length  **/
        public function get bufferLength() : Number {
            return _hlsNetStream.bufferLength;
        };

        /** set minimum buffer Length in seconds 
         * playback will start only if this minimum threshold is reached */
        public function set minBufferLength(new_len : Number) : void {
            _hlsNetStream.minBufferLength = new_len;
        }

        /** set minimum buffer Length in seconds */
        public function get minBufferLength() : Number {
            return _hlsNetStream.minBufferLength;
        };

        /** set maximum buffer Length that can be buffered. setting to 0 means infinite buffering **/
        public function set maxBufferLength(new_len : Number) : void {
            _hlsNetStream.maxBufferLength = new_len;
        }

        /** get maximum buffer Length  **/
        public function get maxBufferLength() : Number {
            return _hlsNetStream.maxBufferLength;
        };

        /** get audio tracks list**/
        public function get audioTracks() : Vector.<HLSAudioTrack> {
            return _fragmentLoader.audioTracks;
        };

        /** get index of the selected audio track (index in audio track lists) **/
        public function get audioTrack() : Number {
            return _fragmentLoader.audioTrack;
        };

        /** select an audio track, based on its index in audio track lists**/
        public function set audioTrack(val : Number) : void {
            _fragmentLoader.audioTrack = val;
        }

        /** if set to true, it will force to flush live URL cache, could be useful with live playlist 
         * as some combinations of Flash Player / Internet Explorer are not able to detect updated URL properly
         **/
        public function set flushLiveURLCache(val : Boolean) : void {
            _manifestLoader.flushLiveURLCache = val;
        }

        /* retrieve force flush live URL cache boolean */
        public function get flushLiveURLCache() : Boolean {
            return _manifestLoader.flushLiveURLCache;
        }

        /* if set to true, playback will start from lowest non-audio level after manifest loading. (default is false) */
        public function set startFromLowestLevel(val : Boolean) : void {
            _fragmentLoader.startFromLowestLevel = val;
        }

        /* retrieve start level logic (default false) */
        public function get startFromLowestLevel() : Boolean {
            return _fragmentLoader.startFromLowestLevel;
        }

        /* if set to true, playback will start from lowest non-audio level after any seek operation. (default is false) */
        public function set seekFromLowestLevel(val : Boolean) : void {
            _fragmentLoader.seekFromLowestLevel = val;
        }

        /* retrieve seek level logic (default false) */
        public function get seekFromLowestLevel() : Boolean {
            return _fragmentLoader.seekFromLowestLevel;
        }


        /* set URL stream loader */
        public function set URLstream(urlstream : Class) : void {
            _hlsURLStream = urlstream;
        }

        /* retrieve URL stream loader */
        public function get URLstream() : Class {
            return _hlsURLStream;
        }
    }
    ;
}