var BaseObject = require('../../base/base_object');
var utils = require('./utils.js');
var rtc_quickconnect = require('rtc-quickconnect');
var rtc_bufferedchannel = require('rtc-bufferedchannel');
var freeice = require('freeice');
var _ = require('underscore');

BEMTV_ROOM_DISCOVER_URL = "http://server.bem.tv/room"
BEMTV_SERVER = "http://server.bem.tv:8080"
MAX_CACHE_SIZE = 10;

var Peer = BaseObject.extend({
  initialize: function(container, el) {
    this.container = container;
    this.el = el;
    this.swarm = {};
    this.room = this.discoverRoom(BEMTV_ROOM_DISCOVER_URL);
    this.listenTo(this.container, 'container:stats:report', this.onStatsReport);
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
    this.send(id, "hello:");
  },
  send: function(id, message) {
    console.log("[bemtv] sending " + message + " to id " + id);
    var sendingTime = Date.now();
    this.swarm[id].send(JSON.stringify({"msg" : message, 'sendingTime': sendingTime}));
  },
  recv: function(id, message) {
    msg = JSON.parse(message);
    rtt = abs(new Date.now() - msg.sendingTime);
    console.log("[bemtv] received " + msg['msg'] + " from id " + id + " (rtt: " + rtt + "ms)");
  },
  swarmAdd: function(id, dc) {
    this.swarm[id] = rtc_bufferedchannel(dc, {calcCharSize: false});
    this.swarm[id].on('data', function(data) { this.onData(id, data); }.bind(this));
  },
  onData: function(id, data) {
    this.recv(id, data);
  },
  onDisconnect: function(id) {
    console.log("[bemtv] peer " + id + " disconnected.");
    delete this.swarm[id];
  },
  onStatsReport: function(metrics) {
    console.log("[bemtv] stats: ", metrics);
    this.metrics = metrics;
  }
});

module.exports = Peer;
