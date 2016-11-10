# TODO pull from microsoft/dotnet when these become available
FROM microsoft/dotnet-nightly:1.1.0-runtime

# set up package cache
RUN curl -o /tmp/packagescache.tar.gz https://distaspnet.blob.core.windows.net/packagecache/1.1.0/aspnetcore.packagecache-1.1.0-debian.8-x64.tar.gz && \
    mkdir /packagescache && cd /packagescache && \
    tar xvf /tmp/packagescache.tar.gz && \
    rm /tmp/packagescache.tar.gz && \
    cd /

# set env var for packages cache
ENV DOTNET_HOSTING_OPTIMIZATION_CACHE /packagescache

# set up network
ENV ASPNETCORE_URLS http://+:80
