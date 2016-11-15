# TODO pull from microsoft/dotnet when these become available
FROM microsoft/dotnet-nightly:1.1.0-runtime
# set env var for packages cache
ENV DOTNET_HOSTING_OPTIMIZATION_CACHE /packagescache

COPY ./build-cache.sh /packagescache/build-cache.sh

# set up package cache
RUN chmod +x /packagescache/build-cache.sh \
    && /packagescache/build-cache.sh \
    && rm /packagescache/build-cache.sh

# set up network
ENV ASPNETCORE_URLS http://+:80
