package org.mangui.HLS {
    /** Identifiers for the different stream types. **/
    public class HLSMediatime {
        private var _position : Number;
        private var _duration : Number;
        private var _live_sliding : Number;
        private var _buffer : Number;

        public function HLSMediatime(position : Number, duration : Number, buffer : Number, live_sliding:Number) {
            _position = position;
            _duration = duration;
            _buffer = buffer;
            _live_sliding = live_sliding;
        }

        /**  playback position (in seconds), relative to current playlist start. 
         * this value could be negative in case of live playlist sliding :
         *  this can happen in case current playback position 
         * is in a fragment that has been removed from the playlist
         */
        
        public function get position() : Number {
            return _position;
        }
        /** current playlist duration (in seconds) **/
        public function get duration() : Number {
            return _duration;
        }

        /** current buffer duration  (in seconds) **/
        public function get buffer() : Number {
            return _buffer;
        }

        /**  live playlist sliding since previous seek()  (in seconds)**/
        public function get live_sliding() : Number {
            return _live_sliding;
        }

    }
}