package org.mangui.HLS.muxing {
    import org.mangui.HLS.muxing.*;
    import org.mangui.HLS.utils.Log;
    import org.mangui.HLS.HLSAudioTrack;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.ByteArray;
    import flash.utils.Timer;

    /** Representation of an MPEG transport stream. **/
    public class TS extends EventDispatcher {
        /** TS Sync byte. **/
        private static const SYNCBYTE : uint = 0x47;
        /** TS Packet size in byte. **/
        private static const PACKETSIZE : uint = 188;
        /** loop counter to avoid blocking **/
        private static const COUNT : uint = 5000;
        /** Packet ID of the PAT (is always 0). **/
        private static const _patId : Number = 0;
        /** Packet ID of the SDT (is always 17). **/
        private static const _sdtId : Number = 17;
        /** has PAT been parsed ? **/
        private var _patParsed : Boolean = false;
        /** has PMT been parsed ? **/
        private var _pmtParsed : Boolean = false;
        /** any TS packets before PMT ? **/
        private var _packetsBeforePMT : Boolean = false;
        /** Packet ID of the Program Map Table. **/
        private var _pmtId : Number = -1;
        /** Packet ID of the video stream. **/
        private var _avcId : Number = -1;
        /** Packet ID of selected audio stream. **/
        private static var _audioId : Number = -1;
        private var _audioIsAAC : Boolean = false;
        /** should we extract audio ? **/
        private var _audioExtract : Boolean;
        /** List of AAC and MP3 audio PIDs */
        private var _aacIds : Vector.<uint> = new Vector.<uint>();
        private var _mp3Ids : Vector.<uint> = new Vector.<uint>();
        /** List with audio frames. **/
        private var _audioTags : Vector.<Tag> = new Vector.<Tag>();
        /** List with video frames. **/
        private var _videoTags : Vector.<Tag> = new Vector.<Tag>();
        /** Timer for reading packets **/
        private var _timer : Timer;
        /** Byte data to be read **/
        private var _data : ByteArray;
        /* callback function upon read complete */
        private var _callback : Function;
        /* current audio binary data */
        private static var _curAudioData : ByteArray = null;
        /* current video binary data */
        private static var _curVideoData : ByteArray = null;
        /* ADTS overflowing data */
        private static var _adtsOverflowData : ByteArray = null;
        /* current AVC Tag */
        private var _curVideoTag : Tag;


        public static function probe(data : ByteArray) : Boolean {
            var pos : Number = data.position;
            var len : Number = Math.min(data.bytesAvailable, 188 * 2);
            for (var i : Number = 0; i < len; i++) {
                if (data.readByte() == SYNCBYTE) {
                    // ensure that at least two consecutive TS start offset are found
                    if (data.bytesAvailable > 188) {
                        data.position = pos + i + 188;
                        if (data.readByte() == SYNCBYTE) {
                            data.position = pos + i;
                            return true;
                        } else {
                            data.position = pos + i + 1;
                        }
                    }
                }
            }
            data.position = pos;
            return false;
        }

        /** Transmux the M2TS file into an FLV file. **/
        public function TS(data : ByteArray, callback : Function, discontinuity : Boolean, audioExtract : Boolean, audioPID : Number) {
            // in case of discontinuity, flush any partially parsed audio/video PES packet
            if (discontinuity) {
                _curAudioData = null;
                _curVideoData = null;
                _adtsOverflowData = null;
            } else {
                // in case there is no discontinuity, but audio PID change, flush any partially parsed audio PES packet
                if (_audioExtract && audioPID != _audioId) {
                    _curAudioData = null;
                    _adtsOverflowData = null;
                }
            }
            // Extract the elementary streams.
            _data = data;
            _callback = callback;
            _audioId = audioPID;
            _audioExtract = audioExtract;
            _timer = new Timer(0, 0);
            _timer.addEventListener(TimerEvent.TIMER, _readData);
            _timer.start();
        };

        /** append new TS data */
        // public function appendData(newData:ByteArray):void {
        // newData.readBytes(_data,_data.length);
        // _timer.start();
        // }
        /** Read a small chunk of packets each time to avoid blocking **/
        private function _readData(e : Event) : void {
            var i : uint = 0;
            while (_data.bytesAvailable && i < COUNT) {
                _readPacket();
                i++;
            }
            // finish reading TS fragment
            if (!_data.bytesAvailable) {
                // first check if TS parsing was successful
                if (_pmtParsed == false) {
                    Log.error("TS: no PMT found, report parsing error");
                    _callback(null, null, null, null);
                } else {
                    _timer.stop();
                    _parsingEnd();
                }
            }
        }

        /** notify end of parsing **/
        private function _parsingEnd() : void {
            // check whether last parsed audio PES is complete
            if (_curAudioData && _curAudioData.length > 14) {
                var pes : PES = new PES(TS._curAudioData, true);
                if (pes.len && (pes.data.length - pes.payload - pes.payload_len) >= 0) {
                    Log.debug2("complete Audio PES found at end of segment, parse it");
                    // complete PES, parse and push into the queue
                    if (_audioIsAAC) {
                        _parseADTSPES(pes);
                    } else {
                        _parseMPEGPES(pes);
                    }
                    _curAudioData = null;
                } else {
                    Log.debug("partial AAC PES at end of segment");
                    _curAudioData.position = _curAudioData.length;
                }
            }
            // check whether last parsed video PES is complete
            if (_curVideoData && _curVideoData.length > 14) {
                pes = new PES(TS._curVideoData, false);
                if (pes.len && (pes.data.length - pes.payload - pes.payload_len) >= 0) {
                    Log.debug2("complete AVC PES found at end of segment, parse it");
                    // complete PES, parse and push into the queue
                    _parseAVCPES(pes);
                    _curVideoData = null;
                } else {
                    Log.debug("partial AVC PES at end of segment");
                    _curVideoData.position = _curVideoData.length;
                }
            }
            Log.debug("TS: successfully parsed");
            // report current audio track and audio track list
            var audioList : Vector.<HLSAudioTrack> = new Vector.<HLSAudioTrack>();
            if (_audioId > 0) {
                var isDefault : Boolean = true;
                for (var i : Number = 0; i < _aacIds.length; ++i) {
                    audioList.push(new HLSAudioTrack('TS/AAC ' + i, HLSAudioTrack.FROM_DEMUX, _aacIds[i], isDefault));
                    if (isDefault)
                        isDefault = false;
                }
                for (i = 0; i < _mp3Ids.length; ++i) {
                    audioList.push(new HLSAudioTrack('TS/MP3 ' + i, HLSAudioTrack.FROM_DEMUX, _mp3Ids[i], isDefault));
                    if (isDefault)
                        isDefault = false;
                }
            }
            Log.debug("TS: " + _videoTags.length + " video tags extracted");
            Log.debug("TS: " + _audioTags.length + " audio tags extracted");
            _callback(_audioTags, _videoTags, _audioId, audioList);
        }

        /** parse ADTS audio PES packet **/
        private function _parseADTSPES(pes : PES) : void {
            var stamp : Number;
            // check if previous ADTS frame was overflowing.
            if (_adtsOverflowData && _adtsOverflowData.length) {
                // if overflowing, append remaining data from previous frame at the beginning of PES packet
                Log.debug("AAC:append overflowing " + _adtsOverflowData.length + " bytes to beginning of new PES packet");
                var ba : ByteArray = new ByteArray();
                ba.writeBytes(_adtsOverflowData);
                ba.writeBytes(pes.data, pes.payload);
                pes.data = ba;
                pes.payload = 0;
                _adtsOverflowData = null;
            }
            if (isNaN(pes.pts)) {
                Log.warn("AAC:no PTS info in this PES packet,discarding it");
                return;
            }
            // insert ADIF TAG at the beginning
            if (_audioTags.length == 0) {
                var adifTag : Tag = new Tag(Tag.AAC_HEADER, pes.pts, pes.dts, true);
                var adif : ByteArray = AAC.getADIF(pes.data, pes.payload);
                Log.debug("AAC: insert ADIF TAG");
                adifTag.push(adif, 0, adif.length);
                _audioTags.push(adifTag);
            }
            // Store ADTS frames in array.
            var frames : Vector.<AudioFrame> = AAC.getFrames(pes.data, pes.payload);
            var frame : AudioFrame;
            for (var j : Number = 0; j < frames.length; j++) {
                frame = frames[j];
                // Increment the timestamp of subsequent frames.
                stamp = Math.round(pes.pts + j * 1024 * 1000 / frame.rate);
                var curAudioTag : Tag = new Tag(Tag.AAC_RAW, stamp, stamp, false);
                curAudioTag.push(pes.data, frame.start, frame.length);
                _audioTags.push(curAudioTag);
            }
            if (frame) {
                // check if last ADTS frame is overflowing on next PES packet
                var adts_overflow:Number = pes.data.length - (frame.start + frame.length);
                if (adts_overflow) {
                    _adtsOverflowData = new ByteArray();
                    _adtsOverflowData.writeBytes(pes.data, frame.start + frame.length);
                    Log.debug("AAC:ADTS frame overflow:" + adts_overflow);
                }
            }
        };

        /** parse MPEG audio PES packet **/
        private function _parseMPEGPES(pes : PES) : void {
            if (isNaN(pes.pts)) {
                Log.warn("no PTS info in this MP3 PES packet,discarding it");
                return;
            }
            var tag : Tag = new Tag(Tag.MP3_RAW, pes.pts, pes.dts, false);
            tag.push(pes.data, pes.payload, pes.data.length - pes.payload);
            _audioTags.push(tag);
        };

        /** parse AVC PES packet **/
        private function _parseAVCPES(pes : PES) : void {
            var sps : ByteArray;
            var pps : ByteArray;
            var sps_found : Boolean = false;
            var pps_found : Boolean = false;
            var units : Vector.<VideoFrame> = AVC.getNALU(pes.data, pes.payload);
            // If there's no NAL unit, push all data in the previous tag, if any exists
            if (!units.length) {
                if (_curVideoTag) {
                    _curVideoTag.push(pes.data, pes.payload, pes.data.length - pes.payload);
                } else {
                    Log.warn("no NAL unit found in first (?) video PES packet, discarding data. possible segmentation issue ?");
                }
                return;
            }
            // If NAL units are not starting right at the beginning of the PES packet, push preceding data into the previous tag.
            var overflow : Number = units[0].start - units[0].header - pes.payload;
            if (overflow && _curVideoTag) {
                _curVideoTag.push(pes.data, pes.payload, overflow);
            }
            if (isNaN(pes.pts)) {
                Log.warn("no PTS info in this AVC PES packet,discarding it");
                return;
            }
            _curVideoTag = new Tag(Tag.AVC_NALU, pes.pts, pes.dts, false);
            // Only push NAL units 1 to 5 into tag.
            for (var j : Number = 0; j < units.length; j++) {
                if (units[j].type < 6) {
                    _curVideoTag.push(pes.data, units[j].start, units[j].length);
                    // Unit type 5 indicates a keyframe.
                    if (units[j].type == 5) {
                        _curVideoTag.keyframe = true;
                    }
                } else if (units[j].type == 7) {
                    sps_found = true;
                    sps = new ByteArray();
                    pes.data.position = units[j].start;
                    pes.data.readBytes(sps, 0, units[j].length);
                } else if (units[j].type == 8) {
                    pps_found = true;
                    pps = new ByteArray();
                    pes.data.position = units[j].start;
                    pes.data.readBytes(pps, 0, units[j].length);
                }
            }
            if (sps_found && pps_found) {
                var avcc : ByteArray = AVC.getAVCC(sps, pps);
                var avccTag : Tag = new Tag(Tag.AVC_HEADER, pes.pts, pes.dts, true);
                avccTag.push(avcc, 0, avcc.length);
                _videoTags.push(avccTag);
            }
            _videoTags.push(_curVideoTag);
        }

        /** Read TS packet. **/
        private function _readPacket() : void {
            // Each packet is 188 bytes.
            var todo : uint = TS.PACKETSIZE;
            // Sync byte.
            if (_data.readByte() != TS.SYNCBYTE) {
                var pos : Number = _data.position;
                if (probe(_data) == true) {
                    Log.warn("lost sync in TS, between offsets:" + pos + "/" + _data.position);
                    _data.position++;
                } else {
                    throw new Error("Could not parse TS file: sync byte not found @ offset/len " + _data.position + "/" + _data.length);
                }
            }
            todo--;
            // Payload unit start indicator.
            var stt : uint = (_data.readUnsignedByte() & 64) >> 6;
            _data.position--;

            // Packet ID (last 13 bits of UI16).
            var pid : uint = _data.readUnsignedShort() & 8191;
            // Check for adaptation field.
            todo -= 2;
            var atf : uint = (_data.readByte() & 48) >> 4;
            todo--;
            // Read adaptation field if available.
            if (atf > 1) {
                // Length of adaptation field.
                var len : uint = _data.readUnsignedByte();
                todo--;
                // Random access indicator (keyframe).
                // var rai:uint = data.readUnsignedByte() & 64;
                _data.position += len;
                todo -= len;
                // Return if there's only adaptation field.
                if (atf == 2 || len == 183) {
                    _data.position += todo;
                    return;
                }
            }

            // Parse the PES, split by Packet ID.
            switch (pid) {
                case _patId:
                    todo -= _readPAT(stt);
                    if (_patParsed == false) {
                        _patParsed = true;
                        Log.debug("TS: PAT found.PMT PID:" + _pmtId);
                    }
                    break;
                case _pmtId:
                    todo -= _readPMT(stt);
                    if (_pmtParsed == false) {
                        _pmtParsed = true;
                        Log.debug("TS: PMT found.AVC,Audio PIDs:" + _avcId + "," + _audioId);
                        // if PMT was not parsed before, and some unknown packets have been skipped in between,
                        // rewind to beginning of the stream, it helps recovering bad segmented content
                        // in theory there should be no A/V packets before PAT/PMT)
                        if (_packetsBeforePMT) {
                            Log.warn("late PMT found, rewinding at beginning of TS");
                            _data.position = 0;
                            return;
                        }
                    }
                    break;
                case _audioId:
                    if (_pmtParsed == false) {
                        break;
                    }
                    if (stt) {
                        if (_curAudioData) {
                            if (_audioIsAAC) {
                                _parseADTSPES(new PES(_curAudioData, true));
                            } else {
                                _parseMPEGPES(new PES(_curAudioData, true));
                            }
                        }
                        _curAudioData = new ByteArray();
                    }
                    if (_curAudioData) {
                        _curAudioData.writeBytes(_data, _data.position, todo);
                    } else {
                        Log.warn("Discarding TS audio packet with id " + pid);
                    }
                    break;
                case _avcId:
                    if (_pmtParsed == false) {
                        break;
                    }
                    if (stt) {
                        if (_curVideoData) {
                            _parseAVCPES(new PES(_curVideoData, false));
                        }
                        _curVideoData = new ByteArray();
                    }
                    if (_curVideoData) {
                        _curVideoData.writeBytes(_data, _data.position, todo);
                    } else {
                        Log.warn("Discarding TS video packet with id " + pid + " bad TS segmentation ?");
                    }
                    break;
                case _sdtId:
                    break;
                default:
                    _packetsBeforePMT = true;
                    break;
            }
            // Jump to the next packet.
            _data.position += todo;
        };

        /** Read the Program Association Table. **/
        private function _readPAT(stt : uint) : Number {
            var pointerField : uint = 0;
            if (stt) {
                pointerField = _data.readUnsignedByte();
                // skip alignment padding
                _data.position += pointerField;
            }
            // skip table id
            _data.position += 1;
            // get section length
            var sectionLen : uint = _data.readUnsignedShort() & 0x3FF;
            // Check the section length for a single PMT.
            if (sectionLen > 13) {
                throw new Error("Multiple PMT entries are not supported.");
            }
            // Grab the PMT ID.
            _data.position += 7;
            _pmtId = _data.readUnsignedShort() & 8191;
            return 13 + pointerField;
        };

        /** Read the Program Map Table. **/
        private function _readPMT(stt : uint) : Number {
            var pointerField : uint = 0;

            // reset audio tracks
            var audioFound : Boolean = false;
            _aacIds = new Vector.<uint>();
            _mp3Ids = new Vector.<uint>();

            if (stt) {
                pointerField = _data.readUnsignedByte();
                // skip alignment padding
                _data.position += pointerField;
            }
            // skip table id
            _data.position += 1;
            // Check the section length for a single PMT.
            var len : uint = _data.readUnsignedShort() & 0x3FF;
            var read : uint = 13;
            _data.position += 7;
            // skip program info
            var pil : uint = _data.readUnsignedShort() & 0x3FF;
            _data.position += pil;
            read += pil;
            // Loop through the streams in the PMT.
            while (read < len) {
                // stream type
                var typ : uint = _data.readByte();
                // stream pid
                var sid : uint = _data.readUnsignedShort() & 0x1fff;
                if (typ == 0x0F) {
                    // ISO/IEC 13818-7 ADTS AAC (MPEG-2 lower bit-rate audio)
                    _aacIds.push(sid);
                    if (sid == _audioId) {
                        audioFound = true;
                        _audioIsAAC = true;
                    }
                } else if (typ == 0x1B) {
                    // ITU-T Rec. H.264 and ISO/IEC 14496-10 (lower bit-rate video)
                    _avcId = sid;
                } else if (typ == 0x03 || typ == 0x04) {
                    // ISO/IEC 11172-3 (MPEG-1 audio)
                    // or ISO/IEC 13818-3 (MPEG-2 halved sample rate audio)
                    _mp3Ids.push(sid);
                    if (sid == _audioId) {
                        audioFound = true;
                    }
                }
                // es_info_length
                var sel : uint = _data.readUnsignedShort() & 0xFFF;
                _data.position += sel;
                // loop to next stream
                read += sel + 5;
            }
            if (_audioId <= 0 || !audioFound) {
                if (_audioExtract) {
                    // automatically select audio track
                    Log.debug("Found " + _aacIds.length + " AAC tracks");
                    Log.debug("Found " + _mp3Ids.length + " MP3 tracks");
                    if (_aacIds.length > 0) {
                        _audioId = _aacIds[0];
                        _audioIsAAC = true;
                    } else if (_mp3Ids.length > 0) {
                        _audioId = _mp3Ids[0];
                        _audioIsAAC = false;
                    }
                    Log.debug("Selected audio PID: " + _audioId);
                }
            }
            return len + pointerField;
        };
    }
}