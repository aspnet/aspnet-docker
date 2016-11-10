
Build ASP.NET Core Docker Image
===============================

This repository contains `Dockerfile` definitions for ASP.NET Core Docker images that can be used to build ASP.NET Core
projects. These Dockerfiles use the [microsoft/dotnet](https://hub.docker.com/r/microsoft/dotnet/) image as its base.

[![Downloads from Docker Hub](https://img.shields.io/docker/pulls/microsoft/aspnetcore-build.svg)](https://hub.docker.com/r/microsoft/aspnetcore-build)
[![Stars on Docker Hub](https://img.shields.io/docker/stars/microsoft/aspnetcore-build.svg)](https://hub.docker.com/r/microsoft/aspnetcore-build)

This image contains:

- [.NET Command Line Interface (CLI)](https://github.com/dotnet/cli) so that you can create, build and run your .NET Core applications.
- A Nuget package cache for the ASP.NET Core libraries.  This will significantly improve the initial package restore
  performance when building ASP.NET Core application.
- [Node.js](https://nodejs.org)
- [Bower](https://bower.io/)
- [Gulp](http://gulpjs.com/)

## Supported tags

- [`1.0.1`, (*Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.0.1/jessie/build/Dockerfile)
- [`1.1.0-projectjson`, `latest` (*Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.1.0/jessie/build-projectjson/Dockerfile)

## Example Usage

1. Create a Dockerfile to build your application (`Dockerfile.build` is a common name used).

    ```Dockerfile
    FROM microsoft/aspnetcore-build
    WORKDIR /app

    COPY project.json .
    RUN dotnet restore

    COPY . .
    RUN dotnet publish --output /out/. --configuration Release
    ```

2. Build your image:

    ```
    $ docker build -t build-image -f Dockerfile.build .
    ```

3. Create a container from your image and copy your built application out.

    ```
    $ docker create --name build-cont build-image
    $ docker cp build-cont:/out ./output
    ```

Now you have built your ASP.NET Core application inside a container and have the published output on the host ready to
deploy. From here you could then construct an optimized runtime image with the `microsoft/aspnetcore` image or just
deploy/run the binaries as normal without using Docker at runtime.