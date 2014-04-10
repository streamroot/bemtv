package org.mangui.HLS.parsing {
    import org.mangui.HLS.parsing.Fragment;

    /** HLS streaming quality level. **/
    public class Level {
        /** audio only Level ? **/
        public var audio : Boolean;
        /** Level Bitrate. **/
        public var bitrate : Number;
        /** Level Name. **/
        public var name : String;
        /** video width (from playlist) **/
        public var width : Number;
        /** video height (from playlist) **/
        public var height : Number;
        /** URL of this bitrate level (for M3U8). **/
        public var url : String;
        /** Level fragments **/
        public var fragments : Vector.<Fragment>;
        /** min sequence number from M3U8. **/
        public var start_seqnum : Number;
        /** max sequence number from M3U8. **/
        public var end_seqnum : Number;
        /** target fragment duration from M3U8 **/
        public var targetduration : Number;
        /** average fragment duration **/
        public var averageduration : Number;
        /** Total duration **/
        public var duration : Number;
        /**  Audio Identifier **/
        public var audio_stream_id : String;

        /** Create the quality level. **/
        public function Level() : void {
            this.fragments = new Vector.<Fragment>();
        };

        /** Return the sequence number before a given time position. **/
        public function getSeqNumBeforePosition(position : Number) : Number {
            if (fragments[0].valid && position < fragments[0].start_time)
                return start_seqnum;

            for (var i : Number = 0; i < fragments.length; i++) {
                /* check whether fragment contains current position */
                if (fragments[i].valid && fragments[i].start_time <= position && fragments[i].start_time + fragments[i].duration > position) {
                    return (start_seqnum + i);
                }
            }
            return end_seqnum;
        };

        /** Return the sequence number from a given program date **/
        public function getSeqNumFromProgramDate(program_date : Number) : Number {
            if (program_date < fragments[0].program_date)
                return -1;

            for (var i : Number = 0; i < fragments.length; i++) {
                /* check whether fragment contains current position */
                if (fragments[i].valid && fragments[i].program_date <= program_date && fragments[i].program_date + 1000 * fragments[i].duration > program_date) {
                    return (start_seqnum + i);
                }
            }
            return -1;
        };

        /** Return the sequence number nearest a PTS **/
        public function getSeqNumNearestPTS(pts : Number, continuity : Number) : Number {
            if (fragments.length == 0)
                return -1;
            var firstIndex : Number = getFirstIndexfromContinuity(continuity);
            if (firstIndex == -1 || fragments[firstIndex].start_pts_computed == Number.NEGATIVE_INFINITY)
                return -1;
            var lastIndex : Number = getLastIndexfromContinuity(continuity);

            for (var i : Number = firstIndex; i <= lastIndex; i++) {
                /* check nearest fragment */
                if ( fragments[i].valid && (Math.abs(fragments[i].start_pts_computed - pts) < Math.abs(fragments[i].start_pts_computed + 1000 * fragments[i].duration - pts))) {
                    return fragments[i].seqnum;
                }
            }
            // requested PTS above max PTS of this level
            return Number.POSITIVE_INFINITY;
        };

        public function getLevelstartPTS() : Number {
            if (fragments.length)
                return fragments[0].start_pts_computed;
            else
                return Number.NEGATIVE_INFINITY;
        }

        /** Return the fragment index from fragment sequence number **/
        public function getFragmentfromSeqNum(seqnum : Number) : Fragment {
            var index : Number = getIndexfromSeqNum(seqnum);
            if (index != -1) {
                return fragments[index];
            } else {
                return null;
            }
        }

        /** Return the fragment index from fragment sequence number **/
        private function getIndexfromSeqNum(seqnum : Number) : Number {
            if (seqnum >= start_seqnum && seqnum <= end_seqnum) {
                return (fragments.length - 1 - (end_seqnum - seqnum));
            } else {
                return -1;
            }
        }

        /** Return the first index matching with given continuity counter **/
        private function getFirstIndexfromContinuity(continuity : Number) : Number {
            // look for first fragment matching with given continuity index
            for (var i : Number = 0; i < fragments.length; i++) {
                if (fragments[i].continuity == continuity)
                    return i;
            }
            return -1;
        }

        /** Return the first seqnum matching with given continuity counter **/
        public function getFirstSeqNumfromContinuity(continuity : Number) : Number {
            var index : Number = getFirstIndexfromContinuity(continuity);
            if (index == -1) {
                return Number.NEGATIVE_INFINITY;
            }
            return fragments[index].seqnum;
        }

        /** Return the last seqnum matching with given continuity counter **/
        public function getLastSeqNumfromContinuity(continuity : Number) : Number {
            var index : Number = getLastIndexfromContinuity(continuity);
            if (index == -1) {
                return Number.NEGATIVE_INFINITY;
            }
            return fragments[index].seqnum;
        }

        /** Return the last index matching with given continuity counter **/
        private function getLastIndexfromContinuity(continuity : Number) : Number {
            var firstIndex : Number = getFirstIndexfromContinuity(continuity);
            if (firstIndex == -1)
                return -1;

            var lastIndex : Number = firstIndex;
            // look for first fragment matching with given continuity index
            for (var i : Number = firstIndex; i < fragments.length; i++) {
                if (fragments[i].continuity == continuity)
                    lastIndex = i;
                else
                    break;
            }
            return lastIndex;
        }

        /** set Fragments **/
        public function updateFragments(_fragments : Vector.<Fragment>) : void {
            var idx_with_pts : Number = -1;
            var len : Number = _fragments.length;
            var frag : Fragment;
            // update PTS from previous fragments
            for (var i : Number = 0; i < len; i++) {
                frag = getFragmentfromSeqNum(_fragments[i].seqnum);
                if (frag != null && frag.start_pts != Number.NEGATIVE_INFINITY) {
                    _fragments[i].start_pts = frag.start_pts;
                    _fragments[i].duration = frag.duration;
                    idx_with_pts = i;
                }
            }
            updateFragmentsProgramDate(_fragments);

            fragments = _fragments;
            start_seqnum = _fragments[0].seqnum;
            end_seqnum = _fragments[len - 1].seqnum;

            if (idx_with_pts != -1) {
                // if at least one fragment contains PTS info, recompute PTS information for all fragments
                updateFragment(fragments[idx_with_pts].seqnum, true, fragments[idx_with_pts].start_pts, fragments[idx_with_pts].start_pts + 1000 * fragments[idx_with_pts].duration);
            } else {
                duration = _fragments[len - 1].start_time + _fragments[len - 1].duration;
            }
            averageduration = duration / len;
        }

        private function updateFragmentsProgramDate(_fragments : Vector.<Fragment>) : void {
            var len : Number = _fragments.length;
            var continuity : Number;
            var program_date : Number;
            var frag : Fragment;
            for (var i : Number = 0; i < len; i++) {
                frag = _fragments[i];
                if (frag.continuity != continuity) {
                    continuity = frag.continuity;
                    program_date = 0;
                }
                if (frag.program_date) {
                    program_date = frag.program_date + 1000 * frag.duration;
                } else if (program_date) {
                    frag.program_date = program_date;
                }
            }
        }

        private function _updatePTS(from_index : Number, to_index : Number) : void {
            // Log.info("updateFragmentPTS from/to:" + from_index + "/" + to_index);
            var frag_from : Fragment = fragments[from_index];
            var frag_to : Fragment = fragments[to_index];

            if (frag_from.valid && frag_to.valid) {
                if (frag_to.start_pts != Number.NEGATIVE_INFINITY) {
                    // we know PTS[to_index]
                    frag_to.start_pts_computed = frag_to.start_pts;
                    // update duration to fix drifts between playlist and fragment
                    if (to_index > from_index)
                        frag_from.duration = Math.max(0,(frag_to.start_pts - frag_from.start_pts_computed) / 1000);
                    else
                        frag_to.duration = Math.max(0,(frag_from.start_pts_computed - frag_to.start_pts) / 1000);
                } else {
                    // we dont know PTS[to_index]
                    if (to_index > from_index)
                        frag_to.start_pts_computed = frag_from.start_pts_computed + 1000 * frag_from.duration;
                    else
                        frag_to.start_pts_computed = frag_from.start_pts_computed - 1000 * frag_to.duration;
                }
            }
        }

        public function updateFragment(seqnum : Number, valid : Boolean, min_pts : Number = 0, max_pts : Number = 0) : Number {
            // Log.info("updatePTS : seqnum/min/max:" + seqnum + '/' + min_pts + '/' + max_pts);
            // get fragment from seqnum
            var fragIdx : Number = getIndexfromSeqNum(seqnum);
            if (fragIdx != -1) {
                var frag : Fragment = fragments[fragIdx];
                // update fragment start PTS + duration
                if (valid) {
                    frag.start_pts = min_pts;
                    frag.start_pts_computed = min_pts;
                    frag.duration = (max_pts - min_pts) / 1000;
                } else {
                    frag.duration = 0;
                }
                frag.valid = valid;
                // Log.info("SN["+fragments[fragIdx].seqnum+"]:pts/duration:" + fragments[fragIdx].start_pts_computed + "/" + fragments[fragIdx].duration);

                // adjust fragment PTS/duration from seqnum-1 to frag 0
                for (var i : Number = fragIdx; i > 0 && fragments[i - 1].continuity == frag.continuity; i--) {
                    _updatePTS(i, i - 1);
                    // Log.info("SN["+fragments[i-1].seqnum+"]:pts/duration:" + fragments[i-1].start_pts_computed + "/" + fragments[i-1].duration);
                }

                // adjust fragment PTS/duration from seqnum to last frag
                for (i = fragIdx; i < fragments.length - 1 && fragments[i + 1].continuity == frag.continuity; i++) {
                    _updatePTS(i, i + 1);
                    // Log.info("SN["+fragments[i+1].seqnum+"]:pts/duration:" + fragments[i+1].start_pts_computed + "/" + fragments[i+1].duration);
                }

                // second, adjust fragment offset
                var start_time_offset : Number = fragments[0].start_time;
                for (i = 0; i < fragments.length; i++) {
                    fragments[i].start_time = start_time_offset;
                    start_time_offset += fragments[i].duration;
                    // Log.info("SN["+fragments[i].seqnum+"]:start_time/continuity/pts/duration:" + fragments[i].start_time + "/" + fragments[i].continuity + "/"+ fragments[i].start_pts_computed + "/" + fragments[i].duration);
                }
                duration = start_time_offset;
                return frag.start_time;
            } else {
                return 0;
            }
        }
    }
}