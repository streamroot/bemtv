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
    var StrobeMediaPlaybackHtml5 = function(element, options){
		this.$window = $(window);
		this.$document = $(document);
		this.element = element;
		this.$element = $(element);
		this.options = $.extend({}, $.fn.strobemediaplaybackhtml5.defaults, options);
    };
    
    var strobeMediaPlaybackHtml5Methods = {
        initialize: function(){
		   $(document).bind('webkitfullscreenchange', this, this.onFullscreenChange);
		   
		   this.$element.bind("mousemove", this, this.onMouseMove);
		   
		   this.$player = this.$element.find("video"); //$("#" + this.options.id)
		   this.player = this.$player.get(0);
		   
		   this.$player.bind("timeupdate", this, this.onTimeUpdate);
		   this.$player.bind('play', this, this.onPlay);
		   this.$player.bind("playing", this, this.onPlaying);
		   this.$player.bind('pause', this, this.onPause);
		   this.$player.bind('ended', this, this.onEnded);
		   this.$player.bind("loadeddata", this, this.onLoadedData);
		   this.$player.bind("loadedmetadata", this, this.onMetaDataLoaded);
		   this.$player.bind("progress", this, this.onProgress);
		   this.$player.bind("click", this, this.onClick);
		   this.$player.bind("dblclick", this, this.onDoubleClick);
		   this.$player.bind("contextmenu", this, function(event){ event.preventDefault(); }); //disable context menu
		   
		   this.hidedelaytimeout, this.isdragging, this.trackswidth;
		   
		   this.controlbar = this.$element.find(this.options.controlbarselector);
		   
		   this.progressbar = this.controlbar.find(this.options.progressbarselector);
		   this.progressbar.bind('click', this, this.onSeekClick);
		   this.tracks = this.progressbar.find(this.options.tracksselector);
		   this.seekbar = this.progressbar.find(this.options.seekbarselector);
		   this.playedbar = this.progressbar.find(this.options.playedbarselector);
		   this.bufferbar = this.progressbar.find(this.options.bufferedbarselector);
		   
		   this.playtoggle = this.controlbar.find(this.options.playtoggleselector);
		   this.playtoggle.bind('click', this, this.onPlayToggleClick);
		   this.playtoggle.bind("mousedown mouseup touchstart touchend", this, this.onButtonHover);
		   
		   this.slider = this.controlbar.find(this.options.sliderselector);
		   this.slider.draggable({disabled: false, containment: "parent", axis: "x"});
		   this.slider.bind("dragstart", this, this.onSliderDragStart);
		   this.slider.bind("drag", this, this.onSliderDragging);
		   this.slider.bind("dragstop", this, this.onSliderDragStop);
		   this.slider.bind("mousedown mouseup touchstart touchend", this, this.onButtonHover);
		   
		   this.fullview = this.controlbar.find(this.options.fullviewselector);
		   this.fullview.bind("click", this, this.onFullViewClick);
		   this.fullview.bind("mousedown mouseup touchstart touchend", this, this.onButtonHover);
		   
		   //disable the fullview button until metadata is loaded; necessary for iPad native fullscreen to work
		   this.fullview.addClass("disabled");
		   
		   this.$player.attr("preload", "true"); //start loading the video, if not already started
		   
		   this.currenttime = this.controlbar.find(this.options.currenttimeselector);
		   this.duration = this.controlbar.find(this.options.durationtimeselector);
		   
		   this.errorwindow = this.$element.find(this.options.errorwindowselector);
		   
		   this.options.originalWidth = this.player.clientWidth;
		   if(this.options.autoplay) this.player.play();
	   },
	   
	   onSliderDragStart: function(event){
		   event.data.isdragging = true;
		   event.data.seekbar.css("width", event.data.playedbar.width()+"px").show();
	   },
	   
	   onSliderDragging: function(event, ui){
		   event.data.seekbar.css("width", ui.position.left+"px");   
	   },
	   
	   onSliderDragStop: function(event, ui){ 
	   		event.data.isdragging = false;
			event.data.seekbar.hide();
			event.data.player.currentTime = event.data.player.duration*((ui.position.left+event.data.slider.width()/2)/$(this).parent().width());
			event.data.onTimeUpdate(event);
		},
	   
	   onProgress: function(event){
		   try{
			   var start = event.target.buffered.start();
			   var end = event.target.buffered.end()
			   var duration = event.target.duration;
			   event.data.bufferbar.css("width", ((end/duration)*100)+"%");
		   }catch(exception){}
	   },
	   
	   onPlay: function(event){
		   event.data.playtoggle.addClass('paused');
	   },
	   
	   onPlaying: function(event){
			event.data.slider.draggable("option", "disabled", false);
	   },
	   
	   onPause: function(event){
		   event.data.playtoggle.removeClass('paused');
	   },
	   
	   onEnded: function(event){
		   event.data.onPause(event);
		   event.data.showControls();
	   },
	   
	   onLoadedData: function(event){
		   event.data.bufferbar.css("width", "100%");
		   event.data.showControls();
		   event.data.duration.html(formatTimeStatus(0, event.target.duration)[1]);
		   event.data.trackswidth = event.data.tracks.width();
	   },
	   
	   onMetaDataLoaded: function(event){
		   event.data.fullview.removeClass("disabled");
	   },
	   
	   onMouseMove: function(event){
			event.data.showControls();
			if(!event.data.player.paused && !event.data.player.ended){
				clearTimeout(event.data.hidedelaytimeout);
				event.data.hidedelaytimeout = setTimeout(function(){event.data.hideControls(event);}, event.data.options.hidedelay);
			}
		},
	   
	   onButtonHover: function(event){
		   $(this).toggleClass("hover");
	   },
	   
	   onPlayToggleClick: function(event){
		   if(event.data.player.paused || event.data.player.ended) event.data.player.play();
		   else event.data.player.pause();
	   },
	   
	   onSeekClick: function(event){
		   var time = event.data.player.duration * ((event.clientX - event.data.progressbar.offset().left) / event.data.progressbar.outerWidth());
		   if(time > 0) event.data.player.currentTime = time;
		   if(event.data.player.paused) event.data.onPause(event);
		   else event.data.onPlay(event);
	   },
	   
	   onClick: function(event){
		   if(event.data.player.ended) event.data.hideControls(event);
		   else event.data.onMouseMove(event);
	   },
	   
	   onDoubleClick: function(event){
		   event.data.onFullViewClick(event);
	   },

		onFullViewClick: function(event){
			try{
				if(event.data.fullview.hasClass("disabled")) return; //do not do anything if the button is disabled
				if(navigator.userAgent.match(/(Macintosh|Windows|Safari|Version\/5\.[1-9])/gi).length >= 3){ //at a minimum match one of the OSes, Safari, and the version
					if($(document).context.webkitIsFullScreen) $(document).context.webkitCancelFullScreen();
					else event.data.$element.context.webkitRequestFullScreen();
				}else event.data.player.webkitEnterFullScreen();
			}catch(error){
				event.data.onFullscreenChange(event);
			}
		},
	   
		onFullscreenChange: function(event){
			event.data.$element.toggleClass(event.data.options.fullscreenclass);
			
			event.data.fullview.toggleClass(event.data.options.fullviewactiveclass);
			
			event.data.trackswidth = event.data.tracks.width();
			if(event.data.player.ended) event.data.onTimeUpdate(event);
		},
		
		onTimeUpdate: function(event){
			var percent = event.data.player.currentTime/event.data.player.duration;
			var px = percent*event.data.trackswidth;
			event.data.playedbar.css("width", px+"px");
			if(!event.data.isdragging) event.data.slider.css("left", px+"px");
			var times = formatTimeStatus(event.data.player.currentTime, event.data.player.duration);
			event.data.currenttime.html(times[0]);
			event.data.duration.html(times[1]);
		},
		
	   onError: function(event){
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
		 event.data.errorwindow.html(message);
		 event.data.errorwindow.show();
        },
	   
	   showControls: function(){
			if(this.controlbar.is(":visible")) return;
			this.controlbar.fadeIn(this.options.fadeinspeed);
		},
		
		hideControls: function(event){
			if(event.data.player.paused && !event.data.player.ended) return;
			event.data.controlbar.fadeOut(event.data.options.fadeoutspeed);
		}
    };
    
    StrobeMediaPlaybackHtml5.prototype = strobeMediaPlaybackHtml5Methods;
    
    /**
     * jQuery plugin hook
     */
    $.fn.strobemediaplaybackhtml5 = function(options){
        var instances = [], i;
        var result = this.each(function(){
            instances.push(new StrobeMediaPlaybackHtml5(this, options));
        });
        
        for (i = 0; i < instances.length; i++) {
            instances[i].initialize();
        }
        return result;
    };
    
    /**
     * jQuery plugin defaults
     */
    $.fn.strobemediaplaybackhtml5.defaults = {
       autoplay: false,
	  hidedelay: 6000,
	  fadeinspeed: "fast",
	  fadeoutspeed: 500,
	  controlbarselector: ".controls",
	  progressbarselector: ".progress",
	  tracksselector: ".tracks",
	  sliderselector: ".slider",
	  seekbarselector: ".seeking",
	  playedbarselector: ".played",
	  bufferedbarselector: ".buffered",
	  playtoggleselector: ".icon.playtoggle",
	  currenttimeselector: ".timestamp.current",
	  durationtimeselector: ".timestamp.duration",
	  errorwindowselector: ".errorwindow",
	  fullviewselector: ".icon.fullview",
	  fullscreenclass: "fullscreen",
	  fullviewactiveclass: "fullscreen"
    };
    
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