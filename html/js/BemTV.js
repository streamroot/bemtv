var quickconnect = require('rtc-quickconnect');
var buffered = require('rtc-bufferedchannel');

BEMTV_SERVER = "http://server.bem.tv:8081"
ICE_SERVERS = [
     {url: 'stun:stun.l.google.com:19302'},
     {url:"turn:numb.viagenie.ca:3478", username: "flavio@bem.tv", credential: "bemtvpublic"}
]
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
    this.setupPeerConnection();
    this.chunksCache = {};
    this.swarmSize = 0;
    this.bufferedChannel = undefined;
    this.requestTimeout = undefined;
  },

  setupPeerConnection: function() {
    this.connection = quickconnect(BEMTV_SERVER, {room: 'bemtv', iceServers: ICE_SERVERS});
    this.dataChannel = this.connection.createDataChannel("bemtv");
    this.dataChannel.on("bemtv:open", this.onOpen);
    this.dataChannel.on("peer:connect", this.onConnect);
    this.dataChannel.on("peer:leave", this.onDisconnect);
  },

  onOpen: function(dc, id) {
    console.log("Peer entered the room: " + id);
    self.bufferedChannel = buffered(dc);
    self.bufferedChannel.on('data', function(data) { self.onData(id, data); });
  },

  onData: function(id, data) {
    splitted = data.split("|");
    if (splitted[0] == CHUNK_REQ && splitted[1] in self.chunksCache) {
      console.log(id + " want " + splitted[1] + ", sending it.");
      self.bufferedChannel.send(CHUNK_OFFER + "|" + splitted[1] + "|" + self.chunksCache[splitted[1]]);

    } else if (splitted[0] == CHUNK_OFFER && splitted[1] == self.currentUrl) {
      console.log("P2P HAPPENING! GO GO GO");
      clearTimeout(self.requestTimeout);
      self.sendToPlayer(splitted[2]);
      self.updateBytesFromP2P(splitted[2].length);
    }
  },

  onDisconnect: function(id) {
    console.log("Peer disconnected");
    self.swarmSize -= 1;
  },

  onConnect: function(id) {
    console.log("Peer connected");
    self.swarmSize += 1;
  },

  requestResource: function(url) {
    console.log("Resource requested by the player: " + url);
    this.currentUrl = url;
    if (this.swarmSize > 0) {
      this.bufferedChannel.send(CHUNK_REQ + "|" + url);
      this.requestTimeout = setTimeout(function() { self.getFromCDN(url); }, P2P_TIMEOUT * 1000);
    } else {
      console.log("No peers available.");
      this.getFromCDN(url);
    }
  },

  getFromCDN: function(url) {
    console.log("Getting from CDN");
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
    bytesFromCDN.innerText = parseInt(bytesFromCDN.innerText) + (bytes);
  },

  updateBytesFromP2P: function(bytes) {
    var bytesFromP2P = document.getElementById("bytesFromP2P");
    bytesFromP2P.innerText = parseInt(bytesFromP2P.innerText) + (bytes);
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
