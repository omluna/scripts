#!/bin/bash
reponame=$1
echo "sync with git server...."

SRC_PATH=/home/android/chenyee_xref/src
BIN_PATH=/home/android/chenyee_xref/bin
DATA_PATH=/home/android/chenyee_xref/data
PORTMAP=$BIN_PATH/port_map
port=`grep $1 $PORTMAP | awk '{print $2}'`
echo "opengrok port is $port"

cd $SRC_PATH/$reponame
branches=`ls`

for branch in $branches;do
    echo $SRC_PATH/$reponame/$branch
    cd $SRC_PATH/$reponame/$branch
    git pull
    echo $SRC_PATH/$reponame/$branch/gionee
    cd $SRC_PATH/$reponame/$branch/gionee
    git pull
    echo $SRC_PATH/$reponame/$branch/gn_project
    cd $SRC_PATH/$reponame/$branch/gn_project
    git pull
done


echo "update opengrok index..."
$BIN_PATH/update_opengrok_index.sh $DATA_PATH/$reponame /$reponame $SRC_PATH/$reponame $port
