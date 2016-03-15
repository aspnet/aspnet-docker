![](https://avatars3.githubusercontent.com/u/6476660?v=3&s=200)

ASP.NET Core Preview Docker Image
====================

This repository contains `Dockerfile` definitions for [ASP.NET Core][home] Docker images.

This project is part of ASP.NET Core. You can find samples, documentation, and getting started instructions for ASP.NET Core at the [Home][home] repo.

[![Build Status of Docker Image on Circle CI](https://img.shields.io/circleci/project/aspnet/aspnet-docker.svg)](https://circleci.com/gh/aspnet/aspnet-docker/tree/master)
[![Downloads from Docker Hub](https://img.shields.io/docker/pulls/microsoft/aspnet.svg)](https://registry.hub.docker.com/u/microsoft/aspnet)
[![Stars on Docker Hub](https://img.shields.io/docker/stars/microsoft/aspnet.svg)](https://registry.hub.docker.com/u/microsoft/aspnet)

## Supported tags

#### `coreclr`-based images

* [`1.0.0-rc1-update1-coreclr` _(1.0.0-rc1-update1-coreclr/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/1.0.0-rc1-update1-coreclr/Dockerfile)
* [`1.0.0-rc1-final-coreclr` _(1.0.0-rc1-final-coreclr/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/1.0.0-rc1-final-coreclr/Dockerfile)
* [`1.0.0-beta8-coreclr` _(1.0.0-beta8-coreclr/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/1.0.0-beta8-coreclr/Dockerfile)
* [`1.0.0-beta7-coreclr` _(1.0.0-beta7-coreclr/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/1.0.0-beta7-coreclr/Dockerfile)

#### `mono`-based images

* [`1.0.0-rc1-update1`, `latest` _(1.0.0-rc1-update1/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/1.0.0-rc1-update1/Dockerfile)
* [`1.0.0-rc1-final`, _(1.0.0-rc1-final/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/1.0.0-rc1-final/Dockerfile)
* [`1.0.0-beta8`,  _(1.0.0-beta8/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/1.0.0-beta8/Dockerfile)
* [`1.0.0-beta7`,  _(1.0.0-beta7/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/1.0.0-beta7/Dockerfile)
* [`1.0.0-beta6`,  _(1.0.0-beta6/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/1.0.0-beta6/Dockerfile)
* [`1.0.0-beta5`,  _(1.0.0-beta5/Dockerfile)_](https://github.com/aspnet/aspnet-docker/blob/master/1.0.0-beta5/Dockerfile)

## How to use this image

Please [read this article][webdev-article] on .NET Web Development and Tools Blog to learn more about using this image.

This image provides the following environment variables:

* `DNX_USER_HOME`: path to DNX installation (e.g. /opt/dnx)
* `DNX_VERSION`: version of DNX (.NET Execution Environment) installed

In addition to these, `PATH` is set to include the `dnx`/`dnu` executables.

[home]: https://github.com/aspnet/home
[webdev-article]: http://blogs.msdn.com/b/webdev/archive/2015/01/14/running-asp-net-5-applications-in-linux-containers-with-docker.aspx
