
ASP.NET Core Build Docker Image
===============================

This repository contains images that are used to compile/publish ASP.NET Core applications inside the container. This is different to compiling an ASP.NET Core application and then adding the compiled output to an image, which is what you would do when using the [microsoft/aspnetcore](https://hub.docker.com/r/microsoft/aspnetcore/) image. These Dockerfiles use the [microsoft/dotnet](https://hub.docker.com/r/microsoft/dotnet/) image as its base.

# Supported Linux amd64 tags

- [`1.1.5-1.1.6-jessie`, `1.1.5-1.1.6`, `1.1`, `1` (*1.1/jessie/sdk/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.1/jessie/sdk/Dockerfile)
- [`2.0.4-2.1.3-stretch`, `2.0-stretch`, `2.0.4-2.1.3`, `2.0`, `2`, `latest` (*2.0/stretch/sdk/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/2.0/stretch/sdk/Dockerfile)
- [`2.0.4-2.1.3-jessie`, `2.0-jessie`, `2-jessie` (*2.0/jessie/sdk/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/2.0/jessie/sdk/Dockerfile)
- [`1.0-1.1-jessie`, `1.0-1.1` (*1.1/jessie/kitchensink/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.1/jessie/kitchensink/Dockerfile)
- [`1.0-2.0-stretch`, `1.0-2.0` (*2.0/stretch/kitchensink/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/2.0/stretch/kitchensink/Dockerfile)
- [`1.0-2.0-jessie` (*2.0/jessie/kitchensink/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/2.0/jessie/kitchensink/Dockerfile)

# Supported Windows Server 2016 Version 1709 (Fall Creators Update) amd64 tags

- [`2.0.4-2.1.3-nanoserver-1709`, `2.0-nanoserver-1709`, `2.0.4-2.1.3`, `2.0`, `2`, `latest` (*2.0/nanoserver-1709/sdk/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/2.0/nanoserver-1709/sdk/Dockerfile)
- [`1.0-2.0-nanoserver-1709`, `1.0-2.0` (*2.0/nanoserver-1709/kitchensink/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/2.0/nanoserver-1709/kitchensink/Dockerfile)

# Supported Windows Server 2016 amd64 tags

- [`1.1.5-1.1.6-nanoserver-sac2016`, `1.1.5-1.1.6`, `1.1`, `1` (*1.1/nanoserver-sac2016/sdk/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.1/nanoserver-sac2016/sdk/Dockerfile)
- [`2.0.4-2.1.3-nanoserver-sac2016`, `2.0-nanoserver-sac2016`, `2.0.4-2.1.3`, `2.0`, `2`, `latest` (*2.0/nanoserver-sac2016/sdk/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/2.0/nanoserver-sac2016/sdk/Dockerfile)
- [`1.0-1.1-nanoserver-sac2016`, `1.0-1.1` (*1.1/nanoserver-sac2016/kitchensink/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/1.1/nanoserver-sac2016/kitchensink/Dockerfile)
- [`1.0-2.0-nanoserver-sac2016`, `1.0-2.0` (*2.0/nanoserver-sac2016/kitchensink/Dockerfile*)](https://github.com/aspnet/aspnet-docker/blob/master/2.0/nanoserver-sac2016/kitchensink/Dockerfile)

>**Note:** ASP.NET Core multi-arch tags, such as 2.0, have been updated to use nanoserver-1709 images if your host is Windows Server 2016 Version 1709 or higher or Windows 10 Fall Creators Update (Version 1709) or higher. You need Docker 17.10 or later to take advantage of these updated tags.

>**Note:** In images tagged with two versions in this pattern `A.B.C-X.Y.Z`, the first version `A.B.C` represents the .NET Core runtime version, and the second `X.Y.Z` represents the .NET Core SDK version.

# What is ASP.NET Core?

ASP.NET Core is a new open-source and cross-platform framework for building modern cloud based internet connected applications, such as web apps, IoT apps and mobile backends. It consists of modular components with minimal overhead, so you retain flexibility while constructing your solutions. You can develop and run your ASP.NET Core apps cross-platform on Windows, Mac and Linux. ASP.NET Core is open source at [GitHub](https://github.com/aspnet).

This image contains:

- [.NET Core SDK](https://github.com/dotnet/cli) so that you can create, build and run your .NET Core applications.
- A NuGet package cache for the ASP.NET Core libraries.  This will significantly improve the initial package restore performance when building ASP.NET Core application.
- [Node.js](https://nodejs.org)
- [Bower](https://bower.io/)
- [Gulp](http://gulpjs.com/)

The CI Image (`1.0-2.0`) contains the 1.0, 1.1, and 2.0 pre-restored packages. It is intended for when you have a solution containing both 2.x and 1.x projects and want to build them all in the same container, gaining advantage of the pre-restored packages. Because it has an extra set of packages it is bigger than the other, more focused, images.

# Related images

1. [microsoft/dotnet](https://hub.docker.com/r/microsoft/dotnet/) - the .NET Core image if you don't need the ASP.NET Core specific optimizations.
2. [microsoft/aspnetcore](https://hub.docker.com/r/microsoft/aspnetcore/) - the ASP.NET Core runtime image, for when you don't need to build inside a container.

# Example Usage

## Build an app with `docker build`

With this technique your application is compiled in two stages when you run `docker build`. Docker 17.05 or newer is required.

Stage 1 compiles and publishes the application by using the `microsoft/aspnetcore-build` image. Stage 2 copies the published application
from Stage 1 into the final image leaving behind all of the source code and tooling needed to build.

1. Create a `.dockerignore` file in your project folder and exclude files that shouldn't be copied into the container:

    ```
    # Sample contents of .dockerignore file
    bin/
    obj/
    node_modules/
    ```

1. Create a `Dockerfile` in your project:

    ```Dockerfile
    # Sample contents of Dockerfile
    # Stage 1
    FROM microsoft/aspnetcore-build AS builder
    WORKDIR /source

    # caches restore result by copying csproj file separately
    COPY *.csproj .
    RUN dotnet restore

    # copies the rest of your code
    COPY . .
    RUN dotnet publish --output /app/ --configuration Release

    # Stage 2
    FROM microsoft/aspnetcore
    WORKDIR /app
    COPY --from=builder /app .
    ENTRYPOINT ["dotnet", "myapp.dll"]
    ```

    This approach has the advantage of caching the results of `dotnet restore` so that packages are not downloaded unless you change your
    project file.

1. Build your image:

    ```
    $ docker build -t myapp .
    ```

1. (Linux containers) Start a container from your image. This will expose port 5000 so you can browse it locally at <http://locahost:5000>.

    ```
    $ docker run -it -p 5000:80 myapp
    ```

1. (Windows containers) Start a container from your image, get its assigned IP address, and then open your browser to the IP address
    of the container on port 80. To see console output, attach to the running container or use `docker logs`.

    ```
    PS> docker run --detach --name myapp_container myapp
    PS> docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' myapp_container
    PS> docker attach myapp_container
    ```

## Build an app with `docker run`

You can use this container to compile your application when it runs. If you use the [Visual Studio tooling](https://blogs.msdn.microsoft.com/webdev/2016/11/16/new-docker-tools-for-visual-studio/) to setup CI/CD to Azure Container Service then this method of using the build container is used.

Run the build container, mounting your code and output directory, and publish your app:

```
docker run -it -v $(PWD):/app --workdir /app microsoft/aspnetcore-build bash -c "dotnet restore && dotnet publish -c Release -o ./bin/Release/PublishOutput"
```

After this is completed, the application in the current directory will be published to the `bin/Release/PublishOutput` directory.
