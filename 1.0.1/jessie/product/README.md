
ASP.NET Core Docker Image
====================

This repository contains `Dockerfile` definitions for ASP.NET Core Docker images. These images use the [Dotnet image](https://hub.docker.com/r/microsoft/dotnet/) as its base.



[![Downloads from Docker Hub](https://img.shields.io/docker/pulls/microsoft/aspnetcore.svg)](https://registry.hub.docker.com/u/microsoft/aspnetcore)
[![Stars on Docker Hub](https://img.shields.io/docker/stars/microsoft/aspnetcore.svg)](https://registry.hub.docker.com/u/microsoft/aspnetcore)

This image contains:

- the [Dotnet CLI](https://github.com/dotnet/cli) so that you can run your already compiled .NET Core applications.
- A set of native images for all of the ASP.NET Core libraries. These images will be used at runtime to increase the cold-start performance of your application. A significant amount of the time taken to JIT compile on startup of your application is typically spent compiling ASP.NET Core libraries rather than your application code. Given that thse libraries are not going to change for a given version we include native images so that the runtime can load them instead of running the JIT.

## Supported tags

- [`1.0.1` (*Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.0.1/jessie/product/Dockerfile)
