![Alt text](http://bem.tv/static/bemtvgithub.png)

A hybrid Peer-to-Peer Model to HTTP Live Streaming (HLS) Content Delivery Networks


## Introdution

BemTV is an attempt to scale live video streaming using P2P without the need of an external plug-in. It uses the powers of [WebRTC](http://www.webrtc.org/) to build swarms considering peer's geolocation and their internet carriers.

## How?

Almost all modern browsers [supports WebRTC](http://iswebrtcreadyyet.com/). However, except Safari on MacOS, none of them supports HTTP Live Streaming (HLS). I've solved this issue using a Flash-based player with an open source plugin that empowers the player with HLS playback.

BemTV acts intercepting the requests for chunks by the player, trying to fetch it from a peer swarm. If nobody serves, it will get it from the CDN. That's why it's called a [Hybrid Model](http://en.wikipedia.org/wiki/Peer-to-peer#Hybrid_models).

## Let me try
Actually the playback is still a little weird (I'm experiencing some stucks and rebuffering events), but I'm trying to improve it. Try calling a friend near you that uses the same internet carrier and have fun.

[BemTV on OSMF-based player](http://bem.tv/player.html)

[BemTV on HLSProvider chromeless player](http://bem.tv/hlsprovider)

