var utils = require("./utils.js");

module.exports = function() {
  self.addEventListener('message', function(e) {
    utils.request(e.data, self.resourceLoaded.bind(self), 'arraybuffer');
  }, false);

  self.resourceLoaded = function(e) {
    self.postMessage(utils.base64ArrayBuffer(e.currentTarget.response));
  }
}
