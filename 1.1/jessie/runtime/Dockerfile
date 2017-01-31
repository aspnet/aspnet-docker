FROM microsoft/dotnet:1.1.0-runtime

# set env var for packages cache
ENV DOTNET_HOSTING_OPTIMIZATION_CACHE /packagescache

COPY ./build-cache.sh /packagescache/build-cache.sh

# set up package cache
RUN /packagescache/build-cache.sh https://dist.asp.net/packagecache/1.1.0/aspnetcore.packagecache-1.1.0-legacy-debian.8-x64.tar.gz \
    && rm /packagescache/build-cache.sh

# set up network
ENV ASPNETCORE_URLS http://+:80
