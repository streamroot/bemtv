package org.mangui.HLS {
    import org.mangui.HLS.parsing.AltAudioTrack;
    import org.mangui.HLS.parsing.Level;

    import flash.events.Event;

    /** Event fired when an error prevents playback. **/
    public class HLSEvent extends Event {
        /** Identifier for a playback complete event. **/
        public static const PLAYBACK_COMPLETE : String = "hlsEventPlayBackComplete";
        /** Identifier for a playback error event. **/
        public static const ERROR : String = "hlsEventError";
        /** Identifier for a fragment load event. **/
        public static const FRAGMENT_LOADED : String = "hlsEventFragmentLoaded";
        /** Identifier when last fragment of playlist has been loaded **/
        public static const LAST_VOD_FRAGMENT_LOADED : String = "hlsEventLastFragmentLoaded";
        /** Identifier for a manifest (re)load event. **/
        public static const MANIFEST_LOADED : String = "hlsEventManifest";
        /** Identifier for a playback media time change event. **/
        public static const MEDIA_TIME : String = "hlsEventMediaTime";
        /** Identifier for a playback state switch event. **/
        public static const STATE : String = "hlsEventState";
        /** Identifier for a quality level switch event. **/
        public static const QUALITY_SWITCH : String = "hlsEventQualitySwitch";
        /** Identifier for a level updated event (playlist loaded) **/
        public static const LEVEL_UPDATED : String = "hlsEventLevelUpdated";
        /** Identifier for a Playlist Duration updated event **/
        public static const PLAYLIST_DURATION_UPDATED : String = "hlsPlayListDurationUpdated";
        /** Identifier for a audio only fragment **/
        public static const AUDIO_ONLY : String = "audioOnly";
        /** Identifier for a audio tracks list change **/
        public static const AUDIO_TRACKS_LIST_CHANGE : String = "audioTracksListChange";
        /** Identifier for a audio track change **/
        public static const AUDIO_TRACK_CHANGE : String = "audioTrackChange";
        /** Identifier for alt audio tracks list change **/
        public static const ALT_AUDIO_TRACKS_LIST_CHANGE : String = "AltAudioTracksListChange";
        /** The current quality level. **/
        public var level : Number;
        /** The current playlist duration. **/
        public var duration : Number;
        /** The list with quality levels. **/
        public var levels : Vector.<Level>;
        /** The list with alternate audio Tracks. **/
        public var altAudioTracks : Vector.<AltAudioTrack>;
        /** The error message. **/
        public var message : String;
        /** The current QOS metrics. **/
        public var metrics : HLSMetrics;
        /** The time position. **/
        public var mediatime : HLSMediatime;
        /** The new playback state. **/
        public var state : String;
        /** The current audio track **/
        public var audioTrack : Number;

        /** Assign event parameter and dispatch. **/
        public function HLSEvent(type : String, parameter : *=null) {
            switch(type) {
                case HLSEvent.ERROR:
                    message = parameter as String;
                    break;
                case HLSEvent.FRAGMENT_LOADED:
                    metrics = parameter as HLSMetrics;
                    break;
                case HLSEvent.MANIFEST_LOADED:
                    levels = parameter as Vector.<Level>;
                    break;
                case HLSEvent.MEDIA_TIME:
                    mediatime = parameter as HLSMediatime;
                    break;
                case HLSEvent.STATE:
                    state = parameter as String;
                    break;
                case HLSEvent.QUALITY_SWITCH:
                    level = parameter as Number;
                    break;
                case HLSEvent.LEVEL_UPDATED:
                    level = parameter as Number;
                    break;
                case HLSEvent.PLAYLIST_DURATION_UPDATED:
                    duration = parameter as Number;
                    break;
                case HLSEvent.ALT_AUDIO_TRACKS_LIST_CHANGE:
                    altAudioTracks = parameter as Vector.<AltAudioTrack>;
                    break;
            }
            super(type, false, false);
        };
    }
}