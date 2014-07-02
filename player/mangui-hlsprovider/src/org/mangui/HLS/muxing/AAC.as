package org.mangui.HLS.muxing {
    import org.mangui.HLS.HLSAudioTrack;

    import flash.utils.ByteArray;

    import org.mangui.HLS.utils.Log;

    /** Constants and utilities for the AAC audio format. **/
    public class AAC {
        /** ADTS Syncword (111111111111), ID (MPEG4), layer (00) and protection_absent (1).**/
        private static const SYNCWORD : uint = 0xFFF1;
        /** ADTS Syncword with MPEG2 stream ID (used by e.g. Squeeze 7). **/
        private static const SYNCWORD_2 : uint = 0xFFF9;
        /** ADTS Syncword with MPEG2 stream ID (used by e.g. Envivio 4Caster). **/
        private static const SYNCWORD_3 : uint = 0xFFF8;
        /** ADTS/ADIF sample rates index. **/
        private static const RATES : Array = [96000, 88200, 64000, 48000, 44100, 32000, 24000, 22050, 16000, 12000, 11025, 8000, 7350];
        /** ADIF profile index (ADTS doesn't have Null). **/
        private static const PROFILES : Array = ['Null', 'Main', 'LC', 'SSR', 'LTP', 'SBR'];

        public function AAC(data : ByteArray, callback : Function) : void {
            Log.debug("AAC: extracting AAC tags");
            var audioTags : Vector.<Tag> = new Vector.<Tag>();
            /* parse AAC, convert Elementary Streams to TAG */
            data.position = 0;
            var id3 : ID3 = new ID3(data);
            // AAC should contain ID3 tag filled with a timestamp
            var frames : Vector.<AudioFrame> = AAC.getFrames(data, data.position);
            var adif : ByteArray = getADIF(data, 0);
            var adifTag : Tag = new Tag(Tag.AAC_HEADER, id3.timestamp, id3.timestamp, true);
            adifTag.push(adif, 0, adif.length);
            audioTags.push(adifTag);

            var audioTag : Tag;
            var stamp : Number;
            var i : Number = 0;

            while (i < frames.length) {
                stamp = Math.round(id3.timestamp + i * 1024 * 1000 / frames[i].rate);
                audioTag = new Tag(Tag.AAC_RAW, stamp, stamp, false);
                if (i != frames.length - 1) {
                    audioTag.push(data, frames[i].start, frames[i].length);
                } else {
                    audioTag.push(data, frames[i].start, data.length - frames[i].start);
                }
                audioTags.push(audioTag);
                i++;
            }
            var audiotracks : Vector.<HLSAudioTrack> = new Vector.<HLSAudioTrack>();
            audiotracks.push(new HLSAudioTrack('AAC ES', HLSAudioTrack.FROM_DEMUX, 0, true));
            Log.debug("AAC: all tags extracted, callback demux");
            callback(audioTags, new Vector.<Tag>(), 0, audiotracks);
        };

        public static function probe(data : ByteArray) : Boolean {
            var pos : Number = data.position;
            var id3 : ID3 = new ID3(data);
            // AAC should contain ID3 tag filled with a timestamp
            if (id3.hasTimestamp) {
                var max_probe_pos : Number = Math.min(data.bytesAvailable, 100);
                do {
                    // Check for ADTS header
                    var short : uint = data.readUnsignedShort();
                    if (short == SYNCWORD || short == SYNCWORD_2 || short == SYNCWORD_3) {
                        // rewind to sync word
                        data.position -= 2;
                        return true;
                    }
                } while (data.position < max_probe_pos);
                data.position = pos;
            }
            return false;
        }

        /** Get ADIF header from ADTS stream. **/
        public static function getADIF(adts : ByteArray, position : Number = 0) : ByteArray {
            adts.position = position;
            var short : uint;
            // we need at least 6 bytes, 2 for sync word, 4 for frame length
            while ((adts.bytesAvailable > 5) && (short != SYNCWORD) && (short != SYNCWORD_2) && (short != SYNCWORD_3)) {
                short = adts.readUnsignedShort();
            }

            if (short == SYNCWORD || short == SYNCWORD_2 || short == SYNCWORD_3) {
                var profile : uint = (adts.readByte() & 0xF0) >> 6;
                // Correcting zero-index of ADIF and Flash playing only LC/HE.
                if (profile > 3) {
                    profile = 5;
                } else {
                    profile = 2;
                }
                adts.position--;
                var srate : uint = (adts.readByte() & 0x3C) >> 2;
                adts.position--;
                var channels : uint = (adts.readShort() & 0x01C0) >> 6;
            } else {
                throw new Error("Stream did not start with ADTS header.");
                return null;
            }
            // 5 bits profile + 4 bits samplerate + 4 bits channels.
            var adif : ByteArray = new ByteArray();
            adif.writeByte((profile << 3) + (srate >> 1));
            adif.writeByte((srate << 7) + (channels << 3));
            if (Log.LOG_DEBUG_ENABLED) {
                Log.debug('AAC: ' + PROFILES[profile] + ', ' + RATES[srate] + ' Hz ' + channels + ' channel(s)');
            }
            // Reset position and return adif.
            adts.position -= 4;
            adif.position = 0;
            return adif;
        };

        /** Get a list with AAC frames from ADTS stream. **/
        public static function getFrames(adts : ByteArray, position : Number) : Vector.<AudioFrame> {
            var frames : Vector.<AudioFrame> = new Vector.<AudioFrame>();
            var frame_start : uint;
            var frame_length : uint;
            var id3 : ID3 = new ID3(adts);
            position += id3.len;
            // Get raw AAC frames from audio stream.
            adts.position = position;
            var samplerate : uint;
            // we need at least 6 bytes, 2 for sync word, 4 for frame length
            while (adts.bytesAvailable > 5) {
                // Check for ADTS header
                var short : uint = adts.readUnsignedShort();
                if (short == SYNCWORD || short == SYNCWORD_2 || short == SYNCWORD_3) {
                    // Store samplerate for offsetting timestamps.
                    if (!samplerate) {
                        samplerate = RATES[(adts.readByte() & 0x3C) >> 2];
                        adts.position--;
                    }
                    // Store raw AAC preceding this header.
                    if (frame_start) {
                        frames.push(new AudioFrame(frame_start, frame_length, frame_length, samplerate));
                    }
                    if (short == SYNCWORD_3) {
                        // ADTS header is 9 bytes.
                        frame_length = ((adts.readUnsignedInt() & 0x0003FFE0) >> 5) - 9;
                        frame_start = adts.position + 3;
                        adts.position += frame_length + 3;
                    } else {
                        // ADTS header is 7 bytes.
                        frame_length = ((adts.readUnsignedInt() & 0x0003FFE0) >> 5) - 7;
                        frame_start = adts.position + 1;
                        adts.position += frame_length + 1;
                    }
                } else {
                    Log.debug("no ADTS header found, probing...");
                    adts.position--;
                }
            }
            if (frame_start) {
                // check if we have a complete frame available at the end, i.e. last found frame is fitting in this PES packet
                var overflow : Number = frame_start + frame_length - adts.length;
                if (overflow <= 0 ) {
                    // no overflow, Write raw AAC after last header.
                    frames.push(new AudioFrame(frame_start, frame_length, frame_length, samplerate));
                } else {
                    Log.debug2("ADTS overflow at the end of PES packet, missing " + overflow + " bytes to complete the ADTS frame");
                }
            } else if (frames.length == 0) {
                Log.warn("No ADTS headers found in this stream.");
            }
            adts.position = position;
            return frames;
        };
    }
}