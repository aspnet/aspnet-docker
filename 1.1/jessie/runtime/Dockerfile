FROM microsoft/dotnet:1.1.10-runtime

# set up network
ENV ASPNETCORE_URLS http://+:80

# set env var for packages cache
ENV DOTNET_HOSTING_OPTIMIZATION_CACHE /packagescache

# set up package cache and other tools
RUN for version in '1.1.2' '1.1.3' '1.1.4' '1.1.5' '1.1.6' '1.1.7' '1.1.8'; do \
        curl -o /tmp/aspnetcore.cache.$version.tar.gz \
            https://dist.asp.net/packagecache/$version/debian.8-x64/aspnetcore.cache.tar.gz \
        && mkdir -p /packagescache \
        && cd /packagescache \
        && tar xf /tmp/aspnetcore.cache.$version.tar.gz \
        && rm /tmp/aspnetcore.cache.$version.tar.gz; \
    done
