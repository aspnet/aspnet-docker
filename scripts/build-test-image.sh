#!/bin/bash

# build a test images locally use the Docker file at current directory
# once the images is built, run an interactive container from it and enter the bash

# the test image is named after following scheme
name=test_image_$(date +%Y%m%d-%H%M%S)

docker build -t $name .
docker run -it $name /bin/bash
