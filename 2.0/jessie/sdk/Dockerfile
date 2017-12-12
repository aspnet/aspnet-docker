FROM microsoft/dotnet:2.0.4-sdk-2.1.3-jessie

# set up environment
ENV ASPNETCORE_URLS http://+:80
ENV ASPNETCORE_PKG_VERSION 2.0.3

# set up node
# See https://nodejs.org/dist/v6.11.3/SHASUMS256.txt.asc
ENV NODE_VERSION 6.11.3
ENV NODE_DOWNLOAD_URL https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz
ENV NODE_DOWNLOAD_SHA 610705D45EB2846A9E10690678A078D9159E5F941487ACA20C6F53B33104358C

RUN curl -SL "$NODE_DOWNLOAD_URL" --output nodejs.tar.gz \
    && echo "$NODE_DOWNLOAD_SHA nodejs.tar.gz" | sha256sum -c - \
    && tar -xzf "nodejs.tar.gz" -C /usr/local --strip-components=1 \
    && rm nodejs.tar.gz \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    # set up bower and gulp
    && npm install -g bower gulp \
    && echo '{ "allow_root": true }' > /root/.bowerrc

# warmup NuGet package cache
COPY packagescache.csproj /tmp/warmup/
RUN dotnet restore /tmp/warmup/packagescache.csproj \
      --source https://api.nuget.org/v3/index.json \
      --verbosity quiet \
    && rm -rf /tmp/warmup/

WORKDIR /
