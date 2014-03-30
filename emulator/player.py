import m3u8
import time
import random
import peer
from log import Logger
from threading import Thread, Timer

logger = Logger()

class Player(Thread):
    def __init__(self):
        Thread.__init__(self)
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
        logger.info("player","Buffering")
        for segment in self.playlist[7:]:
            self.request_resource(segment)
        logger.info("player", "Buffer full")

    def start_polling_and_fetching_chunks(self):
        logger.info("player", "Fetching playlist and chunks every " + str(self.segment_duration) +  "seconds")
        while self.running:
            time.sleep(self.segment_duration)
            last_segments = [str(seg).split("\n")[1] for seg in m3u8.load(self.playlist_uri).segments][7:]
            [self.request_resource(seg) for seg in last_segments if seg not in self.player_buffer]

    def request_resource(self, segment):
        logger.info("player", "requesting " + segment);
        self.resource_loaded(segment)

    def resource_loaded(self, segment):
        logger.info("player", "resource loaded " + segment);
        self.player_buffer.append(segment)

if __name__ == "__main__":
    Player()
