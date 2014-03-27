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
        self.playlist = "http://cdn.bem.tv/stream/soccer4sec/soccer/playlist.m3u8"
        self.current_playlist = []
        self.swarm = {}
        self.cache = {}
        self.running = True
        self.stats = {'recvFromCDN': 0, 'recvFromP2P': 0, 'sentViaP2P': 0}
        self.start()

    def run(self):
        self.start_fetch_playlist(self.playlist)

    def start_fetch_playlist(self, playlist_url):
        while self.running:
            playlist = [str(seg) for seg in m3u8.load(playlist_url).segments]
            if not self.current_playlist:
                self.current_playlist = playlist
            else:
                self.update_current_chunk(playlist)
                self.current_playlist = playlist
            time.sleep(POLLING_TIME * random.random())

    def update_current_chunk(self, playlist):
        diff = list(set(playlist) - set(self.current_playlist))
        if diff and diff not in self.cache.keys():
            self.chunk_lenght, self.current_chunk = diff[0].split("\n")
            self.download_chunk()

    def download_chunk(self):
        logger.info(self.id, "downloading current chunk (%s)" % (self.current_chunk))
        self.timer = Timer(2, self._download_chunk)
        self.broadcast("DES:" + self.current_chunk)
        self.timer.start()

    def broadcast(self, msg):
        for peer_id in self.swarm.keys():
            self.send_to(peer_id, msg)

    def _download_chunk(self):
        self.cache[self.current_chunk] = "chunk_from_cdn"
        self.stats["recvFromCDN"] += 1
        logger.info(self.id, "downloaded current chunk (%s)" % (self.current_chunk))
        self.current_chunk = None

    def send_to(self, id, msg):
        self.swarm[id].recv(self.id, msg)

    def recv(self, id, msg):
        splitted = msg.split(":")

        if splitted[0] == 'DES':
            logger.info(self.id, "DES received for " + splitted[1] + ", cache: "
                    + str(self.cache))
            if splitted[1] in self.cache:
                self.send_to(id, "DESACK:" + splitted[1])

        if splitted[0] == 'DESACK':
            self.send_to(id, "REQ:" + splitted[1])
            self.timer.cancel()

        if splitted[0] == 'REQ':
            self.send_to(id, 'OFFER:' + splitted[1] + ":chunk_from_p2p")
            self.stats['sentViaP2P'] +=1

        if splitted[0] == "OFFER":
            logger.info(self.id, "Yeah! from p2p! %s from %s" % (splitted[1],id))
            self.cache[splitted[1]] = splitted[2]
            self.stats['recvFromP2P'] +=1

    def add_peer(self, peer):
        logger.info(self.id, "connected to " + peer.id);
        self.swarm[peer.id] = peer

    def kill(self):
        logger.info(self.id, "killing %s" % (self.stats))
        self.running = False


if __name__ == "__main__":
#    p1 = Peer("eb5bbe4c-3b4a-41a8-9092-000")
#    p2 = Peer("eb5bbe4c-3b4a-41a8-9092-555")
#    p3 = Peer("eb5bbe4c-3b4a-41a8-9092-999")
#    p1.add_peer(p2)
#    p2.add_peer(p1)
#
#    p1.add_peer(p3)
#    p3.add_peer(p1)
#
#    p2.add_peer(p3)
#    p3.add_peer(p3)
#
#    time.sleep(20)
#    p1.kill()
#    p2.kill()
#    p3.kill()
    peers = [Peer("eb5bbe4c-3b4a-41a8-9092-" + str(i) * 10) for i in range(4)]
    for p in peers:
        for j in peers:
            if p.id != j.id:
                p.add_peer(j)
                j.add_peer(p)

    time.sleep(20)
    [p.kill() for p in peers]

