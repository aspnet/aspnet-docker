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

# set up .NET Core Runtime
RUN curl -o /tmp/dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/release/1.1.0/Binaries/1.1.0-preview1-001100-00/dotnet-debian-x64.1.1.0-preview1-001100-00.tar.gz && \
    mkdir /usr/share/dotnet && cd /usr/share/dotnet && \
    tar xvf /tmp/dotnet.tar.gz && \
    rm /tmp/dotnet.tar.gz && \
    cd && \
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# set up package cache
RUN curl -o /tmp/packagescache.tar.gz https://distaspnet.blob.core.windows.net/packagecache/1.1.0/aspnetcore.packagecache-1.1.0-preview1-final-debian.8-x64.tar.gz && \
    mkdir /packagescache && cd /packagescache && \
    tar xvf /tmp/packagescache.tar.gz && \
    rm /tmp/packagescache.tar.gz && \
    cd /

# set env var for packages cache
ENV DOTNET_HOSTING_OPTIMIZATION_CACHE /packagescache

# set up network
ENV ASPNETCORE_URLS http://+:80
