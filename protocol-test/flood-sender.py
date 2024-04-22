# Not maintained. Don't use

#!/bin/env python3

import socket
from time import sleep
from datetime import datetime
import pytz

CONN = ("", 5257)


def tcp_server(conn, fd):
    maxlen = 65535
    payload = bytearray(b"A" * maxlen)
    while True:
        end = 1
        while end <= maxlen:
            conn.sendall(payload[:end])
            sleep(0.1)
            text = "{} {}\n".format(datetime.now(), end)
            fd.write(text)
            end += 1


def udp_server(addr, fd, interval=0):
    maxlen = 1472
    payload = bytearray(b"A" * maxlen)
    usetz = pytz.timezone("US/Pacific")
    while True:
        end = 1
        while end <= maxlen:
            sock.sendto(payload[:end], addr)
            # sleep(interval)
            text = "{},{}\n".format(datetime.now(usetz), end)
            fd.write(text)
            end += 1


if __name__ == "__main__":
    mode = input("Server type:")
    run = input("Run number:")
    if mode == "tcp":
        # run tcp
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.bind(CONN)
        sock.listen()

        conn, addr = sock.accept()
        with open("{}.tcplog".format(run), "w") as f:
            while True:
                data = conn.recv(1024)
                tcp_server(conn, f)

    elif mode == "udp":
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.bind(CONN)

        interval = 0

        with open("{}.udplog".format(run), "w") as f:
            while True:
                data, addr = sock.recvfrom(1024)
                udp_server(addr, f, interval)
