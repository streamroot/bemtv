package org.mangui.HLS {
    /** Audio Track identifier **/
    public class HLSAudioTrack {
        public static const FROM_DEMUX : Number = 0;
        public static const FROM_PLAYLIST : Number = 1;
        public var title : String;
        public var id : Number;
        public var source : Number;
        public var isDefault : Boolean;

        public function HLSAudioTrack(title : String, source : Number, id : Number, isDefault : Boolean) {
            this.title = title;
            this.source = source;
            this.id = id;
            this.isDefault = isDefault;
        }

        public function toString() : String {
            return "HLSAudioTrack ID: " + id + " Title: " + title + " Source: " + source + " Default: " + isDefault;
        }
    }
}