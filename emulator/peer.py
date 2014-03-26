import m3u8
import time
import random
from log import Logger
from threading import Thread, Timer

POLLING_TIME = 4

logger = Logger()

class Peer(Thread):
    def __init__(self, id):
        Thread.__init__(self)
        self.id = id
        self.playlist = "http://hls-loop.appspot.com/playlist1.m3u8"
        self.current_playlist = []
        self.swarm = []
        self.cache = {}
        self.running = True
        self.stats = {'recvFromCDN': 0, 'recvFromP2P': 0, 'sentViaP2P': 0}
        self.start()

    def run(self):
        self.start_fetch_playlist(self.playlist)

    def start_fetch_playlist(self, playlist_url):
        while self.running:
            logger.info(self.id, "fetching playlist")
            playlist = [str(seg) for seg in m3u8.load(playlist_url).segments]
            if not self.current_playlist:
                self.current_playlist = playlist
            else:
                self.update_current_chunk(playlist)
                self.current_playlist = playlist
            time.sleep(POLLING_TIME)

    def update_current_chunk(self, playlist):
        diff = list(set(playlist) - set(self.current_playlist))
        if diff:
            self.chunk_lenght, self.current_chunk = diff[0].split("\n")
            self.download_chunk()

    def download_chunk(self):
        logger.info(self.id, "downloading current chunk (%s)" % (self.current_chunk))
        t = Timer(random.random() * 2, self._download_chunk)
        t.start()

    def _download_chunk(self):
        self.cache[self.current_chunk] = "chunk_blob_here"
        logger.info(self.id, "downloaded current chunk (%s)" % (self.current_chunk))

    def send_to(self, peer, msg):
        peer.recv(this.id, msg)

    def recv(self, id, msg):
        logger.info(self.id, "received from (%s): %s" % (id, msg))

    def add_peer(self, peer):
        self.swarm.append(peer)

    def kill(self):
        logger.info(self.id, "killing %s" % (self.stats))
        self.running = False


if __name__ == "__main__":
    peers = [Peer("eb5bbe4c-3b4a-41a8-9092-" + str(i) * 10) for i in range(10)]
    time.sleep(20)
    [p.kill() for p in peers]

