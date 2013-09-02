var strobeMediaPlayback = function () {
	var settings = {
		"tablet": {
			"startSize": {"width":480, "height":268},
			"wmode": "direct"
		},
		"smartphone": {
			"startSize": {"width":120, "height":67},
			"wmode": "direct"
		},
		"default": {
			"startSize": {"width":480, "height":268},
			"wmode": "direct"
		}
	};
	
	var flashvars = {hls_plugin : "HLSDynamicPlugin.swf"};
	
	function getSettingByDeviceType(setting, deviceType, defaultValue) {
		if (deviceType in settings) {
			return (settings[deviceType][setting] ? settings[deviceType][setting] : defaultValue);
		}
		else {
			return (settings["default"][setting] ? settings["default"][setting] : defaultValue);
		}
	}
	
	return { 
		settings: function(object) {
			settings = $.extend(true, settings, object);
		},
		flashvars: function(object) {
			flashvars = $.extend(true, flashvars, object);
		},
		draw: function(element) {
			if (element && flashvars && flashvars["src"]) {
				var agent = window.location.hash.replace(/^#/, "");

				function onDeviceDetection(device) {
					var startSize = getSettingByDeviceType("startSize", device.getProfile().type, "");
					if (device.profileDetected() && device.useFlash()) {
						if (device.getProfile().type == "tablet" || device.getProfile().type == "smartphone"){
							flashvars.skin = "skins/"+device.getProfile().type+"-skin.xml";
							flashvars.controlBarType = device.getProfile().type;
							flashvars.playButtonOverlay = false;
						}
						var params = settings[(device.getProfile().type in settings ? device.getProfile().type : "default")];
						params["movie"] = "StrobeMediaPlayback.swf";
						params["allowfullscreen"] = "true";
						params["allowscriptaccess"] = "always";
						
						var attributes = {};
						
						$("#" + element).parent().css("width",startSize["width"]);
						$("#" + element).parent().css("height",startSize["height"]);
						
						swfobject.embedSWF(
							"StrobeMediaPlayback.swf", 
							element, 
							startSize["width"], 
							startSize["height"], 
							"10.1.0", 
							"", 
							flashvars, 
							params, 
							attributes
						);
					}
					else {
						var html5divs = 
							'<div class="html5player">' + 
								'<div class="errorwindow"></div>' +
								'<div class="controls">' +
									'<div class="icon playtoggle">Play/Pause</div>' +
									'<div class="timestamp current">0:00</div>' +
									'<div class="progress">' +
										'<a class="slider"></a>' +
										'<div class="tracks">' +
											'<div class="seeking"></div>' + 
											'<div class="played"></div>' +
											'<div class="buffered"></div>' +
										'</div>' +
									'</div>' +
									'<div class="timestamp duration">0:00</div>' +
									'<div class="icon fullview">Full View</div>' +
								'</div>' +
								'<video width="' + startSize["width"] + '" height="' + startSize["height"] + '" preload="none" poster="' + flashvars["poster"] + '">' +
									'<source src="' + flashvars["src"] + '" />' +
								'</video>' +
							'</div>';
						$("#" + element).html(html5divs);
						$("#" + element + " .html5player").strobemediaplaybackhtml5();
					}
				}

				new DeviceDetection(agent).addCallback(onDeviceDetection).addProfiles(profiles).detect();
			}
		}
	}
}();