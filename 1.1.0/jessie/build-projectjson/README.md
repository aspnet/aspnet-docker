
Build ASP.NET Core Docker Image
===============================

This repository contains `Dockerfile` definitions for ASP.NET Core Docker images that can be used to build ASP.NET Core
projects. These Dockerfiles use the [microsoft/dotnet](https://hub.docker.com/r/microsoft/dotnet/) image as its base.

[![Downloads from Docker Hub](https://img.shields.io/docker/pulls/microsoft/aspnetcore-build.svg)](https://hub.docker.com/r/microsoft/aspnetcore-build)
[![Stars on Docker Hub](https://img.shields.io/docker/stars/microsoft/aspnetcore-build.svg)](https://hub.docker.com/r/microsoft/aspnetcore-build)

## Supported tags

- [`1.1.0-projectjson`, `latest` (*Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.1.0/jessie/build-projectjson/Dockerfile)
- [`1.1.0-msbuild` (*Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.1.0/jessie/build-msbuild/Dockerfile)
- [`1.0.1-msbuild`, (*Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.0.1/jessie/build-msbuild/Dockerfile)
- [`1.0.1`, (*Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.0.1/jessie/build-projectjson/Dockerfile)

## What is ASP.NET Core?

ASP.NET Core is a new open-source and cross-platform framework for building modern cloud based internet connected applications, such as web apps, IoT apps and mobile backends. It consists of modular components with minimal overhead, so you retain flexibility while constructing your solutions. You can develop and run your ASP.NET Core apps cross-platform on Windows, Mac and Linux. ASP.NET Core is open source at [GitHub](https://github.com/aspnet). 

This image contains:

- [.NET Core SDK](https://github.com/dotnet/cli) so that you can create, build and run your .NET Core applications.
- A NuGet package cache for the ASP.NET Core libraries.  This will significantly improve the initial package restore performance when building ASP.NET Core application.
- [Node.js](https://nodejs.org)
- [Bower](https://bower.io/)
- [Gulp](http://gulpjs.com/)

## Related images

1. [microsoft/dotnet](https://hub.docker.com/r/microsoft/dotnet/)
2. [microsoft/aspnetcore](https://hub.docker.com/r/microsoft/aspnetcore/)

## Example Usage

### Build an app on `docker run`

You can use this container to compile your application when it runs. If you use the [Visual Studio tooling](https://blogs.msdn.microsoft.com/webdev/2016/11/16/new-docker-tools-for-visual-studio/) to setup CI/CD to Azure Container Service then this method of using the build container is used.

Run the build container, mounting your code and output directory, and publish your app:

```
docker run --it -v $(PWD):/app --workdir /app microsoft/aspnetcore-build bash -c "dotnet restore && dotnet publish -c Release -o ./bin/Release/PublishOutput"
```

After this has run the application in the current directory will be published to the `bin/Release/PublishOutput` directory.

### Build an app on `docker build`

With this technique your application is compiled when you run `docker build` and you then copy the binaries out of the built image.

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

Now you have built your ASP.NET Core application inside a container and have the published output on the host ready to deploy. From here you could then construct an optimized runtime image with the `microsoft/aspnetcore` image or just deploy/run the binaries as normal without using Docker at runtime.

This approach has the advantage of caching the results of `dotnet restore` so that packages are not downloaded unless your change the project.json.