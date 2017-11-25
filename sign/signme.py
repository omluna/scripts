#!/usr/bin/env python
# -*- coding: utf-8 -*-

import socket
import sys

HOST, PORT = "18.8.3.21", 8091
data = " ".join(sys.argv[1:])

exit_code = 0
# Create a socket (SOCK_STREAM means a TCP socket)
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

try:
    # Connect to server and send data
    sock.connect((HOST, PORT))
    sock.sendall(data)

    # Receive data from the server and shut down
    received = sock.recv(1024)

    if received != "0":
        print "signature failed: " + received
        exit_code = 1
    else:
        print "signature successfully"
        exit_code = 0
except:
    exit_code = 1

finally:
    print "just exit"
    sock.close()
    sys.exit(exit_code)
