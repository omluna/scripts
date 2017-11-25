#!/bin/bash
reponame=$1

echo "`date` update $reponame index start"
echo "sync with git server...."
SRC_PATH=/home/android/chenyee_xref/src
BIN_PATH=/home/android/chenyee_xref/bin
DATA_PATH=/home/android/chenyee_xref/data
PORTMAP=$BIN_PATH/port_map
port=`grep $1 $PORTMAP | awk '{print $2}'`
echo "opengrok port is $port"

cd $SRC_PATH/$reponame

repo sync -c -q --no-tags

echo "update opengrok index..."
$BIN_PATH/update_opengrok_index.sh $DATA_PATH/$reponame /$reponame $SRC_PATH/$reponame $port

echo "`date` update $reponame index end"
