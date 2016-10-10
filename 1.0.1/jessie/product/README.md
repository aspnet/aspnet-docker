
ASP.NET Core Docker Image
====================

This repository contains `Dockerfile` definitions for ASP.NET Core Docker images. These images use the [Dotnet image](https://hub.docker.com/r/microsoft/dotnet/) as its base.



[![Downloads from Docker Hub](https://img.shields.io/docker/pulls/microsoft/aspnetcore.svg)](https://hub.docker.com/r/microsoft/aspnetcore)
[![Stars on Docker Hub](https://img.shields.io/docker/stars/microsoft/aspnetcore.svg)](https://hub.docker.com/r/microsoft/aspnetcore)

This image contains:

- [.NET Core](https://www.microsoft.com/net/core) so that you can run your already compiled .NET Core applications.
- A set of native images for all of the ASP.NET Core libraries. These images will be used at runtime to increase the cold-start performance of your application. A significant amount of the time taken to JIT compile on startup of your application is typically spent compiling ASP.NET Core libraries rather than your application code. Given that these libraries are not going to change for a given version we include native images so that the runtime can load them instead of running the JIT.

## Supported tags

- [`1.0.1`, `latest` (*Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.0.1/jessie/product/Dockerfile)

## Example Usage

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

  This image sets the `ASPNETCORE_URLS` environment variable to `http://+:80` which means that if you have not explicity set a URL in your application, via `app.UseUrl` in your Program.cs for example, then your application will be listening on port 80. It also has `EXPOSE 80` in the base image so that port 80 will be exposed to linked containers, and to external traffic if it is run with `-P` or `-p`.
