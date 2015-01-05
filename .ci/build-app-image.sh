#!/usr/bin/env bash
set -e 	# Exit immediately upon failure

: ${1?"Need to pass BASE_IMAGE as argument"}
: ${2?"Need to pass TEST_APP as argument"}
: ${3?"Need to pass TAG as argument"}

BASE_IMAGE=$1
TEST_APP=$2
TAG=$3

echo "[CI] Injecting Dockerfile to project $TEST_APP..."
cd  $SAMPLES_REPO/samples/$TEST_APP
tee Dockerfile << EOF
FROM $BASE_IMAGE
COPY . /app
WORKDIR /app
RUN kpm restore
ENV KRE_TRACE 1
ENTRYPOINT sleep 10000 | k kestrel
EOF

echo "[CI] Building Docker image for $TEST_APP, will tag as '$TAG'..."
docker build -t $TAG .
echo "[CI] Built Docker image '$TAG'"