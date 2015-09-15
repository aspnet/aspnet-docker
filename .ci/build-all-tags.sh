#!/usr/bin/env bash
set -e 	# Exit immediately upon failure

: ${IMAGE?"Need to pass IMAGE"}
: ${1?"Need to pass search directory argument"}

for tag in `.ci/find-tags.sh $1`; do
	(
	  TAG=${IMAGE}:${tag}
	  echo "[CI] Building image '$TAG'..."
	  set -x
	  docker build -t $TAG $1/$tag
	)
done

echo "[CI] All tags build fine."
