#!/bin/sh
USER=rsync      
DS1=10.67.37.77                     # IP of DestServer
SRCDIR=/data/dl/ota/res/          # Local source dir to monitor, changes for the dir will be synced to DestServer
DEST=otares                                # Same as the module name defined in /etc/rsync.conf on DestServer
/usr/local/bin/inotifywait -mrq -e create,move,delete,modify $SRCDIR | while read D E F
do
    rsync -ahqzt --password-file=/etc/rsync-client.secure --delete ${SRCDIR} ${USER}@${DS1}::${DEST}
done
