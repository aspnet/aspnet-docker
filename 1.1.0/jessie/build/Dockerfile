# base
FROM debian:jessie

# install .NET Core dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libc6 \
        libcurl3 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu52 \
        liblttng-ust0 \
        libssl1.0.0 \
        libstdc++6 \
        libunwind8 \
        libuuid1 \
        zlib1g \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# set up .NET Core SDK
RUN curl -o /tmp/dotnetsdk.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/preview/Binaries/1.0.0-preview2.1-003155/dotnet-dev-debian-x64.1.0.0-preview2.1-003155.tar.gz && \
    mkdir /usr/share/dotnet && cd /usr/share/dotnet && \
    tar xvf /tmp/dotnetsdk.tar.gz && \
    rm /tmp/dotnetsdk.tar.gz && \
    cd && \
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# set up network
ENV ASPNETCORE_URLS http://+:80

# set env var for packages cache
ENV DOTNET_HOSTING_OPTIMIZATION_CACHE /packagescache

# set env var for skipping .NET Core SDK first time experience
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1

# set env var for minimizing package restore footprint
ENV NUGET_XMLDOC_MODE Skip

# copy the ASP.NET packages manifest
COPY packagescache.project.json /tmp/packagescache.project.json

RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NODE_VERSION 4.5.0

# set up node 
RUN buildDeps='xz-utils' \
    && set -x \
    && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
    && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
    && apt-get purge -y --auto-remove $buildDeps \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

# set up package cache and other tools
RUN curl -o /tmp/packagescache.tar.gz \
    https://distaspnet.blob.core.windows.net/packagecache/1.1.0/aspnetcore.packagecache-1.1.0-preview1-final-debian.8-x64.tar.gz && \
    mkdir /packagescache && cd /packagescache && \
    tar xvf /tmp/packagescache.tar.gz && \
    rm /tmp/packagescache.tar.gz && \
    # restore packages
    dotnet restore /tmp/packagescache.project.json \
        --source https://dotnet.myget.org/F/aspnet-1-1-0-preview1/api/v3/index.json \
        --source https://api.nuget.org/v3/index.json && \
    rm /tmp/packagescache.project.json && \
    # set up bower and gulp
    npm install -g bower gulp

WORKDIR /
