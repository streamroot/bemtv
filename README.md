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

## How to build the plugins?

Follow this [tutorial](https://github.com/bemtv/bemtv/wiki/tutorial).

## Development

Currently I'm working on a [clappr player](http://clappr.io) plugin that adds peer-to-peer support to HTTP Live Streaming (hls) streams. You can find the code and follow the progress by watching [this](https://github.com/bemtv/clappr-p2phls-plugin) repository.

## Publications

You can follow BemTV publications and academic works by watching [this](http://github.com/bemtv/publications) repository. I'll push papers and presentations related to BemTV progress.

## Questions/Support

Post your question at our Google Groups discussion list: https://groups.google.com/d/forum/bemtv

# Contribute

If you'd like to support the development of this project, consider make a donation.

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=BWQTD9JLRTNF6&lc=BR&item_name=BemTV%20CDN%2fP2P%20Architecture%20for%20HLS%20Broadcasts&item_number=bemtv&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted)

## Author

[Flávio Ribeiro](http://br.linkedin.com/in/flavioribeiro) - flavio@bem.tv
