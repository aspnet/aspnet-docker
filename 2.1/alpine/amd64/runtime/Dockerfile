FROM microsoft/dotnet-nightly:2.1-runtime-deps-alpine

# set up network
ENV ASPNETCORE_URLS http://+:80

# Workaround https://github.com/aspnet/libuv-package/issues/23
# Install libuv globally and link it so coreclr can laod it
RUN apk add --no-cache libuv \
    && ln -s /usr/lib/libuv.so.1 /usr/lib/libuv.so

# Install ASP.NET Core
ENV ASPNETCORE_VERSION 2.1.0-preview2-30338

RUN apk add --no-cache --virtual .build-deps \
        openssl \
    && wget -O aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-alpine.3.6-x64.tar.gz \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet \
    && rm aspnetcore.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && apk del .build-deps
