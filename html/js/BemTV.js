var quickconnect = require('rtc-quickconnect');
var buffered = require('rtc-bufferedchannel');

BEMTV_SERVER = "http://server.bem.tv:8080"
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
    console.log("Peer connected: " + id);
  },


  requestResource: function(url) {
    console.log("Resource requested by the player: " + url);
    xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.responseType = 'arraybuffer';
    xhr.onload = this.readBytes;
    xhr.send();
  },

  readBytes: function(e) {
    res = Base64ArrayBuffer(e.currentTarget.response);
    document['BemTVplayer'].resourceLoaded(res);
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
