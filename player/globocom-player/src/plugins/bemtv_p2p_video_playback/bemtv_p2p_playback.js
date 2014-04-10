// Copyright 2014 Flávio Ribeiro. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.o/

var UIPlugin = require('../../base/ui_plugin');
var Styler = require('../../base/styler');
var JST = require('../../base/jst');
var _ = require("underscore");
var BemtvCore = require('./bemtv');

var BemTVP2PVideoPlaybackPlugin = UIPlugin.extend({
  name: 'bemtv_p2p_video_playback',
  tagName: 'object',
  template: JST.bemtv_p2p_video_playback,
  attributes: {
    'data-bemtv-p2p-playback': ''
  },

  initialize: function(options) {
    this.src = options.src.replace("http+p2p", "http");
    this.options = options;
    this.el.id = this.cid;
    this.swfPath = options.swfPath || "assets/P2PPlayer.swf";
    this.container.settings = {
      left: ["playstop"],
      right: ["fullscreen", "volume"]
    };
    this.autoPlay = options.autoPlay;
    this.render();
    this.checkIfFlashIsReady();
  },
  requestResource: function(url) {
    this.bemtv.requestResource(url);
  },
  bindEvents: function() {
    this.listenTo(this.container, 'container:play', this.play);
    this.listenTo(this.container, 'container:pause', this.pause);
    this.listenTo(this.container, 'container:stop', this.stop);
    this.listenTo(this.container, 'container:seek', this.seek);
    this.listenTo(this.container, 'container:volume', this.volume);
    this.listenTo(this.container, 'container:fullscreen', this.fullscreen);
    this.listenTo(this.container, 'container:destroyed', this.containerDestroyed);
  },

  bootstrap: function() {
    this.bemtv = new BemtvCore(this.container, this.el);
    clearInterval(this.bootstrapId);
    this.currentState = "IDLE";
    this.timedCheckState();
    this.autoPlay && this.container.play();
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
      var time = (100 / (this.el.getDuration() || 1)) * (this.el.getPosition() || 0);
      this.container.timeUpdated(time);
    }.bind(this), interval);
  },

  play: function() {
    if(this.el.getState() === 'IDLE') {
      this.id = this.updateTime(1000);
    }
    if(this.el.getState() === 'PAUSED') {
      this.el.resume();
    } else {
      this.firstPlay();
    }
  },

  timedCheckState: function() {
    this.currentMediaSequenceId = setInterval(this.getCurrentMediaSequence.bind(this), 1000);
    this.checkStateId = setInterval(this.checkState.bind(this), 400);
  },

  checkState: function() {
    if (this.el.getState() === "PLAYING_BUFFERING" && this.el.getbufferLength() < 1) {
      this.container.buffering();
      this.currentState = "PLAYING_BUFFERING";
    } else if (this.currentState === "PLAYING_BUFFERING" && this.el.getState() === "PLAYING") {
      this.container.bufferfull();
      this.currentState = "PLAYING";
    } else if (this.el.getState() === "IDLE") {
      this.currentState = "IDLE";
    }
  },

  getCurrentMediaSequence: function() {
    this.container.statsAdd({"currentMediaSequence": this.el.getCurrentMediaSequence()});
  },

  firstPlay: function() {
    this.el.load(this.src);
    this.el.play();
  },

  volume: function(value) {
    this.el.volume(value);
  },

  pause: function() {
    this.el.pause();
  },

  stop: function() {
    this.el.stop();
    clearInterval(this.id);
    this.container.timeUpdated(0);
  },

  seek: function(time) {
    clearInterval(this.id);
    this.el.seek(this.el.getDuration() * (time / 100));
    this.id = this.updateTime(1000);
  },

  timeUpdate: function(time) {
    this.container.timeUpdated(time);
  },

  containerDestroyed: function() {
    clearInterval(this.id);
    clearInterval(this.checkStateId);
    clearInterval(this.currentMediaSequenceId);
  },

  setupFirefox: function() {
    var $el = this.$('embed');
    $el.attr('data-bemtv-p2p-playback', '');
    this.setElement($el[0]);
  },

  render: function() {
    var style = Styler.getStyleFor(this.name);
    this.$el.html(this.template({swfPath: this.swfPath}));
    this.$el.append(style);
    this.container.$el.append(this.el);
    if(navigator.userAgent.match(/firefox/i)) { //FIXME remove it from here
      this.setupFirefox();
    }
    return this;
  },

  request: function(url, callback, responseType) {
    var xhr = new XMLHttpRequest();
    xhr.open("GET", url, callback? true: false);
    if (responseType) {
      xhr.responseType = responseType;
    }
    if (callback) {
      xhr.onload = callback;
      xhr.send();
    } else {
      xhr.send();
      return xhr.status == 200? xhr.response: "";
    }
  },
});

BemTVP2PVideoPlaybackPlugin.canPlay = function(resource) {
  return !!resource.match(/http\+p2p:\/\/(.*).m3u8/);
}

module.exports = BemTVP2PVideoPlaybackPlugin;
