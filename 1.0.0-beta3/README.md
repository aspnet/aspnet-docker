![](https://avatars3.githubusercontent.com/u/6476660?v=3&s=200)

ASP.NET 5 Preview Docker Image
====================

This repository contains `Dockerfile` definitions for [ASP.NET 5][home] Docker images.

This project is part of ASP.NET 5. You can find samples, documentation, and getting started instructions for ASP.NET 5 at the [Home][home] repo.

## Supported tags

* [`1.0.0-beta3`, `latest`  _(1.0.0-beta3/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/1.0.0-beta3/Dockerfile)
* [`1.0.0-beta2`,  _(1.0.0-beta2/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/1.0.0-beta2/Dockerfile)
* [`1.0.0-beta1` _(1.0.0-beta1/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/1.0.0-beta1/Dockerfile)
* [`nightly` _(nightly/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/nightly/Dockerfile)

## How to use this image

Please [read this article][webdev-article] on .NET Web Development and Tools Blog to learn more about using this image.

This image provides the following environment variables:

* `KVM_USER_HOME`: path to KRE installation (e.g. /opt/kre)
* `KRE_VERSION`: version of KRE (K Runtime) installed

In addition to these, `PATH` is set to include the `k`/`kpm` executables.

The `nightly` image provides the following environment variables:

* `DNX_USER_HOME`: path to DNX installation (e.g. /opt/dnx)
* `DNX_FEED`: url to the DNX nightly feed (e.g. https://www.myget.org/F/aspnetvnext/api/v2)

In addition to these, `PATH` is set to include the `dnx`/`dnu` executables.

## Build Status

Status for image tags built from `master`: [![Build Status of Docker Image on Circle CI](https://circleci.com/gh/aspnet/aspnet-docker/tree/master.svg?style=svg)](https://circleci.com/gh/aspnet/aspnet-docker/tree/master)

[home]: https://github.com/aspnet/home
[webdev-article]: http://blogs.msdn.com/b/webdev/archive/2015/01/14/running-asp-net-5-applications-in-linux-containers-with-docker.aspx
