#!/bin/bash
cd /home/android/opengrok/bin

SRC_PATH=$3
export 		JAVA_HOME=/usr/local/jdk
#export		OPENGROK_VERBOSE=v 
#export		OPENGROK_PROGRESS=v 
export    OPENGROK_INSTANCE_BASE=$1
export    OPENGROK_WEBAPP_CONTEXT=$2
export 	  OPENGROK_WEBAPP_CFGADDR=localhost:$4
export IGNORE_PATTERNS="-i *.bz2 -i *.o  -i *.a -i *.jar -i *.gz -i *.so -i *.png -i *.jpg  -i *.tar -i *.tgz -i *.zip -i d:prebuilts "

echo $OPENGROK_INSTANCE_BASE
echo $OPENGROK_WEBAPP_CONTEXT
echo $OPENGROK_WEBAPP_CFGADDR
echo $SRC_PATH

./OpenGrok index $SRC_PATH
