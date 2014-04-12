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
    this.container.statsAdd({"chunksSent": 0, "chunksReceivedP2P": 0, "chunksReceivedCDN": 0});
    if (this.p2pSupport) {
      console.log("[bemtv] peer have webrtc support");
      this.peer = this.createPeer();
    }
    cdn_getter.addEventListener('message', this.resourceLoadedFromCDN.bind(this), false);
  },
  requestResource: function(url) {
    this.currentUrl = url;
    if (this.p2pSupport) { //have p2p and we aren't filling startup buffer (issue #23)
      timeout = this.getTimeout();
      console.log('[bemtv] requesting ' + url + ' to peers with ' + timeout);
      this.timeoutId = setTimeout(function() { cdn_getter.postMessage(this.currentUrl); }.bind(this), timeout);
      this.peer.requestResource(url, this.timeoutId);
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
    var current = this.container.getPluginByName("stats").getStats()['chunksReceivedCDN'];
    this.container.statsAdd({'chunksReceivedCDN': current+1});
  },
  createPeer: function() {
    return new Peer(this.container, this.el, this.cache);
  },
});

module.exports = BemTVCore;
