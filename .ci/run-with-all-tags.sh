#!/usr/bin/env bash
set -e 	# Exit immediately upon failure

: ${IMAGE?"Need to pass IMAGE"}
: ${1?"Need to pass search directory as argument"}
: ${2?"Need to pass sample app name as argument"}

for tag in `.ci/find-tags.sh $1`; do
	TAG=${IMAGE}:${tag}
	echo "[CI] ----------------------------------"
	echo "[CI] Verifying '$2' app with '$TAG'"
	(
	  set -x
	  .ci/run-app.sh $TAG $2 ${tag}
	)
done

echo "[CI] '$2' runs fine on all tags."
