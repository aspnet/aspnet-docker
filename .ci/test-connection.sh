#!/usr/bin/env bash
set -e 	# Exit immediately upon failure

: ${1?"Need to pass URL"}
URL=$1

curl -vsSLI --retry 10 --retry-delay 3 $URL
