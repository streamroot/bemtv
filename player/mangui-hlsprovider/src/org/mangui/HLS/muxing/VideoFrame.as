package org.mangui.HLS.muxing {
    /** Video Frame **/
    public class VideoFrame {
        private var _header : Number;
        private var _start : Number;
        private var _length : Number;
        private var _type : Number;

        public function VideoFrame(header : Number, length : Number, start : Number, type : Number) {
            _header = header;
            _start = start;
            _length = length;
            _type = type;
        }

        public function get header() : Number {
            return _header;
        }

        public function get length() : Number {
            return _length;
        }

        public function get start() : Number {
            return _start;
        }

        public function get type() : Number {
            return _type;
        }
    }
}