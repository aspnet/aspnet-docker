#!/usr/bin/env bash

set -euo pipefail

[ -z "${folder_filter:-}" ] && folder_filter='*'

if [ "$(uname)" = "Darwin" ]; then
    host_ip="$(ifconfig en0 | awk '$1 == "inet" {print $2}')"
else
    host_ip="$(ifconfig eth0 | grep -oP 'inet addr:\K\S+')"
fi

./build.ps1 -Folder "$folder_filter"
docker build --rm -t testrunner -f ./test/Dockerfile.testrunner.linux .
docker run --add-host "dockerhost:$host_ip" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    testrunner ./test/test.ps1 -Folder "$folder_filter" -HostIP dockerhost

