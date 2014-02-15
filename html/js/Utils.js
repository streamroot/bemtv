module.exports =  {

  parseData: function(data) {
    parsedData = {};
    splitted = data.split("|");
    parsedData['action'] = splitted[0];
    parsedData['resource'] = splitted[1];
    if (splitted.length == 3) {
      parsedData['chunk'] = splitted[2];
    }
    return parsedData;
  },

  offerMessage: function(action, resource, chunk) {
    return action + "|" + resource + "|" + chunk;
  }
}
