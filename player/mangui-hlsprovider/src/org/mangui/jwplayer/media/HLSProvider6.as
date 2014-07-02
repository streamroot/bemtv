package org.mangui.jwplayer.media {
    import org.mangui.HLS.parsing.Level;

    import com.longtailvideo.jwplayer.events.MediaEvent;
    import com.longtailvideo.jwplayer.model.PlayerConfig;

    import org.mangui.HLS.HLSEvent;
    import org.mangui.jwplayer.media.HLSProvider;

    /** additional method needed for jwplayer6 **/
    public class HLSProvider6 extends HLSProvider {
        /** Array of quality levels **/
        private var _qualityLevels : Array;

        private function level2label(level : Level) : String {
            if (level.name) {
                return level.name;
            } else {
                if (level.height) {
                    return(level.height + 'p / ' + Math.round(level.bitrate / 1024) + 'kb');
                } else {
                    return(Math.round(level.bitrate / 1024) + 'kb');
                }
            }
        }

        override public function initializeMediaProvider(cfg : PlayerConfig) : void {
            _stageEnabled = true;
            super.initializeMediaProvider(cfg);
            _currentQuality = 0;
        }

        /** Forward QOS metrics on fragment load. **/
        override protected function _fragmentHandler(event : HLSEvent) : void {
            super._fragmentHandler(event);
            /* only report levels if more than one available 
            update levels at each fragment load, to dynamically update auto mode label */
            if (_levels && _levels.length > 1) {
                _qualityLevels = [];

                for (var i : Number = 0; i < _levels.length; i++) {
                    _qualityLevels.push({label:level2label(_levels[i])});
                }
                var autoLabel : String = "Auto";
                if (_currentQuality == 0) {
                    autoLabel += ' (' + level2label(_levels[_level]) + ')';
                }
                _qualityLevels.unshift({label:autoLabel});
                sendQualityEvent(MediaEvent.JWPLAYER_MEDIA_LEVELS, _qualityLevels, _currentQuality);
            }
        }

        /** Change the current quality. **/
        override public function set currentQuality(quality : Number) : void {
            _hls.level = (quality - 1);
            if (!isNaN(_media_position)) {
                _hls.stream.seek(_media_position);
            }
            _currentQuality = quality;
            sendQualityEvent(MediaEvent.JWPLAYER_MEDIA_LEVEL_CHANGED, _qualityLevels, quality);
        }

        /** Return the list of quality levels. **/
        override public function get qualityLevels() : Array {
            return _qualityLevels;
        }
    }
}
