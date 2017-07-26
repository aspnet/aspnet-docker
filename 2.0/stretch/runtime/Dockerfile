FROM microsoft/dotnet-nightly:2.0.0-runtime-stretch

# set up network
ENV ASPNETCORE_URLS http://+:80
ENV ASPNETCORE_RUNTIMESTORE_DOWNLOAD_URL https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/store/2.0.0-26452/Build.RS.linux.tar.gz
ENV ASPNETCORE_PKG_VERSION 2.0.0

# set up the runtime store
RUN curl -o /tmp/runtimestore.tar.gz $ASPNETCORE_RUNTIMESTORE_DOWNLOAD_URL \
    && export DOTNET_HOME=$(dirname $(readlink $(which dotnet))) \
    && tar -x -C $DOTNET_HOME -f /tmp/runtimestore.tar.gz \
    && rm /tmp/runtimestore.tar.gz
