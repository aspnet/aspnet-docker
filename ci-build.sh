#!/usr/bin/env bash

set -euo pipefail

folder_filter=''
[ -z "${folder_filter:-}" ] && folder_filter='*'

while [[ $# -gt 0 ]]; do
    case $1 in
        --folder-filter)
            shift
            [ -z "${1+x}" ] && echo "Missing value for --folder-filter" && exit 1
            folder_filter="$1"
            ;;
        *)
            echo "Unrecognized argument $1"
            exit 1
            ;;
    esac
    shift
done

if [ "$(uname)" = "Darwin" ]; then
    host_ip="$(ifconfig en0 | awk '$1 == "inet" {print $2}')"
else
    host_ip="$(ifconfig eth0 | grep -oP 'inet addr:\K\S+')"
fi

./build.ps1 -Folder "$folder_filter"
docker build --rm -t testrunner -f ./test/Dockerfile.testrunner.linux .
docker run --add-host "dockerhost:$host_ip" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    testrunner ./test.ps1 -Folder "$folder_filter" -HostIP dockerhost

