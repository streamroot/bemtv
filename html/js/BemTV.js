var quickconnect = require('rtc-quickconnect');
var buffered = require('rtc-bufferedchannel');
var freeice = require('freeice');

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
    var xhr = new XMLHttpRequest();
    var room = "bemtv";
    xhr.open('GET', BEMTV_ROOM_DISCOVER_URL, false);
    xhr.send();
    if (xhr.status == 200) {
      res = JSON.parse(xhr.response);
      console.log("Got room name " + res['room'] + " from city " + res['city'] + " and telco " + res['asn']);
      room = res['room'];
    }
    this.updateRoomName(room);
    return room;
  },

  onOpen: function(dc, id) {
    console.log("Peer entered the room: " + id);
    self.bufferedChannel = buffered(dc);
    self.bufferedChannel.on('data', function(data) { self.onData(id, data); });
  },

  onData: function(id, data) {
    splitted = data.split("|");
    console.log("Recv from (" + id + ") " + splitted[0] + " -> " + splitted[1]);
    if (splitted[0] == CHUNK_REQ && splitted[1] in self.chunksCache) {
      console.log(id + " want a chunk that I have, sending it.");
      self.bufferedChannel.send(CHUNK_OFFER + "|" + splitted[1] + "|" + self.chunksCache[splitted[1]]);
      self.updateBytesSendUsingP2P(self.chunksCache[splitted[1]].length);

    } else if (splitted[0] == CHUNK_OFFER && splitted[1] == self.currentUrl) {
      clearTimeout(self.requestTimeout);
      self.sendToPlayer(splitted[2]);
      self.updateBytesRecvFromP2P(splitted[2].length);
      console.log("P2P HAPPENING! GO GO GO");
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
      this.bufferedChannel.send(CHUNK_REQ + "|" + url);
      this.requestTimeout = setTimeout(function() { self.getFromCDN(url); }, P2P_TIMEOUT * 1000);
    } else {
      console.log("No peers available.");
      this.getFromCDN(url);
    }
  },

  getFromCDN: function(url) {
    console.log("Getting from CDN " + url);
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.responseType = 'arraybuffer';
    xhr.onload = this.readBytes;
    xhr.send();
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
