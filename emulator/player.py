import m3u8
import time
import random
from peer import Peer
from log import Logger
from threading import Thread

logger = Logger()

class Player(Thread):
    def __init__(self):
        Thread.__init__(self)
        self.id = "eb5bbe4c-3b4a-41a8-9092-" + str(random.randint(0, 100))
        self.peer = Peer(self.id, self.resource_loaded)
        self.playlist_uri = "http://cdn.bem.tv/stream/soccer4sec/soccer/playlist.m3u8"
        self.player_buffer = []
        self.start()

    def run(self):
        segments = m3u8.load(self.playlist_uri).segments
        self.segment_duration = segments[0].duration
        self.playlist = [str(seg).split("\n")[1] for seg in segments]
        self.running = True
        self.startup()
        self.start_polling_and_fetching_chunks()

    def startup(self):
        logger.info(self.id ,"Player: Buffering")
        for segment in self.playlist[7:]:
            self.request_resource(segment)

    def start_polling_and_fetching_chunks(self):
        logger.info(self.id, "Player: Fetching playlist and chunks every " + str(self.segment_duration) +  "seconds")
        while self.running:
            time.sleep(self.segment_duration)
            last_segments = [str(seg).split("\n")[1] for seg in m3u8.load(self.playlist_uri).segments][7:]
            [self.request_resource(seg) for seg in last_segments if seg not in self.player_buffer]

    def request_resource(self, segment):
        logger.info(self.id, "Player: requesting " + segment);
        self.peer.download_chunk(segment)

    def resource_loaded(self, segment):
        logger.info(self.id, "Player: resource loaded " + segment);
        self.player_buffer.append(segment)

    def connect(self, other_player):
        self.peer.add_peer(other_player.peer)

    def shutdown(self):
        logger.info(self.id, "Player Stats:" + str(self.peer.stats)  + " Player buffer: " + str(sorted(self.player_buffer)))
        self.running = False

if __name__ == "__main__":
    players = [Player() for i in range(20)]
    for i in players:
        for j in players:
            if i.id != j.id:
                i.connect(j)
    time.sleep(5)
    [p.shutdown() for p in players]
    time.sleep(5)
    print "Total chunks downloaded from CDN: " + str(sum([x.peer.stats['recvFromCDN'] for x in players]))
    print "Total chunks downloaded from P2P: " + str(sum([x.peer.stats['recvFromP2P'] for x in players]))
    print "Total chunks sent from P2P: " + str(sum([x.peer.stats['sentViaP2P'] for x in players]))

