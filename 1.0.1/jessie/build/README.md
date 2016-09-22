
Build ASP.NET Core Docker Image
====================

This repository contains `Dockerfile` definitions for ASP.NET Core Docker images that can be used to build ASP.NET Core projects. These Dockerfiles use the [Dotnet image](https://hub.docker.com/r/microsoft/dotnet/) as its base.



[![Downloads from Docker Hub](https://img.shields.io/docker/pulls/microsoft/aspnetcore-build.svg)](https://hub.docker.com/r/microsoft/aspnetcore-build)
[![Stars on Docker Hub](https://img.shields.io/docker/stars/microsoft/aspnetcore-build.svg)](https://hub.docker.com/r/microsoft/aspnetcore-build)

This image contains:

- [.NET Cli](https://github.com/dotnet/cli) so that you can create, build and run your .NET Core applications.
- A Nuget package cache for the ASP.NET Core libraries.  This will significantly improve the initial package restore performance when building ASP.NET Core application.
- [Node.js](https://nodejs.org)
- [Bower](https://bower.io/)
- [Gulp](http://gulpjs.com/)

## Supported tags

- [`1.0.1`, `latest` (*Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.0.1/jessie/build/Dockerfile)