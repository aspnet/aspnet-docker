# base
FROM microsoft/dotnet:1.0.3-runtime

# set env var for packages cache
ENV DOTNET_HOSTING_OPTIMIZATION_CACHE /packagescache

COPY ./build-cache.sh /packagescache/build-cache.sh

# set up package cache
RUN /packagescache/build-cache.sh http://dist.asp.net/packagecache/1.0.3/debian.8-x64/aspnetcore.cache.legacy.tar.gz \
    && rm /packagescache/build-cache.sh

# set up network
ENV ASPNETCORE_URLS http://+:80
