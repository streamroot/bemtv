package org.mangui.HLS {
    /** Identifiers for the different stream types. **/
    public class HLSMetrics {
        private var _level : Number;
        private var _bandwidth : Number;

        public function HLSMetrics(level : Number, bandwidth : Number) {
            _level = level;
            _bandwidth = bandwidth;
        }

        public function get level() : Number {
            return _level;
        }

        public function get bandwidth() : Number {
            return _bandwidth;
        }
    }
}