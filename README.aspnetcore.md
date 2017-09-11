
ASP.NET Core Runtime Docker Image
=================================

This repository contains images for running published ASP.NET Core applications. These images use the
[microsoft/dotnet](https://hub.docker.com/r/microsoft/dotnet/) image as its base.

These images contain the runtime only. Use [`microsoft/aspnetcore-build`](https://hub.docker.com/r/microsoft/aspnetcore-build/) to build ASP.NET Core apps inside the container.

# Supported Linux amd64 tags

- [`1.0.5-jessie`, `1.0.5`, `1.0`, `lts` (*1.0/jessie/sdk/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.0/jessie/sdk/Dockerfile)
- [`1.1.2-jessie`, `1.1.2`, `1.1`, `1` (*1.1/jessie/sdk/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.1/jessie/sdk/Dockerfile)
- [`2.0.0-stretch`, `2.0.0`, `2.0`, `2`, `latest` (*2.0/stretch/sdk/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/2.0/stretch/sdk/Dockerfile)
- [`2.0.0-jessie`, `2.0-jessie`, `2-jessie` (*2.0/jessie/sdk/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/2.0/jessie/sdk/Dockerfile)
- [`1.0-1.1` (*1.1/jessie/kitchensink/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.1/jessie/kitchensink/Dockerfile)
- [`1.0-2.0` (*2.0/stretch/kitchensink/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/2.0/stretch/kitchensink/Dockerfile)
- [`1.0-2.0-jessie` (*2.0/jessie/kitchensink/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/2.0/jessie/kitchensink/Dockerfile)

# Supported Windows amd64 tags

- [`1.0.5-nanoserver`, `1.0.5`, `1.0`, `lts` (*1.0/nanoserver/sdk/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.0/nanoserver/sdk/Dockerfile)
- [`1.1.2-nanoserver`, `1.1.2`, `1.1`, `1` (*1.1/nanoserver/sdk/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.1/nanoserver/sdk/Dockerfile)
- [`2.0.0-nanoserver`, `2.0.0`, `2.0`, `2`, `latest` (*2.0/nanoserver/sdk/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/2.0/nanoserver/sdk/Dockerfile)
- [`1.0-1.1` (*1.1/nanoserver/kitchensink/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.1/nanoserver/kitchensink/Dockerfile)
- [`1.0-2.0` (*2.0/nanoserver/kitchensink/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/2.0/nanoserver/kitchensink/Dockerfile)

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

1. [microsoft/dotnet](https://hub.docker.com/r/microsoft/dotnet/) - the .NET Core image if you don't need the ASP.NET Core specific optimizations.
2. [microsoft/aspnetcore-build](https://hub.docker.com/r/microsoft/aspnetcore-build/) - The ASP.NET Core build image for publishing an ASP.NET Core app inside a container.

## How to use this image

1. Create a Dockerfile for your application, the following example assumes you have already compiled your application (which is the expected use case for this image)

  ```
  FROM microsoft/aspnetcore
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
