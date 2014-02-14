function BemTVConnector() {
  this._init();
}

BemTVConnector.version = "1.0";

BemTVConnector.prototype = {
  _init: function() {
    self = this;
        this.requests = {} // <url, peer5.Request>
    this.current_url = "";
    this.options = {};
    this.cyclicHTTP = false;
    if (window.location.hash == "#leech") {
      console.log("Leech found. Forcing downloadMode to p2p");
      self.options = {downloadMode: 'p2p'};
    }

    if (window.location.hash == "#http") {
        console.log("Forcing http (cyclic");
        self.cyclicHTTP = true;
    }




  },

  prefetchP2P: function(url) {
      var number = url.substring(url.lastIndexOf("_")+1, url.length-3);
      var reqs = 3;

      for (var i = 1;i < reqs; i++) {
          var next_url = url.substring(0, url.lastIndexOf("_")+1)  + (parseInt(number) + i) + '.ts';
          this.requestURL(next_url, {downloadMode: 'p2p'}); //req in p2p
      }
  },

  prefetchHTTP: function(url) {
      var number = url.substring(url.lastIndexOf("_")+1, url.length-3);
      var next_url = url.substring(0, url.lastIndexOf("_")+1)  + (parseInt(number) + 1) + '.ts';
      this.requestURL(next_url); //req in http
  },

  requestResource: function(url) {
    console.log("Resource requested: " + url);
    this.current_url = url;
        this.requestURL(url);
  },

    requestURL: function(url, options) {
        if(this.requests[url]) {
            // stop current request to modify it
            if (this.requests[url].downloadMode == 2) { //if p2p req, abort
                console.log('aborting ' + url);
                this.requests[url].abort();
            } else {
                return;
            }

        }

        if (!options) {
            console.log("HTTP Request " + url);
            options = self.options;
        } else {
            console.log("P2P Request: " + url);
        }


        this.requests[url] = new peer5.Request(options);
        this.requests[url].open("GET", url);
        this.requests[url].onload = function(e) {
            if (self.cyclicHTTP) self.prefetchHTTP(url);
            self.readBytes(self, e, url);
        };

        this.requests[url].onerror = function(e) {
            console.warn(e);
            delete self.requests[url];
        };


        this.requests[url].onprogress = function(e) {
      var bytesFromCDN = document.getElementById("bytesFromCDN");
      var bytesFromP2P = document.getElementById("bytesFromP2P");

      bytesFromCDN.innerText = parseInt(bytesFromCDN.innerText) + (e.loadedHTTP);
      bytesFromP2P.innerText = parseInt(bytesFromP2P.innerText) + (e.loadedP2P);
    }

        this.requests[url].send();
  },

  readBytes: function(self, e, url) {
    // this xhr should be remove when P2PXHR fix currentTarget return
//    if (url == self.current_url) {
      console.log("Current URL downloaded");
      var xhr = new XMLHttpRequest();
      xhr.open('GET', e.currentTarget.response, true);
      xhr.overrideMimeType("text/plain; charset=x-user-defined");
      xhr.onload = function(e) {
                var t = Date.now();
        var res = base64ArrayBuffer(str2ab2(xhr.response, xhr.response.length));
        self.loadChunk(res);
                console.log("Loading " + url + ' took ' + (Date.now() - t));
          self.prefetchP2P(url);

      }
      xhr.send();
//    }
  },

  loadChunk: function(chunk) {
     document['BemTVplayer'].resourceLoaded(chunk);
  }
}

function str2ab2(str, len) {
  var buf = new ArrayBuffer(len); // 2 bytes for each char
  var bufView = new Uint8Array(buf);
  for (var i=0; i<len; i++) {
    bufView[i] = str.charCodeAt(i);
  }
  return buf;
}

function base64ArrayBuffer(arrayBuffer) {
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
