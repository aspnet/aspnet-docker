# base
FROM microsoft/dotnet:1.0.0-preview2-sdk

# set up network
ENV ASPNETCORE_URLS http://+:80

# set env var for packages cache
ENV DOTNET_HOSTING_OPTIMIZATION_CACHE $cache_dir

# set env var for minimizing package restore footprint
ENV NUGET_XMLDOC_MODE Skip

# copy the ASP.NET packages manifest
COPY packagescache.project.json /tmp/packagescache.project.json

# set up package cache
RUN curl -o /tmp/packagescache.tar.gz https://dist.asp.net/packagecache/aspnetcore.packagecache-1.0.0-debian.8-x64.tar.gz && \
    mkdir /packagescache && cd /packagescache && \
    tar xvf /tmp/packagescache.tar.gz && \
    rm /tmp/packagescache.tar.gz && \
    # restore 1.0.0 ASP.NET packages
    cd /tmp && dotnet restore packagescache.project.json && \
    rm /tmp/packagescache.project.json && \
    cd /
