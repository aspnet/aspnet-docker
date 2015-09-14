#!/bin/bash
set -ex

SAMPLES_DIR=aspnet-samples
rm -rf "${SAMPLES_DIR}"
git clone -q git://github.com/aspnet/Home.git -b dev "${SAMPLES_DIR}"
