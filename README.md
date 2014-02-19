![Alt text](http://bem.tv/static/bemtvgithub.png)

A hybrid Peer-to-Peer Model to HTTP Live Streaming (HLS) Content Delivery Networks


## Introdution

BemTV is an attempt to scale live video streaming using P2P without the need of an external plug-in. It uses the powers of [WebRTC](http://www.webrtc.org/) to build swarms considering peer's geolocation and their internet carriers.

## How?

Almost all modern browsers [supports WebRTC](http://iswebrtcreadyyet.com/). However, except Safari on MacOS, none of them supports HTTP Live Streaming (HLS). I've solved this issue using a Flash-based player with an open source plugin that empowers the player with HLS playback.

BemTV acts intercepting the requests for chunks by the player, trying to fetch it from a peer swarm. If nobody serves, it will get it from the CDN. That's why it's called a [Hybrid Model](http://en.wikipedia.org/wiki/Peer-to-peer#Hybrid_models).

## Let me try
Actually the playback is still a little weird (I'm experiencing some stucks and rebuffering events), but I'm trying to improve it. Try calling a friend near you that uses the same internet carrier and have fun.

[BemTV on OSMF-based player](http://bem.tv/player.html) (deprecated)

[BemTV on HLSProvider chromeless player](http://bem.tv/hlsprovider.html)

## Building on your machine

First, you'll need ruby/rubygems and node/npm installed. Then:

```
$ gem install bundler
$ bundle
```

This will install necessary gems to build our flash-based player. We'll also install rake, a tool that handles build commands. Let's build everything:

```
$ rake build_all
```

Now you have a snapshot of BemTV.js, our ChromelessPlayer and a hlsprovider.html example on html/ path. Point your favorite http server to this directory and happy hacking.

You can also build just BemTV.js:

```
$ rake build_js
```

Or the swf player:

```
$ rake build_swf
```

Pull requests are encouraged.

## License

Copyright (C) 2014 Flávio Ribeiro < email at flavioribeiro.com >

BemTV is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

BemTV is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with BemTV. If not, see http://www.gnu.org/licenses/.

All files in BemTV are under GPL unless otherwise noted in file's header. Some files may be sublicensed.


