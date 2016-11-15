# base
FROM microsoft/dotnet:1.0.1-core

# set env var for packages cache
ENV DOTNET_HOSTING_OPTIMIZATION_CACHE /packagescache

COPY ./build-cache.sh /packagescache/build-cache.sh

# set up package cache
RUN chmod +x /packagescache/build-cache.sh \
    && /packagescache/build-cache.sh http://dist.asp.net/packagecache/aspnetcore.packagecache-1.0.1-debian.8-x64.tar.gz \
    && rm /packagescache/build-cache.sh

# set up network
ENV ASPNETCORE_URLS http://+:80
