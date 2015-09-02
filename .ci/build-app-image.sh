#!/usr/bin/env bash
set -e 	# Exit immediately upon failure

: ${1?"Need to pass BASE_IMAGE as argument"}
: ${2?"Need to pass TEST_APP as argument"}
: ${3?"Need to pass TAG as argument"}
: ${4?"Need to pass VERSION as argument"}

set +x

BASE_IMAGE=$1
TEST_APP=$2
TAG=$3
VERSION=$4


echo "[CI] Injecting Dockerfile to project $TEST_APP..."
if [[ ! -d $SAMPLES_REPO/samples/$VERSION/$TEST_APP ]]; then
	echo "[CI] Sample '$TEST_APP' not found for Docker image '$VERSION'"
    exit 1
fi
cd  $SAMPLES_REPO/samples/$VERSION/$TEST_APP

ls -al

if [[ -f "Dockerfile" ]]; then
	echo "Using existing Dockerfile in the sample."
	echo "Dockerfile:"
	cat Dockerfile
else
	tee Dockerfile << EOF
FROM $BASE_IMAGE
COPY . /app
WORKDIR /app
RUN dnu restore
ENV DNX_TRACE 1
ENTRYPOINT sleep 10000 | dnx . kestrel
EOF

fi

echo "[CI] Building Docker image for $TEST_APP, will tag as '$TAG'..."
docker build -t $TAG .
echo "[CI] Built Docker image '$TAG'"
