#!/usr/bin/env bash
set -e 	# Exit immediately upon failure

: ${1?"Need to pass BASE_IMAGE as argument"}
: ${2?"Need to pass TEST_APP as argument"}

BASE_IMAGE=$1
TEST_APP=$2
TEST_PORT=$RANDOM

APP_IMG_TAG=$(tr '[:upper:]' '[:lower:]' <<< $TEST_APP)_${TEST_PORT}

# Build the app image
.ci/build-app-image.sh $BASE_IMAGE $TEST_APP $APP_IMG_TAG

# Start app
.ci/start-container.sh 5004 $TEST_PORT $APP_IMG_TAG $APP_IMG_TAG

echo "[CI] Verifying connectivity..."
.ci/test-connection.sh http://localhost:$TEST_PORT