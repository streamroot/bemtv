function PlayerEmbed(parameterNames, parameters) {
  for (var i = 0; i < parameterNames.length; i++) {
      var parameterName = parameterNames[i];
      parameters[parameterName] = pqs.param(parameterName) ||
      parameters[parameterName];
  }

  var wmodeValue = "direct";
  var wmodeOptions = ["direct", "opaque", "transparent", "window"];
  if (parameters.hasOwnProperty("wmode"))
  {
    if (wmodeOptions.indexOf(parameters.wmode) >= 0)
    {
      wmodeValue = parameters.wmode;
    }
    delete parameters.wmode;
  }

  swfobject.embedSWF(
    "static/StrobeMediaPlayback.swf"
    , "BemTVplayer"
    , 640
    , 480
    , "10.1.0"
    , "expressInstall.swf"
    , parameters
    , {
              allowFullScreen: "true",
              wmode: wmodeValue
          }
    , {
              name: "BemTVplayer"
          }
  );

//   function onMediaPlaybackError(playerId, code, message, detail)
//   {
//    alert(playerId + "\n\n" + code + "\n" + message + "\n" + detail);
//   }
}
