FROM microsoft/dotnet-nightly:2.0.0-preview2-runtime

# set up network
ENV ASPNETCORE_URLS http://+:80

# set up the runtime store
ENV ASPNETCORE_RUNTIME_STORE_VERSION 2.0.0-preview2-25704
RUN curl -o /tmp/runtimestore.tar.gz \
    https://aspnetci.blob.core.windows.net/runtimestore/${ASPNETCORE_RUNTIME_STORE_VERSION}/linux-x64/aspnetcore.runtimestore.tar.gz \
    && export DOTNET_HOME=$(dirname $(readlink $(which dotnet))) \
    && tar -x -C $DOTNET_HOME -f /tmp/runtimestore.tar.gz \
    && rm /tmp/runtimestore.tar.gz
