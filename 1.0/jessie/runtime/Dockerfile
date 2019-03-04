FROM mcr.microsoft.com/dotnet/core/runtime:1.0.14-jessie

# set up network
ENV ASPNETCORE_URLS http://+:80

# set env var for packages cache
ENV DOTNET_HOSTING_OPTIMIZATION_CACHE /packagescache

# set up package cache and other tools
RUN for version in '1.0.4' '1.0.5' '1.0.6' '1.0.7' '1.0.8' '1.0.9'; do \
        curl -o /tmp/aspnetcore.cache.$version.tar.gz \
            https://dist.asp.net/packagecache/$version/debian.8-x64/aspnetcore.cache.tar.gz \
        && mkdir -p /packagescache \
        && cd /packagescache \
        && tar xf /tmp/aspnetcore.cache.$version.tar.gz \
        && rm /tmp/aspnetcore.cache.$version.tar.gz; \
    done
