package org.mangui.HLS.muxing {
    import flash.utils.ByteArray;

    import org.mangui.HLS.HLSAudioTrack;
    import org.mangui.HLS.utils.Log;

    public class MP3 {
        /* MPEG1-Layer3 syncword */
        private static const SYNCWORD : uint = 0xFFFB;
        private static const RATES : Array = [44100, 48000, 32000];
        private static const BIT_RATES : Array = [0, 32000, 40000, 48000, 56000, 64000, 80000, 96000, 112000, 128000, 160000, 192000, 224000, 256000, 320000, 0];
        private static const SAMPLES_PER_FRAME : uint = 1152;

        public function MP3(data : ByteArray, callback : Function) : void {
            Log.debug("MP3: extracting MP3 tags");
            var audioTags : Vector.<Tag> = new Vector.<Tag>();
            /* parse MP3, convert Elementary Streams to TAG */
            data.position = 0;
            var id3 : ID3 = new ID3(data);
            // MP3 should contain ID3 tag filled with a timestamp
            var frames : Vector.<AudioFrame> = getFrames(data, data.position);
            var audioTag : Tag;
            var stamp : Number;
            var i : Number = 0;

            while (i < frames.length) {
                stamp = Math.round(id3.timestamp + i * 1024 * 1000 / frames[i].rate);
                audioTag = new Tag(Tag.MP3_RAW, stamp, stamp, false);
                if (i != frames.length - 1) {
                    audioTag.push(data, frames[i].start, frames[i].length);
                } else {
                    audioTag.push(data, frames[i].start, data.length - frames[i].start);
                }
                audioTags.push(audioTag);
                i++;
            }
            Log.debug("MP3: all tags extracted, callback demux");
            var audiotracks : Vector.<HLSAudioTrack> = new Vector.<HLSAudioTrack>();
            audiotracks.push(new HLSAudioTrack('MP3 ES', HLSAudioTrack.FROM_DEMUX, 0, true));
            callback(audioTags, new Vector.<Tag>(), 0, audiotracks);
        };

        public static function probe(data : ByteArray) : Boolean {
            var pos : Number = data.position;
            var id3 : ID3 = new ID3(data);
            // MP3 should contain ID3 tag filled with a timestamp
            if (id3.hasTimestamp) {
                var max_probe_pos : Number = Math.min(data.bytesAvailable, 100);
                do {
                    // Check for MP3 header
                    var short : uint = data.readUnsignedShort();
                    if (short == SYNCWORD) {
                        // rewind to sync word
                        data.position -= 2;
                        return true;
                    }
                } while (data.position < max_probe_pos);
                data.position = pos;
            }
            return false;
        }

        public static function getFrames(data : ByteArray, position : Number = 0) : Vector.<AudioFrame> {
            var frames : Vector.<AudioFrame> = new Vector.<AudioFrame>();
            var frame_start : uint;
            var frame_length : uint;
            var id3 : ID3 = new ID3(data);
            position += id3.len;
            // Get raw MP3 frames from audio stream.
            data.position = position;
            // we need at least 3 bytes, 2 for sync word, 1 for flags
            while (data.bytesAvailable > 3) {
                frame_start = data.position;
                // frame header described here : http://mpgedit.org/mpgedit/mpeg_format/MP3Format.html
                var short : uint = data.readUnsignedShort();
                if (short == SYNCWORD) {
                    var flag : uint = data.readByte();
                    // (15,12)=(&0xf0 >>4)	Bitrate index
                    var bitrate : uint = BIT_RATES[(flag & 0xf0) >> 4];
                    // (11,10)=(&0xc >> 2) Sampling rate frequency index (values are in Hz)
                    var samplerate : uint = RATES[(flag & 0xc) >> 2];
                    // (9)=(&2 >>1)  	Padding bit
                    var padbit : uint = (flag & 2) >> 1;
                    frame_length = (SAMPLES_PER_FRAME / 8) * bitrate / samplerate + padbit;
                    frame_length = Math.round(frame_length);
                    data.position = data.position + (frame_length - 3);
                    frames.push(new AudioFrame(frame_start, frame_length, frame_length, samplerate));
                } else {
                    data.position = data.position - 1;
                }
            }
            data.position = position;
            return frames;
        }
    }
}