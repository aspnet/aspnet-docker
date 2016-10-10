
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
    $ docker create --build-cont build-image
    $ docker cp build-image:/out ./output
    ```

Now you have built your ASP.NET Core application inside a container and have the published output on the host ready to deploy. From here you could then construct an optimized runtime image with the `microsoft/aspnetcore` image or just deploy/run the binaries as normal without using Docker at runtime.

###TODO: I think everything below this line we could cut, and maybe have them as an example in a samples repo. In fact I think a set of samples that show using this technique end-to-end should be published.

### Interactive
  
You can interactively build your application inside this container with a command like the following:

```
$ docker run -v $(pwd):/app -it microsoft/aspnetcore-build
root@8f1bba9f4c95:/# cd /app
root@8f1bba9f4c95:/app# dotnet restore
root@8f1bba9f4c95:/app# dotnet publish
root@8f1bba9f4c95:/app# exit
```
The above assumes you are in a directory with a `project.json` that you want to publish. After running these you will have a `bin` directory that contains the published output of your application.


### Run my build script

If you have a build script that will run restore and publish, perhaps with other custom tasks, then you could run a command like the following:

```
$ docker run -v $(pwd):/app -it microsoft/aspnetcore-build /app/build.sh
```
*note:* The `-w` switch of `docker run` can set the working directory, which might be useful if you are doing this type of work.
