#!/usr/bin/env bash
set -e 	# Exit immediately upon failure

mkdir -p container-logs

for c in `docker ps -aq`; do
	docker logs -t $c 2>&1 > ./container-logs/$c.log
	echo "Saved logs for container $c."
done