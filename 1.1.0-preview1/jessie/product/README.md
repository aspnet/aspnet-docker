ASP.NET Core Docker Image
=========================

This repository contains `Dockerfile` definitions for ASP.NET Core Docker images.
These images use the [microsoft/dotnet](https://hub.docker.com/r/microsoft/dotnet/) image as its base.

[![Downloads from Docker Hub](https://img.shields.io/docker/pulls/microsoft/aspnetcore.svg)](https://hub.docker.com/r/microsoft/aspnetcore)
[![Stars on Docker Hub](https://img.shields.io/docker/stars/microsoft/aspnetcore.svg)](https://hub.docker.com/r/microsoft/aspnetcore)

This image contains:

- [.NET Core](https://www.microsoft.com/net/core) so that you can run your already compiled .NET Core applications.
- A set of native images for all of the ASP.NET Core libraries. These images will be used at runtime to increase the cold-start performance of your application. A significant amount of the time taken to JIT compile on startup of your application is typically spent compiling ASP.NET Core libraries rather than your application code. Given that these libraries are not going to change for a given version we include native images so that the runtime can load them instead of running the JIT.

## Supported tags

- [`1.0.1`, `latest` (*Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.0.1/jessie/product/Dockerfile)
- [`1.1.0-preview1`, (*Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.1.0-preview1/jessie/product/Dockerfile)
