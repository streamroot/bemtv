package org.mangui.osmf.plugins {
    import org.osmf.traits.PlayTrait;
    import org.osmf.traits.PlayState;
    import org.mangui.HLS.HLS;
    import org.mangui.HLS.HLSEvent;
    import org.mangui.HLS.utils.*;

    public class HLSPlayTrait extends PlayTrait {
        private var _hls : HLS;
        private var streamStarted : Boolean = false;

        public function HLSPlayTrait(hls : HLS) {
            super();
            _hls = hls;
            _hls.addEventListener(HLSEvent.PLAYBACK_COMPLETE, _playbackComplete);
        }

        override protected function playStateChangeStart(newPlayState : String) : void {
            Log.info("HLSPlayTrait:playStateChangeStart:" + newPlayState);
            switch(newPlayState) {
                case PlayState.PLAYING:
                    if (streamStarted == false) {
                        _hls.stream.play();
                        streamStarted = true;
                    } else {
                        _hls.stream.resume();
                    }
                    break;
                case PlayState.PAUSED:
                    _hls.stream.pause();
                    break;
                case PlayState.STOPPED:
                    streamStarted = false;
                    _hls.stream.close();
                    break;
            }
        }

        /** playback complete handler **/
        private function _playbackComplete(event : HLSEvent) : void {
            stop();
        }
    }
}
