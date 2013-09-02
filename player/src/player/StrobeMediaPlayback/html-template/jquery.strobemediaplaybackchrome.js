/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
*  (the "License"); you may not use this file except in
*  compliance with the License. 
* 
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

/**
 * 
 */
(function($, undefined){ 	
	/**
     *
     */
    var StrobeMediaPlaybackChrome = function(element, options){
        this.$window = $(window);
        this.$document = $(document);
		this.element = element;
        this.$element = $(element);
        this.options = $.extend({}, $.fn.strobemediaplaybackchrome.defaults, options);
    };
    
    
    var strobeMediaPlaybackChromeMethods = {
        initialize: function(){
            if (!this.options.javascriptControls) {
                this.$element.find(".strobeMediaPlaybackControlBar,.smp-error,.playoverlay").hide();
                return;
            }
            
            this.$player = this.$element; //$("#" + this.options.id)
            this.player = this.element; //this.$player.get(0);
			            
//409             // TODO: Encapsulate this in a dedicated class
//410             if (!this.options.useHTML5) {
//411             
//412                 this.monitor = new VideoElementMonitor(this.$player);
//413                 this.$player.data("videoElement", this.monitor.$videoElement);
//414                 this.player = this.monitor.videoElement;
//415                 this.$player = this.monitor.$videoElement;                
//416                 org.strobemediaplayback.proxied[this.options.id] = this.monitor;             
//417                 monitorChanges(this.monitor);
//418             }    
 
            this.sliding = false;
            this.$element = $("#strobemediaplayback");
            this.playOverlay = this.$element.find('.playoverlay');
            this.play = this.$element.find('.smp.play');
            this.mute = this.$element.find('.smp.volume');
            this.time = this.$element.find('.time');
            this.currentTimeLabel = this.$element.find('.currentTime');
            this.durationLabel = this.$element.find('.duration');
            this.errorOverlay = this.$element.find('.smp-error');
            this.fullscreen = this.$element.find('.fullscreen');
            
            this.play.bind('click', this, this.onPlayClick);
            this.playOverlay.bind('click', this, this.onPlayClick);
            this.mute.bind('click', this, this.onMuteClick);
            this.fullscreen.bind('click', this, this.onFullScreenClick);
            
            this.$player.bind("play", this, this.onPlay);
            this.$player.bind("pause", this, this.onPause);
            this.$player.bind("volumechange", this, this.onVolumeChange);
            this.$player.bind("durationchange", this, this.onDurationChange);
            this.$player.bind("timeupdate", this, this.onTimeUpdate);
            this.$player.bind("waiting", this, this.onWaiting);
            this.$player.bind("seeking", this, this.onSeeking);
            this.$player.bind("seeked", this, this.onSeeked);
            this.$player.bind("ended", this, this.onPause);
            this.$player.bind("error", this, this.onError);
            this.$player.bind("progress", this, this.onProgress);            
            
            this.timeTrack = this.$element.find(".video-track");
            this.slider = this.$element.find(".slider");
            this.played = this.$element.find(".played");
            this.buffered = this.$element.find(".buffered");
            
            this.slider.bind("mousedown", this, this.onSliderMouseDown);
            this.slider.bind("touchstart", this, this.onSliderMouseDown);
            
            // Keep here for further experimentation
            //this.slider.bind("touchmove", this, this.onTouchMove);
            
            this.timeTrack.bind('mousedown', this, this.onTimeTrackClick);
            
            this.$window.bind("orientationchange", this, this.onOrinetationChangeOrResize);
            this.$window.bind("resize", this, this.onOrinetationChangeOrResize);
            
            if (options.disabledControls) {
                this.$element.find(options.disabledControls).addClass("disabled");
            }
            
            this.isFullScreen = false;
            this.layoutControlBar(this.options.width, this.options.height);
        },
        
        onSliderMouseDown: function(event){
            var duration, time, player;
            if (!event.data.sliding) {
                event.preventDefault();
                
                // TODO: Move the sliding code into a special widget
                player = event.data.player;
                event.data.sliding = true;
                duration = player.duration;
                event.data.onProgress(event);
                var timeTrack = event.data.timeTrack;
                var slider = event.data.slider;
                
                var moveTarget = event.data.$document;
                moveTarget.bind("mousemove", event.data, onMouseMove);
                moveTarget.bind("touchmove", event.data, onMouseMove);
                
                moveTarget.bind("mouseup", event.data, onMouseUp);
                moveTarget.bind("touchend", event.data, onMouseUp);
                
                moveTarget.bind("touchcancel", event.data, onTouchCancel);
                
            }
            
            function onMouseMove(event){
                event.preventDefault();
                var timeTrackWidth = event.data.timeTrack.outerWidth();
                var offsetLeft = event.data.timeTrack.offset().left;
                var x = event.clientX;
                var originalEvent = event.originalEvent;
                if (typeof x == 'undefined' && originalEvent && originalEvent.touches && originalEvent.touches.length > 0) {
                    x = originalEvent.touches[0].pageX;
                }
                var relativePosition = (x - offsetLeft) / (timeTrackWidth);
                
                time = duration * relativePosition;
                if (time < duration && time > 0) {
                
                    var timePercent = (Math.max(0, time) / duration * 100);
                    event.data.slider.css({
                        "left": timePercent + "%"
                    });
                    
                    event.data.played.css({
                        "width": timePercent + "%"
                    });
                    event.data.seekTime = time;
                    event.data.onProgress(event);
                }
                
            };
            
            function onMouseUp(event){
                moveTarget.unbind("mousemove");
                moveTarget.unbind("touchmove");
                
                moveTarget.unbind("mouseup");
                moveTarget.unbind("touchend");
                
                if (time > 0) {
                    event.data.seekTime = 0;
                    player.currentTime = time;
                }
                event.data.sliding = false;
            };
            
            function onTouchCancel(event){
                event.data.seekTime = 0;
                event.data.sliding = false;
            };
        },
        
        onOrinetationChangeOrResize: function(event){
            event.data.layoutControlBar(event.data.options.width, event.data.options.height);
        },
        
        onPlayClick: function(event){
            var player = event.data.player;
            
            if (player.paused) {
                player.play();
            }
            else {
                player.pause();
            }
        },
        
        onMuteClick: function(event){
            var player = event.data.player;
            player.muted = !player.muted;
        },
        
        onFullScreenClick: function(event){
            event.data.$element.parent().toggleClass("fullscreen-mode");
        },
        
        onTimeTrackClick: function(event){
            var duration = event.data.player.duration;
            var timeTrackWidth = event.data.timeTrack.outerWidth();
            var offsetLeft = event.data.timeTrack.offset().left;
            var relativePosition = (event.clientX - offsetLeft) / (timeTrackWidth);
            
            var time = duration * relativePosition;            
            
            if (time > 0) {
                event.data.player.currentTime = time;
            }
            
            
            $("#seekDebug").html("clientX=" + event.clientX + " width=" + timeTrackWidth + " duration=" + duration + " time=" + time);
        },
        
        onPlay: function(event){
            event.data.errorOverlay.hide();
            event.data.play.removeClass("play").addClass("pause");
            if (event.data.useHTML5 &&
            event.data.options.hasOwnProperty("playButtonOverlay") &&
            event.data.options.playButtonOverlay) {
                event.data.playOverlay.fadeOut(600);
            }
        },
        
        onPause: function(event){
            event.data.play.removeClass("pause").addClass("play");
            if (event.data.useHTML5 && event.data.options.playButtonOverlay) {
                event.data.playOverlay.fadeIn(600);
            }
        },
        
        onWaiting: function(event){
            // $("#debug").append("BUFFERING");
            event.data.buffered.css({
                "width": 0
            });
        },
        
        onError: function(event){
            //$("#debug").append("ERROR" + event.data.player.error.code);
            if (event.data.useHTML5) {
                var message;
                switch (event.target.error.code) {
                    case event.target.error.MEDIA_ERR_ABORTED:
                        message = 'You aborted the video playback.';
                        break;
                    case event.target.error.MEDIA_ERR_NETWORK:
                        message = 'A network error caused the video download to fail part-way.';
                        break;
                    case event.target.error.MEDIA_ERR_DECODE:
                        message = 'The video playback was aborted due to a corruption problem or because the video used features your browser did not support.';
                        break;
                    case event.target.error.MEDIA_ERR_SRC_NOT_SUPPORTED:
                        message = 'The video could not be loaded, either because the server or network failed or because the format is not supported.';
                        break;
                    default:
                        message = 'An unknown error occurred.';
                        break;
                }
                //$("#debug").append(message);
                event.data.errorOverlay.html(message);
                event.data.errorOverlay.show();
            }
        },
        
        onSeeking: function(event){
            // $("#debug").append("SEEKING");
        },
        
        onSeeked: function(event){
            event.data.onProgress(event);
        },
        
        onVolumeChange: function(event){
            if (event.data.player.muted) {
                event.data.mute.addClass("mute");
            }
            else {
                event.data.mute.removeClass("mute");
            }
        },
        
        onDurationChange: function(event){
            var duration = event.data.player.duration;
            var currentTime = event.data.player.currentTime;
            
            var timeDuration = formatTimeStatus(currentTime, duration);
            
            event.data.currentTimeLabel.html(timeDuration[0]);
            event.data.durationLabel.html(timeDuration[1]);
        },
        
        onTimeUpdate: function(event){
            if (event.data.sliding) {
                return;
            }
            var duration = event.data.player.duration;
            var currentTime = event.data.player.currentTime;
            
            var timeDuration = formatTimeStatus(currentTime, duration);
            
            event.data.currentTimeLabel.html(timeDuration[0]);
            event.data.durationLabel.html(timeDuration[1]);
            
            var timePercent = (Math.max(0, currentTime) / duration * 100);
            
            event.data.slider.css({
                "left": timePercent + "%"
            });
            
            event.data.played.css({
                "width": timePercent + "%"
            });
            
            event.data.onProgress(event);
        },
        
        onProgress: function(event){
            var bufferedPercent = 0;
            
            if (!event.data.player.seeking) {
                var buffered = event.data.player.buffered;
                
                var time = event.data.seekTime || Math.max(0, event.data.player.currentTime);
                //$("#debug").append(buffered.length + "-" + buffered.end(buffered.length - 1));
                var timePercent = time / event.data.player.duration * 100;
                if (buffered) {
                    var lastBuffered = buffered.end(buffered.length - 1);
                    bufferedPercent = (lastBuffered / event.data.player.duration) * 100;
                    bufferedPercent -= timePercent;
                    //$("#debug").append(bufferedPercent);
                }
                if (timePercent + bufferedPercent > 100) {
                    bufferedPercent = 100 - timePercent;
                }
            }
            var css = {
                "left": timePercent + "%",
                "width": bufferedPercent + "%"
            }
            if (bufferedPercent + timePercent > 99) {
                event.data.buffered.addClass("done")
            }
            else {
                event.data.buffered.removeClass("done")
            }
            event.data.buffered.css(css);
        },
        
        layoutControlBar: function(newWidth, newHeight){
            if (this.useHTML5 && this.options.playButtonOverlay) {
                this.playOverlay.fadeIn(600);
                this.playOverlay.css({
                    "left": (newWidth / 2 - this.playOverlay.width() / 2) + "px",
                    "top": (newHeight / 2 - this.playOverlay.height() / 2) + "px"
                });
            }
            
            $('.video-progress2').css({
                "width": (newWidth - 200) + "px"
            });
            
            //$('.strobeMediaPlaybackControlBar').fadeIn(600);
            $('.strobeMediaPlaybackControlBar').css({
                "width": newWidth - 6 + "px"
            });
        }
        
    }
    
    StrobeMediaPlaybackChrome.prototype = strobeMediaPlaybackChromeMethods;
    
    
    /**
     * jQuery plugin hook
     */
    $.fn.strobemediaplaybackchrome = function(options){
        var instances = [], i;
        var result = this.each(function(){
            instances.push(new StrobeMediaPlaybackChrome(this, options));
        });
        
        for (i = 0; i < instances.length; i++) {
            instances[i].initialize();
        }
        return result;
    };
    
    /**
     * jQuery plugin defaults
     */
    $.fn.strobemediaplaybackchrome.defaults = {
        javascriptControls: false
    };
    
    
    // Internals, private functions
    
    function onMouseMove(event){
        showControlBar();
    }
    
    function formatTimeStatus(currentPosition, totalDuration){
        var h;
        var m;
        var s;
        function prettyPrintSeconds(seconds, leadingMinutes, leadingHours){
            seconds = Math.floor(isNaN(seconds) ? 0 : Math.max(0, seconds));
            h = Math.floor(seconds / 3600);
            m = Math.floor(seconds % 3600 / 60);
            s = seconds % 60;
            return ((h > 0 || leadingHours) ? (h + ":") : "") +
            (((h > 0 || leadingMinutes) && m < 10) ? "0" : "") +
            m +
            ":" +
            (s < 10 ? "0" : "") +
            s;
        }
        
        var totalDurationString = prettyPrintSeconds(totalDuration);
        var currentPositionString = prettyPrintSeconds(currentPosition, h > 0 || m > 9, h > 0);
        return [currentPositionString, totalDurationString];
    }
})(jQuery);