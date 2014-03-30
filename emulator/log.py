from termcolor import colored
from datetime import datetime

class Logger(object):

    def __init__(self):
        self.ids_and_colors = {}
        self.colors = ['red', 'green', 'yellow', 'blue', 'magenta', 'cyan'] * 100

    def info(self, id, message):
        color = self._get_color(id)
        attrs = []
        if "Yeah" in message or "No" in message:
            attrs = ['bold', 'dark']

            print str(datetime.now()) + " " + colored("[%s] %s" % (id, message), color, attrs=attrs)

    def _get_color(self, id):
        if id not in self.ids_and_colors:
            self.ids_and_colors[id] = self.colors.pop()

        return self.ids_and_colors[id]

