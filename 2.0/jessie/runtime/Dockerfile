FROM microsoft/dotnet:2.0.5-runtime-jessie

# set up network
ENV ASPNETCORE_URLS http://+:80
ENV ASPNETCORE_PKG_VERSION 2.0.5

# set up the runtime store
RUN for version in '2.0.0' '2.0.3' '2.0.5'; do \
        curl -o /tmp/runtimestore.tar.gz https://dist.asp.net/runtimestore/$version/linux-x64/aspnetcore.runtimestore.tar.gz \
        && export DOTNET_HOME=$(dirname $(readlink $(which dotnet))) \
        && tar -x -C $DOTNET_HOME -f /tmp/runtimestore.tar.gz \
        && rm /tmp/runtimestore.tar.gz; \
    done
