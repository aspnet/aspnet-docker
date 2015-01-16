ASP.NET 5 Preview Docker Image
====================

This repository contains `Dockerfile` definitions for [ASP.NET 5][home] Docker images.

This project is part of ASP.NET 5. You can find samples, documentation, and getting started instructions for ASP.NET 5 at the [Home][home] repo.

## Supported tags

* [`latest` _(Dockerfile)_](1.0.0-beta1/Dockerfile)
* [`1.0.0-beta1` _(Dockerfile)_](1.0.0-beta1/Dockerfile)
* [`nightly` _(Dockerfile)_](nightly/Dockerfile)

## How to use this image

Please [read this article][webdev-article] on .NET Web Development and Tools Blog to learn more about using this image.

This image provides the following environment variables:

* `KRE_USER_HOME`: path to KRE installation (e.g. /opt/kre)
* `KRE_VERSION`: version of KRE (K Runtime) installed (except the `nightly` image)

In addition to these, `PATH` is set to include the `k`/`kpm` executables.

[home]: https://github.com/aspnet/home
[webdev-article]: http://blogs.msdn.com/b/webdev/archive/2015/01/14/running-asp-net-5-applications-in-linux-containers-with-docker.aspx

