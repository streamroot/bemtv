var quickconnect = require('rtc-quickconnect');
var buffered = require('rtc-bufferedchannel');

BEMTV_SERVER = "http://server.bem.tv:8081"
ICE_SERVERS = [
     {url: 'stun:stun.l.google.com:19302'},
     {url:"turn:numb.viagenie.ca:3478", username: "flavio@bem.tv", credential: "bemtvpublic"}
]

var BemTV = function() {
  this._init();
}

BemTV.version = "1.0";

BemTV.prototype = {
  _init: function() {
    self = this;
    this.setupPeerConnection();
  },

  setupPeerConnection: function() {
    console.log("BemTV setup peer connection");
    this.connection = quickconnect(BEMTV_SERVER, {room: 'bemtv', iceServers: ICE_SERVERS});
    this.dataChannel = this.connection.createDataChannel("bemtv");
    this.dataChannel.on("peer:connect", this.onPeerConnect);
    this.dataChannel.on("peer:disconnect", this.onPeerDisconnect);
    this.dataChannel.on("bemtv:open", this.onOpen);
  },

  onOpen: function(dc, id) {
    console.log("Chegou gente, mandando string");
    this.bufferedChannel = buffered(dc);
    this.bufferedChannel.send("alo");
    this.bufferedChannel.on('data', function(data) { console.log("pbufferedeer " + id + "says:" + data); });
  },

  onPeerConnect: function(dataChannel, id) {
    console.log("Peer connected: " + id);
  },

  onPeerDisconnect: function(dataChannel, id) {
    console.log("Peer disconnected: " + id);
  },

  requestResource: function(url) {
    console.log("Resource requested by the player: " + url);
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.responseType = 'arraybuffer';
    xhr.onload = this.readBytes;
    xhr.send();
  },

  readBytes: function(e) {
    console.log("calling readBytes");
    var res = self.base64ArrayBuffer(e.currentTarget.response);
    var bemtvPlayer = document.getElementById('BemTVplayer');
    bemtvPlayer.resourceLoaded(res);
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
//module.exports = quickconnect;
//module.exports = buffered;

//var quickconnect = require('rtc-quickconnect');
//var buffered = require('rtc-bufferedchannel');
//
//var connection = quickconnect('http://server.bem.tv:8080', { room: 'buffer', debug: true,
//                                iceServers: [
//                                     {url: 'stun:stun.l.google.com:19302'},
//                                     {url:"turn:numb.viagenie.ca:3478", username: "flavio@bem.tv", credential: "bemtvpublic"}
//                                            ] });
//
//var datachannel = connection.createDataChannel("bemtv");
//
////connection.on('peer', function(pc, id, data, monitor) {
////    console.log('got a new friend, id: ' + id, pc);
////});
//
//datachannel.on("bemtv:open", function(dc, id) {
//        console.log('test dc open for peer: ' + id);
//        bufferedDc = buffered(dc);
//        //console.log(bufferedDc);
//        bufferedDc.send("sim!");
//        bufferedDc.onmessage = function(evt) { console.log("pbufferedeer " + id + "says:" + evt.data); };
//        bufferedDc.on('data', function(data) {
//                doc = document.getElementById("ae");
//                doc.innerHTML = "rolou ->" + data; });
//});
//
//datachannel.on('peer:connect', function(pc, id, data) {
//        console.log("Chegou um doidao novo: " + id);
//});
//
//datachannel.on('peer:disconnect', function(pc, id, data) {
//        console.log("Vazou um doidao: " + id);
//});
//
