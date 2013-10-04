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
 * jQuery plugin that generate the necessary video playback mark-up.
 * @param {Object} /iPad/i
 */
(function($, undefined){


    /**
     * Adapts the options of the video player based on the device/browser capabilities.
     */
    var AdaptiveExperienceConfigurator = function(){
    };
    
    var adaptiveExperienceConfiguratorMethods = {
    
        initialize: function(){
            this.userAgent = navigator.userAgent;
            
            this.isiPad = this.userAgent.match(/iPad/i) != null;
            this.isiPhone = this.userAgent.match(/iPhone/i) != null;
            this.isAndroid = this.userAgent.match(/Android/i) != null;
            
            this.screenWidth = screen.width;
            this.screenHeight = screen.width;
            this.isPhone = this.screenHeight < 360;
            this.isTablet = this.screenHeight >= 360 && this.screenHeight <= 768;
            this.isDesktop = this.screenHeight > 768;
            
            this.hasHTML5VideoCapability = !!document.createElement('video').canPlayType;
			this.flashPlayerVersion = swfobject.getFlashPlayerVersion();
            this.hasFlashPlayerCapability = this.flashPlayerVersion.major >= 10;          
        },
        
        adapt: function(options){
        
            if (!this.userAgent) {
                // Initialize lazily
                this.initialize();
            }
            
            // First, extend with default values
			options = $.extend({}, $.fn.strobemediaplayback.defaults, options);
            this.changed = true;
            var i = 0, n = this.rules.length;
            while (this.changed) {
                this.changed = false;
                for (i = 0; i < n; i++) {
                    this.rules[i](this, options);
                }
                this.changed = false;
            }
            return options;
        },
        
        setOption: function(options, name, value){
            if (!options.hasOwnProperty(name) || options[name] != value) {
                options[name] = value;
                this.changed = true;
            }
        },
		
        rules: [ 		
			//playerImplementation
			function(context, options){
	            if (options.favorFlashOverHtml5Video && context.hasFlashPlayerCapability) {
					context.setOption(options, "useHTML5", false);
				}
				else {
					if (!options.favorFlashOverHtml5Video && context.hasHTML5VideoCapability) {
						context.setOption(options, "useHTML5", true);
					}
					else {
						if (options.favorFlashOverHtml5Video) {
							context.setOption(options, "useHTML5", !context.hasFlashPlayerCapability);
						}
						else {
							context.setOption(options, "useHTML5", context.hasHTML5VideoCapability);
						}
					}
				}
	        }, 
			
			//neverUseJavaScriptControlsOnIPhone:
	 		function(context, options){
	            if (context.isiPhone) {
	                context.setOption(options, "javascriptControls", false);
	            }
	        }, 
			
			//hideVolumeControlOnIPad: 
	 		function(context, options){
	            if (context.isiPad) {
	                context.setOption(options, "disabledControls", ".volume");
	            }
	        }, 
			
			// No Flash & No HTML5 Video
	 		function(context, options){
	            if (!context.hasFlashPlayerCapability && !context.hasHTML5VideoCapability) {
	                context.setOption(options, "javascriptControls", false);
	                context.setOption(options, "displayAlternativeContent", true);
	            }
	        }
		]
    };
    
    AdaptiveExperienceConfigurator.prototype = adaptiveExperienceConfiguratorMethods;
	  
	$.fn.adaptiveexperienceconfigurator = new AdaptiveExperienceConfigurator();
    
    var StrobeMediaPlayback = function(element, options){
		this.element = element;
        this.$element = $(element);
        this.options = $.extend({}, $.fn.strobemediaplayback.defaults, options);
    };
	
	// HACK: keeps the reference to the context of the function which uses swfobject 
	// - needed for the swfobject.js error callback handler.
    var onFlashEmbedCompleteThisReference = null;
	
    var strobeMediaPlaybackMethods = {
        initialize: function() {
			// Detect video playback capabilities and adapt the settings
		    this.options = $.fn.adaptiveexperienceconfigurator.adapt(this.options);
			
            if (this.options.useHTML5) {
				var $video = $("<video></video>");
                $video.attr("id", this.options.id);	
                $video.attr("class", "smp_video");
                $video.attr("preload", "none");
                $video.attr("width", this.options.width);
                $video.attr("height", this.options.height);
                $video.attr("src", this.options.src);
				
				if (this.options.loop)
				{
					$video.attr("loop", "loop");
				}
				if (this.options.autoPlay)
				{
					$video.attr("autoplay", "autoplay");
				}
				if (this.options.controlBarMode !=  "none")
				{
					$video.attr("controls", "controls");
				}
				if  (this.options.poster != "")
				{
					$video.attr("poster", this.options.poster);
				}
                this.$element.replaceWith($video);
				
				this.$video = $video;
				this.video = $video[0];
            }
            else {
                this.options.queryString = $.fn.strobemediaplayback.generateQueryString(this.options);
                var flashvars = this.options;
				flashvars.javascriptCallbackFunction = "$.fn.strobemediaplayback.triggerHandler";
                var params = {
                    allowFullScreen: "true",
					wmode: "direct"
                };
                var attributes = {
                    id: this.options.id,
                    name: this.options.id
                };
				onFlashEmbedCompleteThisReference = this;
                swfobject.embedSWF(this.options.swf, 
					this.$element.attr("id"), 
					this.options.width, 
					this.options.height, 
					this.options.minimumFlashPlayerVersion, 
					this.options.expressInstallSwfUrl, 
					flashvars, params, attributes, 
					this.onFlashEmbedComplete);		
				
					this.monitor = new VideoElementMonitor(null);  
					
					this.$video = this.monitor.$videoElement;
					this.video = this.monitor.videoElement;
					proxyMediaElements[this.options.id] = this.monitor;				            
            }
        },
		
		onFlashEmbedComplete: function(event)
		{			
			if (!event.success && $.fn.adaptiveexperienceconfigurator.hasHTML5VideoCapability)
			{
				onFlashEmbedCompleteThisReference.useHTML5 = true;
				onFlashEmbedCompleteThisReference.initialize();			
			}
			else {
				// TODO: Error notification - failed to embed the video -> fallback to displaying a link?
			}
		}
    }
    
    StrobeMediaPlayback.prototype = strobeMediaPlaybackMethods;
    
    $.fn.strobemediaplayback = function(options){
		
        var instances = [], i;
        
        var result = null;
		
		this.each(function(){
			var strobeMediaPlayback = new StrobeMediaPlayback(this, options);
            instances.push(strobeMediaPlayback);
        });
        
        for (i = 0; i < instances.length; i++) {			
            instances[i].initialize();
			if (result == null) {
				result = instances[i].$video;
			}
			else{
				result.push(instances[i].video);
			}
        }
        return result;
    };
    
    /**
     * Plug-in default values
     */
    $.fn.strobemediaplayback.defaults = {
        favorFlashOverHtml5Video: true,
        swf: "StrobeMediaPlayback.swf",
        //javascriptCallbackFunction: "org.strobemediaplayback.triggerHandler",
		javascriptCallbackFunction: "$.fn.strobemediaplayback.triggerHandler",
		
        minimumFlashPlayerVersion: "10.0.0",
        expressInstallSwfUrl: "expressInstall.swf",
		autoPlay: false,
		loop: false,
		controlBarMode: "docked",
		poster: ""
    };    
	
	
    /**
     * Utitility method that will retrieve the page parameters from the Query String.
     */
    $.fn.strobemediaplayback.parseQueryString = function(queryString){
        var options = {};
        
        var queryPairs = queryString.split('&'), queryPair, n = queryPairs.length;
        for (var i = 0; i < n; i++) {
            queryPair = queryPairs[i].split('=');
            if (queryPair[1] == "true" || queryPair[1] == "false") {
                options[queryPair[0]] = (queryPair[1] == "true");
            }
            else {
                var number = parseFloat(queryPair[1]);
                if (!isNaN(number)) {
                    options[queryPair[0]] = number;
                }
                else {
                    options[queryPair[0]] = queryPair[1];
                }
            }
        }
        return options;
    }
    
    
    /**
     * Utitility method that will retrieve the page parameters from the Query String.
     */
    $.fn.strobemediaplayback.generateQueryString = function(options){
        var queryStrings = [];
        for (var key in options) {
            if (queryStrings.length > 0) {
                queryStrings.push("&");
            }
            queryStrings.push(encodeURIComponent(key));
            queryStrings.push("=");
            queryStrings.push((options[key]));
        }
        return queryStrings.join("");
    }

	var proxyMediaElements = {};
	var proxiedMediaElements = {};
	
	$.fn.strobemediaplayback.triggerHandler = function(id, eventName, updatedProperties){
		var proxyMediaElement = proxyMediaElements[id];
		if (typeof proxyMediaElement != 'undefined') {
			
			if (typeof proxiedMediaElements[id] == 'undefined') {
				strobeMediaPlayback = document.getElementById(id);	
				proxiedMediaElements[id] = strobeMediaPlayback;
				
				proxyMediaElement.strobeMediaPlayback = strobeMediaPlayback;
			    proxyMediaElement.videoElement.play = jQuery.proxy(strobeMediaPlayback.play2, proxyMediaElement.strobeMediaPlayback);
		        proxyMediaElement.videoElement.pause = jQuery.proxy(strobeMediaPlayback.pause, proxyMediaElement.strobeMediaPlayback);
		        proxyMediaElement.videoElement.load = jQuery.proxy(proxyMediaElement.load, proxyMediaElement);
				proxyMediaElement.videoElement.strobeMediaPlayback = strobeMediaPlayback;				
				monitorChanges(proxyMediaElement);	
			}			
			proxyMediaElement.update(updatedProperties, [eventName], proxyMediaElement);
		}
	}
    /**
     * Custom video playback controls
     */
    var writableProperties = "src preload currentTime defaultPlaybackRate playbackRate autoplay loop controls volume muted".split(" ");
    
    var timeRangeProperties = "played seekable buffered".split(" ");
    var timeRangeMethods = {
        start: function(index){
            return this._start[index];
        },
        end: function(index){
            return this._end[index];
        }
    }
    
    var monitorChanges = function(monitor){
        var i = writableProperties.length;
        while (i--) {
            var propertyName = writableProperties[i];
            if (monitor.cc.hasOwnProperty(propertyName) &&
            monitor.videoElement.hasOwnProperty(propertyName) &&
            monitor.cc[propertyName] != monitor.videoElement[propertyName]) { 			
                var setter = "set" + propertyName.charAt(0).toUpperCase() + propertyName.substring(1);
                monitor.strobeMediaPlayback[setter](monitor.videoElement[propertyName]);
				monitor.cc[propertyName] = monitor.videoElement[propertyName];
            }
        }
        setTimeout(function(){
            monitorChanges(monitor)
        }, 500);
    };
    
    var VideoElementMonitor = function($strobeMediaPlayback) {        
        this.videoElement = {
            duration: 0,
            currentTime: 0,
            paused: true,
            muted: false
        };
        
        this.cc = {
            duration: 0,
            currentTime: 0,
            paused: true,
            muted: false
        };
 
        this.$videoElement = $(this.videoElement);
    }
	
    var isPropertyChanged = function(object, cc, propertyName)
	{
		return !object.hasOwnProperty(propertyName) && object[propertyName] != cc[propertyName];
	}
	
    var videoElementMonitorMethods = {		
        load: function(){			
            this.strobeMediaPlayback.setSrc(this.videoElement.src);
            this.strobeMediaPlayback.load();
        },
        
        update: function(properties, events, monitor){       			
            var propertyName;
			for (propertyName in properties) {
                if (jQuery.inArray("emptied", events) < 0 &&
                monitor.cc.hasOwnProperty(propertyName) &&
                monitor.videoElement.hasOwnProperty(propertyName) &&
                (monitor.cc[propertyName] != monitor.videoElement[propertyName] && 
				!isNaN(monitor.cc[propertyName]) && 
				!isNaN(monitor.videoElement[propertyName]))) {
                    // this value changed
                    continue;
                }
				
                monitor.cc[propertyName] = properties[propertyName];
                monitor.videoElement[propertyName] = properties[propertyName];
                if (jQuery.inArray(propertyName, timeRangeProperties) >= 0) {
                    monitor.videoElement[propertyName].start = timeRangeMethods.start;
                    monitor.videoElement[propertyName].end = timeRangeMethods.end;
                }
            }

            if (events) {
                var i = events.length;
                while (i--) {
                    monitor.$videoElement.triggerHandler(events[i]);
                }
            }
        }
    }
    
    VideoElementMonitor.prototype = videoElementMonitorMethods;
})(jQuery);


/*
 * Generate org.strobemediaplayback namespace - which will be used by the
 * Flash/Strobe Media Playback once it is ready
 */
if (typeof org == 'undefined') {
    var org = {};
}

if (typeof org.strobemediaplayback == 'undefined') {
    org.strobemediaplayback = {};
}

if (typeof org.strobemediaplayback.proxied == 'undefined') {
    org.strobemediaplayback.proxied = {};
}

org.strobemediaplayback.triggerHandler = function(id, eventName, updatedProperties){
	alert("--org.strobemediaplayback.triggerHandler");
    if (eventName == "onJavaScriptBridgeCreated") {
        if (typeof onJavaScriptBridgeCreated == "function") {
            onJavaScriptBridgeCreated(id);
        }
    }
    else {
        if (typeof org.strobemediaplayback.proxied[id] != 'undefined') {
            org.strobemediaplayback.proxied[id].update(updatedProperties, [eventName], org.strobemediaplayback.proxied[id]);
        }
    }
}
