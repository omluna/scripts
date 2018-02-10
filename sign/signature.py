#!/usr/bin/env python
# -*- coding: utf-8 -*-

import SocketServer
import subprocess
import time
import sh
import logging
import signal

logging.basicConfig(format='%(asctime)s %(message)s', datefmt='%Y-%m-%d %H:%M:%S')

signature_srv = "18.8.3.21"
srv_port = 8091
sign_action = {"P": "/home/android/chenyee_sign/scan_product.sh",
               "O": "/home/android/chenyee_sign/scan_ota.sh"}


class SignatureHandler(SocketServer.BaseRequestHandler):

    def do_signature(self):
        # 1 -- mount nfs
        action, path, packname = self.data.split(",")
        nfs_dir = self.ipaddr + ":" + path
        work_dir = "/home/android/signature/" + self.ipaddr + '/' + packname
	exit_code =  0

        try:
            sh.sudo.mkdir(work_dir, "-p")
        except sh.ErrorReturnCode_1:
            logging.warning("mkdir failed, just ignore it")

        try:
            sh.sudo.mount("-t", "nfs", "-o", "hard,intr", nfs_dir, work_dir)
        except sh.ErrorReturnCode, e:
            logging.warning("mount failed: cmd=%s, exit_code = %d" % (e.full_cmd, e.exit_code))
            self.request.sendall(str(e.exit_code))
            return

        logging.warning("start sign....")
	try:
        	sign_ret = sh.sudo("/bin/bash", sign_action[action], work_dir, packname)
		exit_code = sign_ret.exit_code
		logging.warning("--------------sign success, stdout-----------------")
        	logging.warning(sign_ret.stdout)
		logging.warning("--------------sign success, stdout end-----------------")
	except sh.ErrorReturnCode,e:
		logging.warning("--------------sign failed-----------------")
        	logging.warning(e.stdout)
        	logging.warning("~~~~~~~~~~~~~~~~~~~~~~~~")
        	logging.warning(e.stderr)
		logging.warning("--------------sign failed end-----------------")
		exit_code = e.exit_code
	finally:
        	sh.sudo.umount(work_dir)

        if exit_code != 0:
            logging.error("sign failed")

        self.request.sendall(str(exit_code))


    def handle(self):
        # self.request is the TCP socket connected to the client
        self.data = self.request.recv(1024).strip()
        self.ipaddr = self.client_address[0]
        logging.warning("receive request from " + self.ipaddr + " with " + self.data)
        self.do_signature()
        logging.warning("finish signature for %s" % self.ipaddr)


if __name__ == "__main__":
    # Create the server, binding to localhost on port 9999
    server = SocketServer.TCPServer((signature_srv, srv_port), SignatureHandler)

    # Activate the server; this will keep running until you
    # interrupt the program with Ctrl-C
    try:
        server.serve_forever()

    except KeyboardInterrupt:
        logging.warning("got key interrupt, shutdown server")
        server.shutdown()

