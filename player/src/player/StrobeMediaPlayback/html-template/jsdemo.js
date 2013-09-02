/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 * 
 **********************************************************/
 
if (typeof org == 'undefined') { var org = {}; }
if (typeof org.strobemediaplayback == 'undefined') { org.strobemediaplayback = {}; }
if (typeof org.strobemediaplayback.players == 'undefined') { org.strobemediaplayback.players = {}; }

org.strobemediaplayback.initializeControlBar = function() 
{
	$(".smp-volume").slider({
		orientation: 'horizontal',
		range: "min",
		max: 100.0,
		value: 100.0
	});
	
	$(".smp-progress").slider({
		orientation: 'horizontal',
		range: "min",
		max: 100.0,
		value: 100.0				
	});
	
	//$(".smp-progress.ui-corner-all").removeClass("ui-corner-all");			
	//$(".smp-progress a.ui-corner-all").removeClass("ui-corner-all");
	
	$('.smp-play').button({
		text: false,
		icons: {
			primary: 'ui-icon-play'
		}
	});
	
	$('.smp-mute').button({
		text: false,
		icons: {
			primary: 'ui-icon-volume-on'
		}
	});
	
	$('.smp-mbr-indicator').button({
		text: false,
		icons: {
			primary: 'ui-icon-signal'
		}
	});	
}

org.strobemediaplayback.formatTimeStatus = function(currentPosition, totalDuration)
{			
	var h;
	var m;
	var s;
	function prettyPrintSeconds(seconds, leadingMinutes, leadingHours)
	{
		seconds = Math.floor(isNaN(seconds) ? 0 : Math.max(0, seconds));
		h = Math.floor(seconds / 3600);
		m = Math.floor(seconds % 3600 / 60);
		s = seconds % 60;
		return ((h>0||leadingHours) ? (h + ":") : "")
		+ (((h>0||leadingMinutes) && m<10) ? "0" : "")
			+ m + ":" 
			+ (s<10 ? "0" : "") 
			+ s;
	}	
				
	var totalDurationString =  prettyPrintSeconds(totalDuration);			
	var currentPositionString = prettyPrintSeconds(currentPosition, h>0||m>9, h>0);
	return currentPositionString  + " / " + totalDurationString;
}

org.strobemediaplayback.StrobeMediaPlaybackJSUI = function(player, controlBar)
{
	this.currentTime = 0;
	this.player = player;
	this.controlBar = controlBar;
	this.play = $('.smp-play', this.controlBar);
	this.mute = $('.smp-mute', this.controlBar);
	this.volume = $('.smp-volume', this.controlBar);
	this.time = $('.smp-time', this.controlBar);
	this.progress = $('.smp-progress', this.controlBar);
	this.dynamicStreamingIndicator = $('.smp-mbr-indicator', this.controlBar);
	this.dynamicStreamingItems = $('.smp-mbr-items', this.controlBar);

	this.play.bind('click', this, this.onPlayClick);
	this.progress.bind('slide', this, this.onProgressSlide);
	this.progress.bind('change', this, this.onProgressSlide);
	this.mute.bind('click', this, this.onMuteClick);
	this.volume.bind('slide', this, this.onVolumeSlide);
	this.volume.bind('change', this, this.onVolumeSlide);
	
	this.dynamicStreamingIndicator.hide();
	this.dynamicStreamingIndicator.bind('mouseover', this, this.onDynamicStreamingMouseOver);
	this.dynamicStreamingIndicator.bind('mouseout', this, this.onDynamicStreamingMouseOut);
	this.dynamicStreamingIndicator.bind('click', this, this.onDynamicStreamingClick);
	
	this.dynamicStreamingItems.hide();
	
	//$(player).show();
}

org.strobemediaplayback.StrobeMediaPlaybackJSUI.prototype = 
{
	onDurationChange: function(duration)
	{
		this.duration = duration;
		$(this.time).html(org.strobemediaplayback.formatTimeStatus(this.currentTime, this.duration));
		$(".smp-progress").slider({						
			max: this.duration,
			value: Math.max(0, this.currentTime)				
		});	
	},
	
	onCurrentTimeChange: function(currentTime)
	{
		this.currentTime = currentTime;
		$(this.time).html(org.strobemediaplayback.formatTimeStatus(currentTime, this.duration));
		
		this.progress.slider({
			max: this.duration,	
			value: Math.max(0, currentTime)
		});	
	},

	onVolumeChange: function(value)
	{
		this.volume.slider("value", value * 100.0);
	},
	
	onMutedChange : function(value)
	{
		if (value == false) // Seems to be a BUG?
		{
			this.mute.button('option', {					
				icons: {
					primary: 'ui-icon-volume-on'
				}
			});
		}
		else
		{
			this.mute.button('option', {					
				icons: {
					primary: 'ui-icon-volume-off'
				}
			});				
		}		
	},
	
	onMediaPlayerStateChange : function(value)
	{	
		//alert("onMediaPlayerStateChange:" + value);
		var options; 		
		if (value == 'playing') 
		{
			options = 
				{
					label: 'pause',
					icons: {
						primary: 'ui-icon-pause'
					}
				};	
		}
		else if (value == 'paused' || value == 'ready')
		{
			options = 
				{
					label: 'play',
					icons: {
						primary: 'ui-icon-play'
					}
				};
		}		
		this.play.button('option', options);
	},
	
	onSwitchingChange: function(value, playerId)
	{	
		if (value == false)
		{
			this.onRedrawDynamicStreamItems(value, playerId);
		}
		else
		{
			//alert("start switching");
		}
	},	
		
	onRedrawDynamicStreamItems: function(value, playerId)
	{	
		if (value == false)
		{
			var dynamicStreams=this.player.getStreamItems();
			var buttonText;
			var button;
			button = $('<button value="auto" class="smp-mbr-auto">Auto</button>');
			if (this.player.getAutoDynamicStreamSwitch() == true)
			{
				button.button(
				{
					icons: 
					{
						primary: 'ui-icon-circle-triangle-e'
					}
				}
				);
			}
			else
			{
				button.button();
				button.bind("click", this, this.onMBRItemChange);
			}
			
			this.dynamicStreamingItems.empty();
			this.dynamicStreamingItems.append(button); 
			
			for (var idx = 0; idx < dynamicStreams.length; idx ++)
			{				
				buttonText = dynamicStreams[idx]['width'] + "x" + dynamicStreams[idx]['height'] + " @ " + dynamicStreams[idx]['bitrate'] + "kbps"; 
				button = $('<button class="smp-mbr-item" value="'+ idx +'"/>');
				
				if (idx==this.player.getCurrentDynamicStreamIndex())
				{
					button.button(
					{
						label: buttonText,
						icons: 
						{
							primary: 'ui-icon-circle-triangle-e'
						}
					}
					);
				}
				else
				{
					button.button({label: buttonText});
					button.bind("click", this, this.onMBRItemChange);
				}	
				//this.dynamicStreamingItems.append('<br/ >');
				this.dynamicStreamingItems.append(button);
			}
		}
		else
		{
			//alert('start switching');
		}
	},
	
	onAutoSwitchChange : function(value, playerId)
	{
		button = $(".smp-mbr-auto", this.dynamicStreamingItems );
		if (value)
		{
			button.button(
			{
				icons: 
				{
					primary: 'ui-icon-circle-triangle-e'
				}
			}
			);
			button.unbind('click');
		}
		else
		{
			button.button();
		}
	},
	
	onIsDynamicStreamChange: function(value, playerId) 
	{
		if (value == true)
		{
			this.onRedrawDynamicStreamItems(!value, playerId);
			this.dynamicStreamingIndicator.show();
		}
		else
		{
			this.dynamicStreamingIndicator.hide();
		}
	},	
	
	onMediaSizeChange: function(value, playerId) 
	{
		this.onRedrawDynamicStreamItems(false, playerId);
	},	
	

	//////////
	
 	onPlayClick:function(event)
	{
		var player = event.data.player;
		var state = player.getState();
		//alert("onPlayClick:function:"+state);
		if (state == 'playing') 
		{
			player.pause();
		}
		else if (state == 'paused' || state == 'ready') 
		{
			player.play2();
		}			
	},
	
	onProgressSlide: function(event, ui)
	{	
		if (event.originalEvent != undefined)
		{	
			var player = event.data.player;			
			var seekValue = ui.value;
			$("#debug").append("<br />seek=" + seekValue);
			if (player.getState() != "ready" && player.canSeekTo(seekValue))
			{
				player.seek(seekValue);
			}	
			else
			{
				return false;
			}		
		}
		return true;
	},
	
	onVolumeSlide: function (event, ui) 
	{
		var player = event.data.player;
		player.setVolume(ui.value / 100.0);			
	},
	
	onMuteClick: function(event)
	{
		var player = event.data.player;
		player.setMuted(!player.getMuted());
	},
	
	onDynamicStreamingMouseOver: function(event)
	{
		var dynamicStreamingItems = event.data.dynamicStreamingItems;
		//dynamicStreamingItems.show();
		
		//alert('over:' + player.id);
	},
	
	onDynamicStreamingMouseOut: function(event)
	{
		var dynamicStreamingItems = event.data.dynamicStreamingItems;
		//dynamicStreamingItems.hide();
		
		//alert('over:' + player.id);
	},
	
	onDynamicStreamingClick: function(event)
	{
		var dynamicStreamingItems = event.data.dynamicStreamingItems;
		var player = event.data.player;
		var state = player.getState();	
		if (state != "playing" && state != "paused" ) return false;
		
		if (dynamicStreamingItems.is(':visible'))
		{
			dynamicStreamingItems.hide();
		}
		else
		{
			dynamicStreamingItems.show();
		}
		return true;
		//alert('over:' + player.id);
	},
	
	onMBRItemChange: function(event)
	{
		var player = event.data.player;
		var state = player.getState();		
		var controlBar = event.data.controlBar;
		//alert(event.target.value);
		
		$(event.currentTarget).button(
			{
				icons: 
				{
					primary: 'ui-icon-shuffle'
				}
			}
		);
		
		$(event.currentTarget).siblings().unbind('click');
		
		if (event.target.value=="auto")
		{
			player.setAutoDynamicStreamSwitch(true);
		}
		else
		{
			player.setAutoDynamicStreamSwitch(false);
			player.switchDynamicStreamIndex(event.target.value);
		}
		//alert(event.target.value);
	}
}
			
			
$(function()
	{
		org.strobemediaplayback.initializeControlBar();
	}
);	

// Utilities
//	
org.strobemediaplayback.bindListeners = function (player, instance, instanceName)
{
	for (var name in instance)
	{
		if (name.indexOf('on') == 0)
		{
			var eventName = name.charAt(2).toLowerCase() + name.substring(3);
			player.addEventListener(eventName, instanceName + "." + name);
		}
	}
}