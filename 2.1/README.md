HTTP 301 Moved Permanently
--------------------------

**Where are the 2.1 aspnet-docker images?**

In 2.1\*, the ASP.NET Core Docker images have migrated to https://github.com/dotnet/dotnet-docker.

_\*Note: ASP.NET Core 2.1 is still in preview._

**How can I upgrade from 1.x/2.0 to 2.1?**

You can upgrade to 2.1 and by changing the repository name in the `FROM` line in your Dockerfile using this mapping:

Current | Upgrade
--------|--------------
`microsoft/aspnetcore:1.0`<br>`microsoft/aspnetcore:1.1`<br>`microsoft/aspnetcore:2.0` | `microsoft/dotnet:2.1-aspnetcore-runtime`
`microsoft/aspnetcore-build:1.0`<br>`microsoft/aspnetcore-build:1.1`<br>`microsoft/aspnetcore-build:2.0` | `microsoft/dotnet:2.1-sdk`

**I was using NodeJS in `microsoft/aspnetcore-build`, but this is missing from `microsoft/dotnet:2.1-sdk`. What should I do?**

You can either install NodeJS by adding a few lines of code to your Dockerfile that download and extract NodeJS, 
or you can use the multi-stage feature of Docker and the official NodeJS images.

Sample code to install NodeJS on your own:

```Dockerfile
# set up node
ENV NODE_VERSION 8.9.4
ENV NODE_DOWNLOAD_SHA 21fb4690e349f82d708ae766def01d7fec1b085ce1f5ab30d9bda8ee126ca8fc
RUN curl -SL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz" --output nodejs.tar.gz \
    && echo "$NODE_DOWNLOAD_SHA nodejs.tar.gz" | sha256sum -c - \
    && tar -xzf "nodejs.tar.gz" -C /usr/local --strip-components=1 \
    && rm nodejs.tar.gz \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs
```

Sample code to use multi-arch build
```Dockerfile
FROM node:8 AS node-builder
WORKDIR /src
COPY . .
RUN npm run webpack

FROM microsoft/dotnet:2.1-sdk AS dotnet-builder
WORKDIR /app
COPY --from=node-builder /src/dist/*.js  ./dist
```
