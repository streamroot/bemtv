var quickconnect = require('rtc-quickconnect');
var buffered = require('rtc-bufferedchannel');
var freeice = require('freeice');
var utils = require('./Utils.js');

BEMTV_ROOM_DISCOVER_URL = "http://server.bem.tv:9000/room"
BEMTV_SERVER = "http://server.bem.tv:8080"
ICE_SERVERS = freeice();
CHUNK_REQ = "req"
CHUNK_OFFER = "offer"
P2P_TIMEOUT = 2 // in seconds

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
    this.updateRoomName(room);
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
      self.updateBytesSendUsingP2P(self.chunksCache[resource].length);

    } else if (parsedData['action'] == CHUNK_OFFER && parsedData['resource'] == self.currentUrl) {
      clearTimeout(self.requestTimeout);
      self.sendToPlayer(parsedData['chunk']);
      self.updateBytesRecvFromP2P(parsedData['chunk'].length);
      console.log("Chunk " + parsedData['resource'] + " received from p2p");
    }
  },

  onDisconnect: function(id) {
    self.swarmSize -= 1;
    self.updateSwarmSize(self.swarmSize);
  },

  onConnect: function(id) {
    self.swarmSize += 1;
    self.updateSwarmSize(self.swarmSize);
  },

  requestResource: function(url) {
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
  },

  getFromCDN: function(url) {
    console.log("Getting from CDN " + url);
    utils.request(url, this.readBytes, "arraybuffer");
  },

  readBytes: function(e) {
    var res = self.base64ArrayBuffer(e.currentTarget.response);
    self.sendToPlayer(res);
    self.updateBytesFromCDN(res.length);
  },

  sendToPlayer: function(data) {
    var bemtvPlayer = document.getElementById('BemTVplayer');
    self.chunksCache[self.currentUrl] = data;
    self.currentUrl = undefined;
    bemtvPlayer.resourceLoaded(data);
  },

  updateBytesFromCDN: function(bytes) {
    var bytesFromCDN = document.getElementById("bytesFromCDN");
    bytesFromCDN.innerHTML = parseInt(bytesFromCDN.innerHTML) + (bytes);
  },

  updateBytesRecvFromP2P: function(bytes) {
    var bytesFromP2P = document.getElementById("bytesFromP2P");
    bytesFromP2P.innerHTML = parseInt(bytesFromP2P.innerHTML) + (bytes);
  },

  updateBytesSendUsingP2P: function(bytes) {
    var bytesToP2P = document.getElementById("bytesToP2P");
    bytesToP2P.innerHTML = parseInt(bytesToP2P.innerHTML) + (bytes);
  },

  updateRoomName: function(name) {
    var roomName = document.getElementById("roomName");
    roomName.innerHTML = name;

  },

  updateSwarmSize: function(size) {
    var swarmSize = document.getElementById("swarmSize");
    swarmSize.innerHTML = size;
  },

  base64ArrayBuffer: function(arrayBuffer) {
    var base64    = ''
    var encodings = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    var bytes         = new Uint8Array(arrayBuffer)
    var byteLength    = bytes.byteLength
    var byteRemainder = byteLength % 3
    var mainLength    = byteLength - byteRemainder
    var a, b, c, d, chunk

    for (var i = 0; i < mainLength; i = i + 3) {
      chunk = (bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2]
      a = (chunk & 16515072) >> 18 // 16515072 = (2^6 - 1) << 18
      b = (chunk & 258048)   >> 12 // 258048   = (2^6 - 1) << 12
      c = (chunk & 4032)     >>  6 // 4032     = (2^6 - 1) << 6
      d = chunk & 63               // 63       = 2^6 - 1
      base64 += encodings[a] + encodings[b] + encodings[c] + encodings[d]
    }

    if (byteRemainder == 1) {
      chunk = bytes[mainLength]
      a = (chunk & 252) >> 2 // 252 = (2^6 - 1) << 2
      b = (chunk & 3)   << 4 // 3   = 2^2 - 1
      base64 += encodings[a] + encodings[b] + '=='
    } else if (byteRemainder == 2) {
      chunk = (bytes[mainLength] << 8) | bytes[mainLength + 1]
      a = (chunk & 64512) >> 10 // 64512 = (2^6 - 1) << 10
      b = (chunk & 1008)  >>  4 // 1008  = (2^6 - 1) << 4
      c = (chunk & 15)    <<  2 // 15    = 2^4 - 1
      base64 += encodings[a] + encodings[b] + encodings[c] + '='
    }

    return base64;
  }

}

module.exports = BemTV;
