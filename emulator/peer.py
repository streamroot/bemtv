import time
import random
from log import Logger
from threading import Timer

logger = Logger()

class Peer(object):
    def __init__(self, id, resource_loaded_callback):
        self.id = id
        self.swarm = {}
        self.cache = {}
        self.desack_sent = False
        self.running = True
        self.stats = {'recvFromCDN': 0, 'recvFromP2P': 0, 'sentViaP2P': 0}
        self.resource_loaded_callback = resource_loaded_callback

    def download_chunk(self, segment):
        logger.info(self.id, "downloading chunk (%s)" % (segment))
        self.timer = Timer(random.randint(0,3), self._download_chunk, [segment])
        self.broadcast("DES:" + segment)
        self.timer.start()

    def broadcast(self, msg):
        for peer_id in self.swarm.keys():
            self.send_to(peer_id, msg)

    def _download_chunk(self, segment):
        self.cache[segment] = "chunk_from_cdn"
        self.stats["recvFromCDN"] += 1
        logger.info(self.id, "No! from CDN! %s" % segment)
        self.received_chunk(segment)

    def received_chunk(self, segment):
        logger.info(self.id, "downloaded chunk (%s: %s)" % (segment, self.cache[segment]))
        self.resource_loaded_callback(segment)

    def send_to(self, id, msg):
        self.swarm[id].recv(self.id, msg)

    def recv(self, id, msg):
        splitted = msg.split(":")

        if splitted[0] == 'DES':
            logger.info(self.id, "DES received for " + splitted[1] + ", cache: " + str(self.cache.keys()))
            if splitted[1] in self.cache:
                self.send_to(id, "DESACK:" + splitted[1])

        if splitted[0] == 'DESACK':
            if splitted[1] not in self.cache.keys() and not self.desack_sent:
                self.desack_sent = True
                self.send_to(id, "REQ:" + splitted[1])
                self.timer.cancel()

        if splitted[0] == 'REQ':
            self.send_to(id, 'OFFER:' + splitted[1] + ":chunk_from_p2p")
            self.stats['sentViaP2P'] +=1

        if splitted[0] == "OFFER":
            logger.info(self.id, "Yeah! from p2p! %s from %s" % (splitted[1],id))
            self.cache[splitted[1]] = splitted[2]
            self.stats['recvFromP2P'] +=1
            self.desack_sent = False
            self.received_chunk(splitted[1])

    def add_peer(self, peer):
        logger.info(self.id, "connected to " + peer.id);
        self.swarm[peer.id] = peer

    def kill(self):
        logger.info(self.id, "killing %s" % (self.stats))
        self.running = False


