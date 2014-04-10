package org.mangui.osmf.plugins {
    import org.osmf.traits.DVRTrait;

    import flash.net.NetStream;
    import flash.media.Video;

    import org.mangui.HLS.parsing.Level;
    import org.mangui.HLS.HLS;
    import org.mangui.HLS.utils.Log;
    import org.mangui.HLS.HLSTypes;
    import org.osmf.media.LoadableElementBase;
    import org.osmf.media.MediaElement;
    import org.osmf.media.videoClasses.VideoSurface;
    import org.osmf.media.MediaResourceBase;
    import org.osmf.media.URLResource;
    import org.osmf.traits.AudioTrait;
    import org.osmf.traits.BufferTrait;
    import org.osmf.traits.LoadTrait;
    import org.osmf.traits.LoaderBase;
    import org.osmf.traits.MediaTraitType;
    import org.osmf.traits.PlayTrait;
    import org.osmf.traits.SeekTrait;
    import org.osmf.traits.TimeTrait;
    import org.osmf.utils.OSMFSettings;
    import org.osmf.net.DynamicStreamingResource;
    import org.osmf.net.DynamicStreamingItem;
    import org.osmf.net.NetStreamAudioTrait;
    import org.osmf.net.StreamType;
    import org.osmf.net.StreamingURLResource;

    public class HLSMediaElement extends LoadableElementBase {
        private var _hls : HLS;
        private var _stream : NetStream;
        private var _defaultduration : Number;
        private var videoSurface : VideoSurface;
        private var _smoothing : Boolean;
        private var _loadTrait : HLSNetStreamLoadTrait;

        public function HLSMediaElement(resource : MediaResourceBase, hls : HLS, duration : Number) {
            _hls = hls;
            _defaultduration = duration;
            super(resource, new HLSNetLoader(hls));
            initTraits();
        }

        protected function createVideo() : Video {
            return new Video();
        }

        override protected function createLoadTrait(resource : MediaResourceBase, loader : LoaderBase) : LoadTrait {
            if (_loadTrait == null) {
                _loadTrait = new HLSNetStreamLoadTrait(_hls, _defaultduration, loader, resource);
            }
            return _loadTrait;
        }

        /**
         * Specifies whether the video should be smoothed (interpolated) when it is scaled.
         * For smoothing to work, the runtime must be in high-quality mode (the default).
         * The default value is false (no smoothing).  Set this property to true to take
         * advantage of mipmapping image optimization.
         *
         * @see flash.media.Video
         *
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion OSMF 1.0
         **/
        public function get smoothing() : Boolean {
            return _smoothing;
        }

        public function set smoothing(value : Boolean) : void {
            _smoothing = value;
            if (videoSurface != null) {
                videoSurface.smoothing = value;
            }
        }

        private function initTraits() : void {
            _stream = _hls.stream;

            // Set the video's dimensions so that it doesn't appear at the wrong size.
            // We'll set the correct dimensions once the metadata is loaded.  (FM-206)
            videoSurface = new VideoSurface(OSMFSettings.enableStageVideo && OSMFSettings.supportsStageVideo, createVideo);
            videoSurface.smoothing = true;
            videoSurface.deblocking = 1;
            videoSurface.width = videoSurface.height = 0;
            videoSurface.attachNetStream(_stream);

            Log.debug("HLSMediaElement:audioTrait");
            var audioTrait : AudioTrait = new NetStreamAudioTrait(_stream);
            addTrait(MediaTraitType.AUDIO, audioTrait);

            Log.debug("HLSMediaElement:BufferTrait");
            var bufferTrait : BufferTrait = new HLSBufferTrait(_hls);
            addTrait(MediaTraitType.BUFFER, bufferTrait);

            Log.debug("HLSMediaElement:TimeTrait");
            var timeTrait : TimeTrait = new HLSTimeTrait(_hls, _defaultduration);
            addTrait(MediaTraitType.TIME, timeTrait);

            Log.debug("HLSMediaElement:DisplayObjectTrait");
            var displayObjectTrait : HLSDisplayObjectTrait = new HLSDisplayObjectTrait(videoSurface, NaN, NaN);
            addTrait(MediaTraitType.DISPLAY_OBJECT, displayObjectTrait);

            Log.debug("HLSMediaElement:PlayTrait");
            var playTrait : PlayTrait = new HLSPlayTrait(_hls);
            addTrait(MediaTraitType.PLAY, playTrait);

            // setup seek trait
            Log.debug("HLSMediaElement:SeekTrait");
            var seekTrait : SeekTrait = new HLSSeekTrait(_hls, timeTrait);
            addTrait(MediaTraitType.SEEK, seekTrait);

            var levels : Vector.<Level> = _hls.levels;
            var nbLevel : Number = levels.length;

            // retrieve stream type
            var streamType : String = (resource as StreamingURLResource).streamType;
            if (streamType == null || streamType == StreamType.LIVE_OR_RECORDED) {
                if (_hls.type == HLSTypes.LIVE) {
                    streamType = StreamType.LIVE;
                } else {
                    streamType = StreamType.RECORDED;
                }
            }

            if (nbLevel > 1) {
                var urlRes : URLResource = resource as URLResource;
                var dynamicRes : DynamicStreamingResource = new DynamicStreamingResource(urlRes.url);
                var streamItems : Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();

                for (var i : Number = 0; i < nbLevel; i++) {
                    if (levels[i].width) {
                        streamItems.push(new DynamicStreamingItem(level2label(levels[i]), levels[i].bitrate / 1024, levels[i].width, levels[i].height));
                    } else {
                        streamItems.push(new DynamicStreamingItem(level2label(levels[i]), levels[i].bitrate / 1024));
                    }
                }
                dynamicRes.streamItems = streamItems;
                dynamicRes.initialIndex = 0;
                resource = dynamicRes;
                // setup dynamic stream trait
                var dsTrait : HLSDynamicStreamTrait = new HLSDynamicStreamTrait(_hls);
                addTrait(MediaTraitType.DYNAMIC_STREAM, dsTrait);
            }

            // set Stream Type
            var streamUrlRes : StreamingURLResource = resource as StreamingURLResource;
            streamUrlRes.streamType = streamType;
            if (streamType == StreamType.DVR) {
                // add DvrTrait
                var dvrTrait : DVRTrait = new DVRTrait(true);
                addTrait(MediaTraitType.DVR, dvrTrait);
            }

            // setup drm trait
            // addTrait(MediaTraitType.DRM, drmTrait);

            // setup alternative audio trait
            Log.debug("HLSMediaElement:AlternativeAudioTrait");
            var alternateAudioTrait : HLSAlternativeAudioTrait = new HLSAlternativeAudioTrait(_hls, this as MediaElement);
            addTrait(MediaTraitType.ALTERNATIVE_AUDIO, alternateAudioTrait);
        }

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
    }
}