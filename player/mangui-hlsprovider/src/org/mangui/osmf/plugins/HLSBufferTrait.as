package org.mangui.osmf.plugins {
    import org.osmf.traits.BufferTrait;
    import org.mangui.HLS.HLS;
    import org.mangui.HLS.HLSEvent;
    import org.mangui.HLS.HLSStates;
    import org.mangui.HLS.utils.*;

    public class HLSBufferTrait extends BufferTrait {
        private var _hls : HLS;

        public function HLSBufferTrait(hls : HLS) {
            super();
            _hls = hls;
            _hls.addEventListener(HLSEvent.STATE, _stateChangedHandler);
        }

        override public function get bufferLength() : Number {
            return _hls.stream.bufferLength;
        }

        /** state changed handler **/
        private function _stateChangedHandler(event : HLSEvent) : void {
            switch(event.state) {
                case HLSStates.PLAYING_BUFFERING:
                case HLSStates.PAUSED_BUFFERING:
                    Log.debug("HLSBufferTrait:_stateChangedHandler:setBuffering(true)");
                    setBuffering(true);
                    break;
                default:
                    Log.debug("HLSBufferTrait:_stateChangedHandler:setBuffering(false)");
                    setBuffering(false);
                    break;
            }
        }
    }
}
