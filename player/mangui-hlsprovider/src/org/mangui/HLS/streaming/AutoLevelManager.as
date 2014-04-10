package org.mangui.HLS.streaming {
    import org.mangui.HLS.parsing.Level;
    import org.mangui.HLS.*;
    import org.mangui.HLS.utils.Log;

    /** Class that manages auto level selection **/
    public class AutoLevelManager {
        /** Reference to the HLS controller. **/
        private var _hls : HLS;
        /** switch up threshold **/
        private var _switchup : Array = null;
        /** switch down threshold **/
        private var _switchdown : Array = null;
        /** bitrate array **/
        private var _bitrate : Array = null;
        /** nb level **/
        private var _nbLevel : Number = 0;

        /** Create the loader. **/
        public function AutoLevelManager(hls : HLS) : void {
            _hls = hls;
            _hls.addEventListener(HLSEvent.MANIFEST_LOADED, _manifestLoadedHandler);
        };

        /** Store the manifest data. **/
        private function _manifestLoadedHandler(event : HLSEvent) : void {
            var levels : Vector.<Level>= event.levels;
            var maxswitchup : Number = 0;
            var minswitchdwown : Number = Number.MAX_VALUE;
            _nbLevel = levels.length;
            _bitrate = new Array(_nbLevel);
            _switchup = new Array(_nbLevel);
            _switchdown = new Array(_nbLevel);
            var i : Number;

            for (i = 0; i < _nbLevel; i++) {
                _bitrate[i] = levels[i].bitrate;
            }

            for (i = 0; i < _nbLevel - 1; i++) {
                _switchup[i] = (_bitrate[i + 1] - _bitrate[i]) / _bitrate[i];
                maxswitchup = Math.max(maxswitchup, _switchup[i]);
            }
            for (i = 0; i < _nbLevel - 1; i++) {
                _switchup[i] = Math.min(maxswitchup, 2 * _switchup[i]);
                Log.debug("_switchup[" + i + "]=" + _switchup[i]);
            }

            for (i = 1; i < _nbLevel; i++) {
                _switchdown[i] = (_bitrate[i] - _bitrate[i - 1]) / _bitrate[i];
                minswitchdwown = Math.min(minswitchdwown, _switchdown[i]);
            }
            for (i = 1; i < _nbLevel; i++) {
                _switchdown[i] = Math.max(2 * minswitchdwown, _switchdown[i]);
                Log.debug("_switchdown[" + i + "]=" + _switchdown[i]);
            }
        };

        public function getbestlevel(download_bandwidth : Number) : Number {
            for (var i : Number = _nbLevel - 1; i >= 0; i--) {
                if (_bitrate[i] <= download_bandwidth) {
                    return i;
                }
            }
            return 0;
        }

        /** Update the quality level for the next fragment load. **/
        public function getnextlevel(current_level : Number, buffer : Number, last_segment_duration : Number, last_fetch_duration : Number, last_bandwidth : Number) : Number {
            if (last_fetch_duration == 0 || last_segment_duration == 0) {
                return 0;
            }

            /* rsft : remaining segment fetch time : available time to fetch next segment
            it depends on the current playback timestamp , the timestamp of the first frame of the next segment
            and TBMT, indicating a desired latency between the time instant to receive the last byte of a
            segment to the playback of the first media frame of a segment
            buffer is start time of next segment
            TBMT is the buffer size we need to ensure (we need at least 2 segments buffered */
            var rsft : Number = Math.max(0, 1000 * buffer - 2 * last_fetch_duration);
            var sftm : Number = Math.min(last_segment_duration, rsft) / last_fetch_duration;
            // Log.info("rsft:" + rsft);
            // Log.info("sftm:" + sftm);

            /* to switch level up :
            rsft should be greater than switch up condition,
             */
            if ((current_level < _nbLevel - 1) && (sftm > (1 + _switchup[current_level]))) {
                Log.debug("sftm:> 1+_switchup[_level]=" + (1 + _switchup[current_level]));
                Log.debug("switch to level " + (current_level + 1));
                // level up
                return (current_level + 1);
            }

            /* to switch level down :
            rsft should be smaller than switch up condition,
             */ else if (current_level > 0 && (sftm < 1 - _switchdown[current_level])) {
                Log.debug("sftm < 1-_switchdown[current_level]=" + _switchdown[current_level]);
                var bufferratio : Number = 1000 * buffer / last_segment_duration;
                /* find suitable level matching current bandwidth, starting from current level
                when switching level down, we also need to consider that we might need to load two fragments.
                the condition (bufferratio > 2*_levels[j].bitrate/_last_bandwidth)
                ensures that buffer time is bigger than than the time to download 2 fragments from level j, if we keep same bandwidth
                 */
                for (var j : Number = current_level - 1; j > 0; j--) {
                    if ( _bitrate[j] <= last_bandwidth && (bufferratio > 2 * _bitrate[j] / last_bandwidth)) {
                        Log.debug("switch to level " + j);
                        return j;
                    }
                }
                Log.debug("switch to level 0");
                return 0;
            }
            return current_level;
        }
    }
}