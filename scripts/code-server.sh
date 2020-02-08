#!/bin/bash

#
# script to run code-server in docker on a specific path
# and spawn a browser tab to the UI
# 
# currently, passing specific file not working


ARG_PATH=$1
TARGET_FILE=
ABS_DIRECTORY=

if [ -d $ARG_PATH ]
then
ABS_DIRECTORY=$(cd $ARG_PATH; pwd) 
else
DIRNAME=$(dirname $ARG_PATH)
ABS_DIRECTORY=$(cd $DIRNAME; pwd)
TARGET_FILE=$(basename $ARG_PATH)
fi


BASE_DIRNAME=$(basename $ABS_DIRECTORY)
CONTAINER_DIR="/home/coder/$BASE_DIRNAME"
CONTAINER_OPEN_ARG="$CONTAINER_DIR/$TARGET_FILE"
#CONTAINER_OPEN_ARG="$CONTAINER_DIR"

DOCKER_NAME="code-server"

docker run --rm --name "$DOCKER_NAME" -p 127.0.0.1:8080:8080  \
  -v "$ABS_DIRECTORY:$CONTAINER_DIR" codercom/code-server:v2 \
  --auth none $CONTAINER_DIR $CONTAINER_OPEN_ARG & 

DOCKERPID=$!

trap "docker stop $DOCKER_NAME" EXIT

sleep 1

xdg-open "http://127.0.0.1:8080"

case $(ps -o stat= -p $$) in
  *+*) read -rs -n1  ;;
  *) wait $DOCKERPID ;;
esac

