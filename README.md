![Alt text](http://bem.tv/static/bemtvgithub.png)

Hybrid CDN/Peer-to-Peer Architecture for Online Live Streams (HLS)


## Introduction

BemTV is an attempt to scale live video streaming using peer-to-peer without the need of an external plug-in. It uses the powers of [WebRTC](http://www.webrtc.org/) to build swarms, enabling the possibility to flow chunks between users.

## How?

Almost all modern browsers [supports WebRTC](http://iswebrtcreadyyet.com/). BemTV acts intercepting the requests for chunks by the player, trying to fetch it from a peer swarm. If nobody serves, it will get it from the CDN. That's why it's called a [Hybrid Model](http://en.wikipedia.org/wiki/Peer-to-peer#Hybrid_models).

## Let me try

Playback is still a little weird (I'm experiencing some stucks and rebuffering events), but I'm improving it. Try calling a friend near you that uses the same internet carrier and have fun.

[BemTV on flashls chromeless player](http://bem.tv/demo.html)


## Development

Currently I'm working on a [clappr player](http://clappr.io) plugin that adds peer-to-peer support to HTTP Live Streaming (hls) streams. You can find the code and follow the progress by watching [this](https://github.com/bemtv/clappr-p2phls-plugin) repository.


## Publications

You can follow BemTV publications and academic works by watching [this](http://github.com/bemtv/publications) repository. I'll push papers and presentations related to BemTV progress.

## Author

[Flávio Ribeiro](http://br.linkedin.com/in/flavioribeiro) - flavio@bem.tv
