var quickconnect = require('rtc-quickconnect');
var buffered = require('rtc-bufferedchannel');
var freeice = require('freeice');
var utils = require('./Utils.js');

BEMTV_ROOM_DISCOVER_URL = "http://server.bem.tv:9000/room"
BEMTV_SERVER = "http://server.bem.tv:8080"
ICE_SERVERS = freeice();
CHUNK_REQ = "req"
CHUNK_OFFER = "offer"
P2P_TIMEOUT = 1.2 // in seconds

var BemTV = function() {
  this._init();
}

BemTV.version = "1.0";

BemTV.prototype = {
  _init: function() {
    self = this;
    this.room = this.discoverMyRoom();
    this.setupPeerConnection();
    this.chunksCache = {};
    this.swarmSize = 0;
    this.bufferedChannel = undefined;
    this.requestTimeout = undefined;
  },

  setupPeerConnection: function() {
    this.connection = quickconnect(BEMTV_SERVER, {room: this.room, iceServers: ICE_SERVERS});
    this.dataChannel = this.connection.createDataChannel(this.room);
    this.dataChannel.on(this.room + ":open", this.onOpen);
    this.dataChannel.on("peer:connect", this.onConnect);
    this.dataChannel.on("peer:leave", this.onDisconnect);
  },

  discoverMyRoom: function() {
    var response = utils.request(BEMTV_ROOM_DISCOVER_URL);
    var room = response? JSON.parse(response)['room']: "bemtv";
    utils.updateRoomName(room);
    return room;
  },

  onOpen: function(dc, id) {
    console.log("Peer entered the room: " + id);
    self.bufferedChannel = buffered(dc);
    self.bufferedChannel.on('data', function(data) { self.onData(id, data); });
  },

  onData: function(id, data) {
    var parsedData = utils.parseData(data);
    if (parsedData['action'] == CHUNK_REQ && parsedData['resource'] in self.chunksCache) {
      console.log("Sending chunk " + parsedData['resource'] + " to " + id);
      var resource = parsedData['resource'];
      var offerMessage = utils.createMessage(CHUNK_OFFER, resource, self.chunksCache[resource]);
      self.bufferedChannel.send(offerMessage);
      utils.updateBytesSendUsingP2P(self.chunksCache[resource].length);

    } else if (parsedData['action'] == CHUNK_OFFER && parsedData['resource'] == self.currentUrl) {
      clearTimeout(self.requestTimeout);
      self.sendToPlayer(parsedData['chunk']);
      utils.updateBytesRecvFromP2P(parsedData['chunk'].length);
      console.log("Chunk " + parsedData['resource'] + " received from p2p");
    }
  },

  onDisconnect: function(id) {
    self.swarmSize -= 1;
    utils.updateSwarmSize(self.swarmSize);
  },

  onConnect: function(id) {
    self.swarmSize += 1;
    utils.updateSwarmSize(self.swarmSize);
  },

  requestResource: function(url) {
    if (url != this.currentUrl) {
      this.currentUrl = url;
      if (this.swarmSize > 0) {
        console.log("Trying to get from swarm");
        var reqMessage = utils.createMessage(CHUNK_REQ, url);
        this.bufferedChannel.send(reqMessage);
        this.requestTimeout = setTimeout(function() { self.getFromCDN(url); }, P2P_TIMEOUT * 1000);
      } else {
        console.log("No peers available.");
        this.getFromCDN(url);
      }
    } else {
      console.log("Skipping double downloads!");
    }

  },

  getFromCDN: function(url) {
    console.log("Getting from CDN " + url);
    utils.request(url, this.readBytes, "arraybuffer");
  },

  readBytes: function(e) {
    var res = utils.base64ArrayBuffer(e.currentTarget.response);
    self.sendToPlayer(res);
    utils.updateBytesFromCDN(res.length);
  },

  sendToPlayer: function(data) {
    var bemtvPlayer = document.getElementById('BemTVplayer');
    self.chunksCache[self.currentUrl] = data;
    self.currentUrl = undefined;
    bemtvPlayer.resourceLoaded(data);
  },
}

module.exports = BemTV;
