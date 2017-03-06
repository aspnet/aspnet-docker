FROM microsoft/dotnet:1.1.1-runtime

# set up network
ENV ASPNETCORE_URLS http://+:80

# set env var for packages cache
ENV DOTNET_HOSTING_OPTIMIZATION_CACHE /packagescache
ENV ASPNETCORE_CACHE_VERSION 1.1.2

# set up package cache and other tools
RUN curl -o /tmp/packagescache.tar.gz \
    https://dist.asp.net/packagecache/${ASPNETCORE_CACHE_VERSION}/debian.8-x64/aspnetcore.cache.tar.gz \
    && mkdir /packagescache && cd /packagescache \
    && tar xvf /tmp/packagescache.tar.gz \
    && rm /tmp/packagescache.tar.gz
