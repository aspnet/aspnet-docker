![](https://avatars3.githubusercontent.com/u/6476660?v=3&s=200)

PartsUnlimited Demo App Linux Image
===================================

This repository contains `Dockerfile` definitions for [PartsUnlimited](https://github.com/Microsoft/PartsUnlimited) Demo on a Linux Docker image.

## How to use this image

This image is basically the base image
[`coreclr-1.0.0-beta5-11624` _(coreclr-1.0.0-beta5-11624/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/coreclr-1.0.0-beta5-11624/Dockerfile).
with the PartsUnlimited demo app downloaded to `/opt/demo`.  Type `/opt/demo/Kestrel` to run the website.

## Build Status

Status for image tags built from `master`: [![Build Status of Docker Image on Circle CI](https://circleci.com/gh/aspnet/aspnet-docker/tree/master.svg?style=svg)](https://circleci.com/gh/aspnet/aspnet-docker/tree/master)

[home]: https://github.com/aspnet/home
[webdev-article]: http://blogs.msdn.com/b/webdev/archive/2015/01/14/running-asp-net-5-applications-in-linux-containers-with-docker.aspx
