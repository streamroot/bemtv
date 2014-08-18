## TL;DR. Where's the code?

You can see it [here](http://github.com/bemtv/clappr-p2phls-plugin)

<div align=center><img src="http://bem.tv/img/logo.png" alt="BemTV logo"><br>
<h2>Hybrid CDN/P2P Architecture for HLS Broadcasts</h2>
</div>

## Introduction

BemTV is an attempt to scale live video streaming using peer-to-peer without the need of an external plug-in. It uses the powers of [WebRTC](http://www.webrtc.org/) to build swarms, enabling the possibility to flow chunks between users.

## How?

Almost all modern browsers [supports WebRTC](http://iswebrtcreadyyet.com/). BemTV acts intercepting the requests for chunks by the player, trying to fetch it from a peer swarm. If nobody serves, it will get it from the CDN. That's why it's called a [Hybrid Model](http://en.wikipedia.org/wiki/Peer-to-peer#Hybrid_models).

## Let me try

Open [BemTV website](http://bem.tv) and call friends near you to visit also. Click play and look at chunks being exchanged on the stats box!

## Development

Currently I'm working on a [clappr player](http://clappr.io) plugin that adds peer-to-peer support to HTTP Live Streaming (hls) streams. You can find the code and follow the progress by watching [this](https://github.com/bemtv/clappr-p2phls-plugin) repository.

## How to use it on my own HLS transmission?

Follow this [tutorial](https://github.com/bemtv/bemtv/wiki/tutorial).


## Publications

You can follow BemTV publications and academic works by watching [this](http://github.com/bemtv/publications) repository. I'll push papers and presentations related to BemTV progress.

## Author

[Flávio Ribeiro](http://br.linkedin.com/in/flavioribeiro) - flavio@bem.tv
