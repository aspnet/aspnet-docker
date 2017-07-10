FROM microsoft/dotnet-nightly:2.0.0-preview3-runtime-stretch

# set up network
ENV ASPNETCORE_URLS http://+:80

# set up the runtime store
RUN curl -o /tmp/runtimestore.tar.gz \
    https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/store/dev-270/Build.RS.linux.tar.gz \
    && export DOTNET_HOME=$(dirname $(readlink $(which dotnet))) \
    && tar -x -C $DOTNET_HOME -f /tmp/runtimestore.tar.gz \
    && rm /tmp/runtimestore.tar.gz
