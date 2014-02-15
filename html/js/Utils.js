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
  }
}
