#!/usr/bin/env bash
set -e 	# Exit immediately upon failure

: ${1?"Need to pass BASE_IMAGE as argument"}
: ${2?"Need to pass TEST_APP as argument"}
: ${3?"Need to pass TAG as argument"}
: ${4?"Need to pass VERSION as argument"}


BASE_IMAGE=$1
TEST_APP=$2
TAG=$3
VERSION=$4
SAMPLE="aspnet-samples/samples/${VERSION}/${TEST_APP}"
SAMPLE_NO_CLR="aspnet-samples/samples/${VERSION%-coreclr}/${TEST_APP}"

if [[ ! -d "$SAMPLE_NO_CLR" ]]; then
	echo "[CI] Sample '$TEST_APP' not found for Docker image '$VERSION' at ${SAMPLE_NO_CLR}"
    exit 1
fi

if [[ -d "$SAMPLE_NO_CLR" ]] && [[ ! -d "$SAMPLE" ]]; then
	set -x
	echo "Samples dir ${SAMPLE} not found. Will clone from ${SAMPLE_NO_CLR}."

	mkdir -p "${SAMPLE}"
	cp -rf "${SAMPLE_NO_CLR}" $(dirname "${SAMPLE}")
	ls -al "${SAMPLE}"
	# Append -coreclr to FROM.. directive
	sed -i.bak '/^FROM/ s/$/-coreclr/' "${SAMPLE}/Dockerfile"
	set +x
fi

cd  $SAMPLE
if [[ -f "Dockerfile" ]]; then
	echo "Using existing Dockerfile in the sample."
	echo "Dockerfile:"
	cat Dockerfile
else
	echo "[CI] Injecting Dockerfile to project $TEST_APP..."
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
