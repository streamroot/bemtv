var BaseObject = require('../../base/base_object');
var Peer = require('./peer');
var work = require('webworkify');
var cdn_getter = work(require('./cdn_getter.js'));

var BemTVCore = BaseObject.extend({
  initialize: function(container, el) {
    this.container = container;
    this.el = el;
    this.p2pSupport = !!(window.webkitRTCPeerConnection || window.mozRTCPeerConnection)
    if (this.p2pSupport) {
      console.log("[bemtv] peer have webrtc support");
      this.peer = this.createPeer();
    }
    cdn_getter.addEventListener('message', this.resourceLoaded.bind(this), false);
  },
  requestResource: function(url) {
    cdn_getter.postMessage(url);
  },
  resourceLoaded: function(ev) {
    this.el.resourceLoaded(ev.data);
  },
  createPeer: function() {
    return new Peer(this.container, this.el);
  },
});

module.exports = BemTVCore;
