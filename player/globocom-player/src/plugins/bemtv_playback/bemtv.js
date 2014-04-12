var BaseObject = require('../../base/base_object');
var Peer = require('./peer');
var work = require('webworkify');
var cdn_getter = work(require('./cdn_getter.js'));

MAX_CACHE_SIZE = 10;

var BemTVCore = BaseObject.extend({
  initialize: function(container, el) {
    this.container = container;
    this.el = el;
    this.p2pSupport = !!(window.webkitRTCPeerConnection || window.mozRTCPeerConnection);
    this.cache = {};
    if (this.p2pSupport) {
      console.log("[bemtv] peer have webrtc support");
      this.peer = this.createPeer();
    }
    cdn_getter.addEventListener('message', this.resourceLoadedFromCDN.bind(this), false);
  },
  requestResource: function(url) {
    this.currentUrl = url;
    if (this.p2pSupport) {
      this.peer.requestResource(url);
      timeout = this.getTimeout();
      console.log('[bemtv] requesting ' + url + ' to peers with ' + timeout + "ms of timeout");
      this.timeoutId = setTimeout(function() { cdn_getter.postMessage(this.currentUrl); }.bind(this), timeout);
    } else {
      cdn_getter.postMessage(url);
    }
  },
  getTimeout: function() {
    var chunkSize = this.el.getChunkSize();
    return chunkSize !== 0? chunkSize * 500:1000;
  },
  resourceLoadedFromCDN: function(ev) {
    this.el.resourceLoaded(ev.data);
    this.cache[this.currentUrl] = ev.data;
  },
  resourceLoadedFromP2P: function(data) {
    console.log("loaded from p2p!");
  },
  createPeer: function() {
    return new Peer(this.container, this.el, this.resourceLoadedFromP2P);
  },
});

module.exports = BemTVCore;
