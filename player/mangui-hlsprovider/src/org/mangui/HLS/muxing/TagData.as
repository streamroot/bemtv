package org.mangui.HLS.muxing {
    import flash.utils.ByteArray;

    /** Tag Content **/
    public class TagData {
        private var _array : ByteArray;
        private var _start : uint;
        private var _length : uint;

        public function TagData(array : ByteArray, start : uint, length : uint) {
            _array = array;
            _start = start;
            _length = length;
        }

        public function get array() : ByteArray {
            return _array;
        }

        public function get start() : Number {
            return _start;
        }

        public function get length() : Number {
            return _length;
        }
    }
}