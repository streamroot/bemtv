package org.mangui.osmf.plugins {
    import org.osmf.traits.SeekTrait;
    import org.osmf.traits.TimeTrait;
    import org.mangui.HLS.HLS;
    import org.mangui.HLS.HLSStates;
    import org.mangui.HLS.HLSEvent;
    import org.mangui.HLS.utils.*;

    public class HLSSeekTrait extends SeekTrait {
        private var _hls : HLS;

        public function HLSSeekTrait(hls : HLS, timeTrait : TimeTrait) {
            super(timeTrait);
            _hls = hls;
            _hls.addEventListener(HLSEvent.STATE, _stateChangedHandler);
        }

        /**
         * @private
         * Communicates a <code>seeking</code> change to the media through the NetStream. 
         * @param newSeeking New <code>seeking</code> value.
         * @param time Time to seek to, in seconds.
         */
        override protected function seekingChangeStart(newSeeking : Boolean, time : Number) : void {
            if (newSeeking) {
                Log.info("HLSSeekTrait:seekingChangeStart(newSeeking/time):(" + newSeeking  + "/" + time + ")");
                _hls.stream.seek(time);
            }
            super.seekingChangeStart(newSeeking, time);
        }

        /** state changed handler **/
        private function _stateChangedHandler(event : HLSEvent) : void {
            if (seeking && (event.state != HLSStates.PAUSED_BUFFERING && event.state != HLSStates.PLAYING_BUFFERING)) {
                Log.debug("HLSSeekTrait:setSeeking(false);");
                setSeeking(false, timeTrait.currentTime);
            }
        }
    }
}