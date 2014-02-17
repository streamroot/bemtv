module.exports =  {

  parseData: function(data) {
    var parsedData = {};
    var splitted = data.split("|");
    parsedData['action'] = splitted[0];
    parsedData['resource'] = splitted[1];
    if (splitted.length == 3) {
      parsedData['chunk'] = splitted[2];
    }
    return parsedData;
  },

  createMessage: function(action, resource, chunk) {
    if (chunk) {
      return action + "|" + resource + "|" + chunk;
    } else {
      return action + "|" + resource;
    }
  },

  request: function(url, callback, responseType) {
    var xhr = new XMLHttpRequest();
    xhr.open("GET", url, callback? true: false);
    if (responseType) {
      xhr.responseType = responseType;
    }
    if (callback) {
      xhr.onload = callback;
      xhr.send();
    } else {
      xhr.send();
      return xhr.status == 200? xhr.response: "";
    }
  },

  incrementCounter: function(element) {
    var el = document.getElementById(element);
    el.innerHTML = parseInt(el.innerHTML) + 1;
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
