var BaseObject = require('../../base/base_object');
var utils = require('./utils.js');
var rtc_quickconnect = require('rtc-quickconnect');
var rtc_bufferedchannel = require('rtc-bufferedchannel');
var freeice = require('freeice');
var _ = require('underscore');

BEMTV_ROOM_DISCOVER_URL = "http://server.bem.tv/room"
BEMTV_SERVER = "http://server.bem.tv:8080"

var Peer = BaseObject.extend({
  initialize: function(container, el, resourceLoadedCallback) {
    this.container = container;
    this.el = el;
    this.resourceLoaded = resourceLoadedCallback;
    this.swarm = {};
    this.peersServed = {};
    this.room = this.discoverRoom(BEMTV_ROOM_DISCOVER_URL);
    this.connect();
  },
  connect: function() {
    console.log("[bemtv] detected swarm name: " + this.room);
    connection = rtc_quickconnect(BEMTV_SERVER, {room: this.room, iceServers: freeice()});
    console.log("[bemtv] connecting... ");
    this.createDataChannel(connection);
  },
  createDataChannel: function(connection) {
    dataChannel = connection.createDataChannel(this.room); // disable heartbeat?
    dataChannel.on(this.room + ':open', this.onOpen.bind(this));
    dataChannel.on('peer:leave', this.onDisconnect.bind(this));
    console.log("[bemtv] connected. ");
  },
  discoverRoom: function(url) {
    response = utils.request(url);
    return response? JSON.parse(response)['room']: "bemtv";
  },
  onOpen: function(dc, id) {
    this.swarmAdd(id, dc);
    if (this.container.getPluginByName('stats').getStats()['watchingTime']) {
      this.send(id, _.extend({"msg": "PING"}, this.getScoreParameters()));
    }
  },
  send: function(id, message) {
    var sendingTime = Date.now();
    this.swarm[id].dataChannel.send(JSON.stringify({"msg" : message, 'sendingTime': sendingTime}));
  },
  recv: function(id, message) {
    data = JSON.parse(message);
    rtt = Math.abs(Date.now() - data.sendingTime);
    if (data.msg['msg'] == "PING") {
      this.swarm[id]["score"] = this.calculateScore(_.extend({"rtt":rtt}, data.msg.scoreParams));
    }
  },
  calculateScore: function(params) {
    console.log("Need to calculate score for: ", params);
    return 600;
  },
  swarmAdd: function(id, dc) {
    dataChannel = rtc_bufferedchannel(dc, {calcCharSize: false});
    this.swarm[id] = {"dataChannel" : dataChannel, "score": undefined};
    dataChannel.on('data', function(data) { this.onData(id, data); }.bind(this));
  },
  onData: function(id, data) {
    this.recv(id, data);
  },
  onDisconnect: function(id) {
    console.log("[bemtv] peer " + id + " disconnected.");
    delete this.swarm[id];
  },
  getScoreParameters: function() {
    this.metrics = this.container.getPluginByName('stats').getStats();
    return {"scoreParams": {"wt": this.metrics['watchingTime'] || 0,
            "rt": this.metrics['rebufferingTime'] || 0 ,
            "cms": this.metrics["currentMediaSequence"],
            "tps": this.peersServed.length || 0}};
  },
  requestResource: function(url) {
    console.log("[bemtv] ask partners for " + url);
  }
});

module.exports = Peer;
