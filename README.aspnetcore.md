
ASP.NET Core Runtime Docker Image (Nightly)
===========================================

This repository contains images for running published ASP.NET Core applications. These images use the
[microsoft/dotnet-nightly](https://hub.docker.com/r/microsoft/dotnet-nightly/) image as its base.

These images contain the runtime only. Use [`microsoft/aspnetcore-build-nightly`](https://hub.docker.com/r/microsoft/aspnetcore-build-nightly/) to build ASP.NET Core apps inside the container.

## Supported Linux amd64 tags

- [`1.0.6-jessie`, `1.0.6`, `1.0`, `lts` (*1.0/jessie/runtime/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/dev/1.0/jessie/runtime/Dockerfile)
- [`1.1.3-jessie`, `1.1.3`, `1.1`, `1` (*1.1/jessie/runtime/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/dev/1.1/jessie/runtime/Dockerfile)
- [`2.0.0-stretch`, `2.0.0`, `2.0`, `2`, `latest` (*2.0/stretch/runtime/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/dev/2.0/stretch/runtime/Dockerfile)
- [`2.0.0-jessie`, `2.0-jessie`, `2-jessie` (*2.0/jessie/runtime/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/dev/2.0/jessie/runtime/Dockerfile)
- [`2.1.0-preview1-stretch`, `2.1.0-preview1`, `2.1` (*2.1/stretch/runtime/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/dev/2.1/stretch/runtime/Dockerfile)
- [`2.1.0-preview1-jessie`, `2.1-jessie` (*2.1/jessie/runtime/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/dev/2.1/jessie/runtime/Dockerfile)

## Supported Windows amd64 tags

- [`1.0.6-nanoserver`, `1.0.6`, `1.0`, `lts` (*1.0/nanoserver/runtime/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/dev/1.0/nanoserver/runtime/Dockerfile)
- [`1.1.3-nanoserver`, `1.1.3`, `1.1`, `1` (*1.1/nanoserver/runtime/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/dev/1.1/nanoserver/runtime/Dockerfile)
- [`2.0.0-nanoserver`, `2.0.0`, `2.0`, `2`, `latest` (*2.0/nanoserver/runtime/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/dev/2.0/nanoserver/runtime/Dockerfile)
- [`2.1.0-preview1-nanoserver`, `2.1.0-preview1`, `2.1` (*2.1/nanoserver/runtime/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/dev/2.1/nanoserver/runtime/Dockerfile)

## What is ASP.NET Core?

ASP.NET Core is a new open-source and cross-platform framework for building modern cloud based internet connected applications, such as web apps, IoT apps and mobile backends. It consists of modular components with minimal overhead, so you retain flexibility while constructing your solutions. You can develop and run your ASP.NET Core apps cross-platform on Windows, Mac and Linux. ASP.NET Core is open source at [GitHub](https://github.com/aspnet).

This image contains:

- [.NET Core](https://www.microsoft.com/net/core) so that you can run your already compiled .NET Core applications.
- A set of native images for all of the ASP.NET Core libraries. These images will be used at runtime to increase
  the cold-start performance of your application. A significant amount of the time taken to JIT compile on startup of
  your application is typically spent compiling ASP.NET Core libraries rather than your application code. Given that
  these libraries are not going to change for a given version we include native images so that the runtime can load them
  instead of running the JIT.

## Related images

1. [microsoft/dotnet-nightly](https://hub.docker.com/r/microsoft/dotnet-nightly/) - the .NET Core image if you don't need the ASP.NET Core specific optimizations.
2. [microsoft/aspnetcore-build-nightly](https://hub.docker.com/r/microsoft/aspnetcore-build-nightly/) - The ASP.NET Core build image for publishing an ASP.NET Core app inside a container.

## How to use this image

1. Create a Dockerfile for your application, the following example assumes you have already compiled your application (which is the expected use case for this image)

  ```
  FROM microsoft/aspnetcore-nightly
  WORKDIR /app
  COPY . .
  ENTRYPOINT ["dotnet", "myapp.dll"]
  ```

2. Build and run your app:

  ```
  $ docker build -t myapp .
  $ docker run -d -p 8000:80 myapp
  ```

3. Browse to localhost:8000 to access your app.

### A note on ports

  This image sets the `ASPNETCORE_URLS` environment variable to `http://+:80` which means that if you have not explicity
  set a URL in your application, via `app.UseUrl` in your Program.cs for example, then your application will be listening
  on port 80 inside the container.
