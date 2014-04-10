package org.mangui.HLS.muxing {
    /** Audio Frame **/
    public class AudioFrame {
        private var _start : uint;
        private var _length : uint;
        private var _expected_length : uint;
        private var _rate : uint;

        public function AudioFrame(start : uint, length : uint, expected_length : uint, rate : uint) {
            _start = start;
            _length = length;
            _expected_length = expected_length;
            _rate = rate;
        }

        public function get start() : Number {
            return _start;
        }

        public function get length() : Number {
            return _length;
        }

        public function get expected_length() : Number {
            return _expected_length;
        }

        public function get rate() : Number {
            return _rate;
        }
    }
}