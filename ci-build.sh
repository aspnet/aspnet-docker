#!/usr/bin/env bash

set -euo pipefail

[ -z "${folder_filter:-}" ] && folder_filter='*'

./build.ps1 -Folder "$folder_filter"
docker build --rm -t testrunner -f ./test/Dockerfile.testrunner.linux .
docker run --add-host "dockerhost:$(ifconfig eth0 | grep -oP 'inet addr:\K\S+')" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    testrunner powershell -File ./test/test.ps1 -Folder "$folder_filter" -HostIP dockerhost

