var quickconnect = require('rtc-quickconnect');
var buffered = require('rtc-bufferedchannel');
var freeice = require('freeice');
var utils = require('./Utils.js');

/* Configuration */
BEMTV_ROOM_DISCOVER_URL = "http://server.bem.tv/room"
BEMTV_SERVER = "http://server.bem.tv:8080"
ICE_SERVERS = freeice();
DESIRE_TIMEOUT = 0.7; // in seconds
REQ_TIMEOUT = 3; // in seconds
MAX_CACHE_SIZE = 10;


/* Header protocol messages */
CHUNK_REQ = "req"
CHUNK_DESIRE = "des"
CHUNK_DESACK = "desack"
CHUNK_OFFER = "offer"

/* Peer States */
PEER_IDLE = 0
PEER_WAITING = 1
PEER_UPLOADING = 2
PEER_DOWNLOADING = 3
PEER_DESIRING = 4

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
    this.requestTimeout = undefined;
    this.currentState = PEER_IDLE;
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
    self.swarm[id] = buffered(dc, {calcCharSize: false});
    self.swarm[id].on('data', function(data) { self.onData(id, data); });
    utils.updateSwarmSize(self.swarmSize());
  },

  onData: function(id, data) {
    var parsedData = utils.parseData(data);
    var resource = parsedData['resource'];

    if (self.isDesire(parsedData) && resource in self.chunksCache) {
      self.currentState = PEER_UPLOADING;
      var desAckMessage = utils.createMessage(CHUNK_DESACK, resource);
      self.swarm[id].send(desAckMessage);

    } else if (self.isDesAck(parsedData) && self.currentState == PEER_DESIRING) {
      clearTimeout(self.requestTimeout);
      self.currentState = PEER_DOWNLOADING;
      var reqMessage = utils.createMessage(CHUNK_REQ, resource);
      self.swarm[id].send(reqMessage);
      this.requestTimeout = setTimeout(function() { self.getFromCDN(resource); }, REQ_TIMEOUT *1000);

    } else if (self.isReq(parsedData)) { // what happens if the chunk is removed from cache on this step?
      var offerMessage = utils.createMessage(CHUNK_OFFER, resource, self.chunksCache[resource]);
      self.swarm[id].send(offerMessage);
      utils.incrementCounter("chunksToP2P");
      self.currentState = PEER_IDLE;

    } else if (self.isOffer(parsedData) && resource == self.currentUrl) {
      clearTimeout(self.requestTimeout);
      self.sendToPlayer(parsedData['chunk']);
      utils.incrementCounter("chunksFromP2P");
      self.currentState = PEER_IDLE;
    }
  },

  isReq: function(parsedData) {
    return parsedData['action'] == CHUNK_REQ;
  },

  isOffer: function(parsedData) {
    return parsedData['action'] == CHUNK_OFFER;
  },

  isDesire: function(parsedData) {
    return parsedData['action'] == CHUNK_DESIRE;
  },

  isDesAck: function(parsedData) {
    return parsedData['action'] == CHUNK_DESACK;
  },

  onDisconnect: function(id) {
    delete self.swarm[id];
    utils.updateSwarmSize(self.swarmSize());
  },

  requestResource: function(url) {
    if (url != this.currentUrl) {
      this.currentUrl = url;
      if (this.swarmSize() > 0) {
        this.getFromP2P(url);
      } else {
        this.getFromCDN(url);
      }
    }
  },

  getFromP2P: function(url) {
    this.currentState = PEER_DESIRING;
    var desMessage = utils.createMessage(CHUNK_DESIRE, url);
    this.broadcast(desMessage);
    this.requestTimeout = setTimeout(function() { self.getFromCDN(url); }, DESIRE_TIMEOUT * 1000);
  },

  getFromCDN: function(url) {
    utils.request(url, this.readBytes, "arraybuffer");
    this.currentState = PEER_IDLE;
  },

  readBytes: function(e) {
    var res = utils.base64ArrayBuffer(e.currentTarget.response);
    self.sendToPlayer(res);
    utils.incrementCounter("chunksFromCDN");
  },

  broadcast: function(msg) {
    for (id in self.swarm) {
      self.swarm[id].send(msg);
    }
  },

  swarmSize: function() {
    return Object.keys(self.swarm).length;
  },

  sendToPlayer: function(data) {
    var bemtvPlayer = document.getElementsByTagName("embed")[0] || document.getElementById("BemTVplayer");
    self.chunksCache[self.currentUrl] = data;
    self.currentUrl = undefined;
    bemtvPlayer.resourceLoaded(data);
    self.checkCacheSize();
  },

  checkCacheSize: function() {
    var cacheKeys = Object.keys(self.chunksCache);
    if (cacheKeys.length > MAX_CACHE_SIZE) {
      delete self.chunksCache[cacheKeys[0]];
    }
  },
}

module.exports = BemTV;
