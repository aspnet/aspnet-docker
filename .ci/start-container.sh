#!/usr/bin/env bash
set -e 	# Exit immediately upon failure

: ${1?"Need to pass APP_PORT as argument"}
: ${2?"Need to pass HOST_PORT as argument"}
: ${3?"Need to pass CNT_NAME as argument"}
: ${4?"Need to pass APP_IMG as argument"}

APP_PORT=$1
HOST_PORT=$2
CNT_NAME=$3
APP_IMG=$4

SLEEP=10

# Start container
echo "[CI] Starting Docker container '$CNT_NAME', listening on port $HOST_PORT:"
docker run -t -d -p $HOST_PORT:$APP_PORT --name $CNT_NAME $APP_IMG

# Wait to bootstrap the app
echo "[CI] Sleeping $SLEEP seconds to bootstrap the server..."
sleep $SLEEP
docker ps