var quickconnect = require('rtc-quickconnect');
var buffered = require('rtc-bufferedchannel');
var freeice = require('freeice');
var utils = require('./Utils.js');

BEMTV_ROOM_DISCOVER_URL = "http://server.bem.tv:9000/room"
BEMTV_SERVER = "http://server.bem.tv:8080"
ICE_SERVERS = freeice();
CHUNK_REQ = "req"
CHUNK_OFFER = "offer"
P2P_TIMEOUT = 2.5 // in seconds
MAX_CACHE_SIZE = 4;

var BemTV = function() {
  this._init();
}

BemTV.version = "1.0";

BemTV.prototype = {
  _init: function() {
    self = this;
    this.room = this.discoverMyRoom();
    this.setupPeerConnection(this.room);
    this.chunksCache = {};
    this.swarm = {};
    this.bufferedChannel = undefined;
    this.requestTimeout = undefined;
  },

  setupPeerConnection: function(room) {
    connection = quickconnect(BEMTV_SERVER, {room: room, iceServers: ICE_SERVERS});
    dataChannel = connection.createDataChannel(room);
    dataChannel.on(room + ":open", this.onOpen);
    dataChannel.on("peer:leave",   this.onDisconnect);
  },

  discoverMyRoom: function() {
    var response = utils.request(BEMTV_ROOM_DISCOVER_URL);
    var room = response? JSON.parse(response)['room']: "bemtv";
    utils.updateRoomName(room);
    return room;
  },

  onOpen: function(dc, id) {
    console.log("Peer entered the room: " + id);
    self.swarm[id] = buffered(dc);
    self.swarm[id].on('data', function(data) { self.onData(id, data); });
    utils.updateSwarmSize(self.swarmSize());
  },

  onData: function(id, data) {
    var parsedData = utils.parseData(data);
    var resource = parsedData['resource'];

    if (self.isReq(parsedData) && resource in self.chunksCache) {
      console.log("Sending chunk " + resource + " to " + id);
      var offerMessage = utils.createMessage(CHUNK_OFFER, resource, self.chunksCache[resource]);
      self.swarm[id].send(offerMessage);
      utils.incrementCounter("chunksToP2P");

    } else if (self.isOffer(parsedData) && resource == self.currentUrl) {
      clearTimeout(self.requestTimeout);
      self.sendToPlayer(parsedData['chunk']);
      utils.incrementCounter("chunksFromP2P");
      console.log("P2P:" + parsedData['resource']);
    }
  },

  isReq: function(parsedData) {
    return parsedData['action'] == CHUNK_REQ;
  },

  isOffer: function(parsedData) {
    return parsedData['action'] == CHUNK_OFFER;
  },

  onDisconnect: function(id) {
    delete self.swarm[id];
    utils.updateSwarmSize(self.swarmSize());
  },

  requestResource: function(url) {
    if (url != this.currentUrl) {
      this.currentUrl = url;
      if (this.currentUrl in self.chunksCache) {
        console.log("Chunk is already on cache, getting from it");
        this.sendToPlayer(self.chunksCache[url]);
      }
      if (this.swarmSize() > 0) {
        this.getFromP2P(url);
      } else {
        console.log("No peers available.");
        this.getFromCDN(url);
      }
    } else {
      console.log("Skipping double downloads!");
    }
  },

  getFromP2P: function(url) {
    console.log("Trying to get from swarm " + url);
    var reqMessage = utils.createMessage(CHUNK_REQ, url);
    this.broadcast(reqMessage);
    this.requestTimeout = setTimeout(function() { self.getFromCDN(url); }, P2P_TIMEOUT * 1000);
  },

  getFromCDN: function(url) {
    console.log("Getting from CDN " + url);
    utils.request(url, this.readBytes, "arraybuffer");
  },

  readBytes: function(e) {
    var res = utils.base64ArrayBuffer(e.currentTarget.response);
    self.sendToPlayer(res);
    utils.incrementCounter("chunksFromCDN");
  },

  broadcast: function(msg) {
    console.log("Broadcasting request to peers");
    for (id in self.swarm) {
      self.swarm[id].send(msg);
    }
  },

  swarmSize: function() {
    return Object.keys(self.swarm).length;
  },

  sendToPlayer: function(data) {
    var bemtvPlayer = document.getElementById('BemTVplayer');
    self.chunksCache[self.currentUrl] = data;
    self.currentUrl = undefined;
    bemtvPlayer.resourceLoaded(data);
    self.checkCacheSize();
  },

  checkCacheSize: function() {
    var cacheKeys = Object.keys(self.chunksCache);
    if (cacheKeys.length > MAX_CACHE_SIZE) {
      var key = self.chunksCache;
      console.log("Removing from cache: " + cacheKeys[0]);
      delete self.chunksCache[cacheKeys[0]];
    }
  },
}

module.exports = BemTV;
