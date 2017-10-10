FROM microsoft/dotnet:2.0.0-sdk-2.0.2-jessie

# set up environment
ENV ASPNETCORE_URLS http://+:80
ENV NODE_VERSION 6.11.3
ENV ASPNETCORE_PKG_VERSION 2.0.0

RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" ; \
  done

# set up node
RUN buildDeps='xz-utils' \
    && set -x \
    && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
    && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
    && apt-get purge -y --auto-remove $buildDeps \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    # set up bower and gulp
    && npm install -g bower gulp \
    && echo '{ "allow_root": true }' > /root/.bowerrc

# Install the 1.x runtimes
RUN for url in \
      'https://dotnetcli.blob.core.windows.net/dotnet/release/1.1.0/Binaries/1.1.4/dotnet-debian-x64.1.1.4.tar.gz' \
      'https://dotnetcli.blob.core.windows.net/dotnet/preview/Binaries/1.0.7/dotnet-debian-x64.1.0.7.tar.gz'; \
    do \
      echo "Downloading and installing from $url" \
      && curl -SL $url --output /tmp/dotnet.tar.gz \
      && mkdir -p /usr/share/dotnet \
      && tar -zxf /tmp/dotnet.tar.gz -C /usr/share/dotnet \
      && rm /tmp/dotnet.tar.gz; \
    done

# Add Docker SDK for when building a solution that has the Docker tools project.
RUN curl -H 'Cache-Control: no-cache' -o /tmp/Microsoft.Docker.Sdk.tar.gz https://distaspnet.blob.core.windows.net/sdk/Microsoft.Docker.Sdk.tar.gz \
    && cd /usr/share/dotnet/sdk/${DOTNET_SDK_VERSION}/Sdks \
    && tar xf /tmp/Microsoft.Docker.Sdk.tar.gz \
    && rm /tmp/Microsoft.Docker.Sdk.tar.gz

# copy the ASP.NET packages manifest
COPY packagescache.csproj /tmp/warmup/

# warm up package cache
RUN dotnet restore /tmp/warmup/packagescache.csproj \
      --source https://api.nuget.org/v3/index.json \
      --verbosity quiet \
    && rm -rf /tmp/warmup/

WORKDIR /
