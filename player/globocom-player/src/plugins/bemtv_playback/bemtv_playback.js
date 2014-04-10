// Copyright 2014 Flávio Ribeiro. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

var UIPlugin = require('../../base/ui_plugin');
var Styler = require('../../base/styler');
var JST = require('../../base/jst');
var _ = require("underscore");
var BemTVCore =  require('./bemtv');

var BemTVP2PVideoPlaybackPlugin = UIPlugin.extend({
  name: 'bemtv_playback',
  tagName: 'object',
  template: JST.bemtv_playback,
  attributes: {
    'data-bemtv-playback': ''
  },
  initialize: function(options) {
    this.src = options.src.replace("http+p2p", "http");
    this.swfPath = options.swfPath || "assets/P2PPlayer.swf";
    this.autoPlay = options.autoPlay;
    this.settings = {
      left: ["playstop"],
      right: ["fullscreen", "volume"]
    };
    this.bemtv = new BemtvCore(this.container, this.el);
    this.checkIfFlashIsReady();
  },
  requestResource: function(url) {
    this.bemtv.requestResource(url);
  },
  getCurrentMediaSequence: function() {
    this.container.statsAdd({"currentMediaSequence": this.el.getCurrentMediaSequence()});
  },
  bootstrap: function() {
    this.trigger('playback:ready', this.name);
    clearInterval(this.bootstrapId);
    this.currentState = "IDLE";
    this.timedCheckState();
    this.el.playerSetflushLiveURLCache(true);
    this.el.playerSetstartFromLowestLevel(true); // decreases startup time
  },
  checkIfFlashIsReady: function() {
    this.bootstrapId = setInterval(function() {
      if(this.el.getState) {
        this.bootstrap();
      }
    }.bind(this), 50);
  },
  updateTime: function(interval) {
    return setInterval(function() {
      this.trigger('playback:timeupdate', this.el.getPosition(), this.el.getDuration(), this.name);
    }.bind(this), interval);
  },
  play: function() {
    if(this.el.getState() === 'IDLE') {
      this.id = this.updateTime(1000);
    }
    if(this.el.getState() === 'PAUSED') {
      this.el.playerResume();
    } else {
      this.firstPlay();
    }
  },
  timedCheckState: function() {
    this.checkStateId = setInterval(this.checkState.bind(this), 250);
    this.currentMediaSequenceId = setInterval(this.getCurrentMediaSequence.bind(this), 1000);
  },
  checkState: function() {
    if (this.el.getState() === "PLAYING_BUFFERING" && this.el.getbufferLength() < 1 && this.currentState !== "PLAYING_BUFFERING") {
      this.trigger('playback:buffering', this.name);
      this.currentState = "PLAYING_BUFFERING";
    } else if (this.currentState === "PLAYING_BUFFERING" && this.el.getState() === "PLAYING") {
      this.trigger('playback:bufferfull', this.name);
      this.currentState = "PLAYING";
    } else if (this.el.getState() === "IDLE") {
      this.currentState = "IDLE";
    }
  },
  firstPlay: function() {
    this.el.playerLoad(this.src);
    this.el.playerPlay();
  },
  volume: function(value) {
    this.el.playerVolume(value);
  },
  pause: function() {
    this.el.playerPause();
  },
  stop: function() {
    this.el.playerStop();
    clearInterval(this.id);
    this.trigger('playback:timeupdate', 0, this.name);
  },
  isPlaying: function() {
    return !!(this.isReady && this.el.getState().match(/playing/i));
  },
  seek: function(time) {
    clearInterval(this.id);
    this.el.playerSeek(this.el.getDuration() * (time / 100));
    this.id = this.updateTime(1000);
  },
  timeUpdate: function(time, duration) {
    this.trigger('playback:timeupdate', time, duration, this.name);
  },
  destroy: function() {
    clearInterval(this.id);
    clearInterval(this.checkStateId);
    clearInterval(this.currentMediaSequenceId);
  },
  setupFirefox: function() {
    var $el = this.$('embed');
    $el.attr('data-hls-playback', '');
    this.setElement($el[0]);
  },
  render: function() {
    var style = Styler.getStyleFor(this.name);
    this.$el.html(this.template({swfPath: this.swfPath}));
    this.$el.append(style);
    this.el.id = this.cid;
    if(navigator.userAgent.match(/firefox/i)) { //FIXME remove it from here
      this.setupFirefox();
    }
    return this;
  }
});

BemTVP2PVideoPlaybackPlugin.canPlay = function(resource) {
  return !!resource.match(/p2p\+http(.*).m3u8/);
}


module.exports = BemTVP2PVideoPlaybackPlugin;
