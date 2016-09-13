#!/bin/bash

# clear all the test images which are built by build-test-image.sh script
# the script will forcefully remove all images as well as their containers if the image name follows this scheme
search='test_image_'

# remove containers
for container in $(docker ps -a | grep test_image_ | tr -s ' ' | cut -d ' ' -f1);
do
    docker rm -f $container
done

# remove images
for image in $(docker images | grep test_image_ | tr -s ' ' | cut -d ' ' -f3);
do
    docker rmi -f $image
done
