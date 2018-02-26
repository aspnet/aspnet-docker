FROM microsoft/dotnet-nightly:2.1.300-preview1-sdk-bionic

# set up environment
ENV ASPNETCORE_URLS http://+:80

# set up node
ENV NODE_VERSION 8.9.4
ENV NODE_DOWNLOAD_SHA 21fb4690e349f82d708ae766def01d7fec1b085ce1f5ab30d9bda8ee126ca8fc

RUN curl -SL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz" --output nodejs.tar.gz \
    && echo "$NODE_DOWNLOAD_SHA nodejs.tar.gz" | sha256sum -c - \
    && tar -xzf "nodejs.tar.gz" -C /usr/local --strip-components=1 \
    && rm nodejs.tar.gz \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

# Ensure packages required for standalone apps are pre-fetched

# Set to ubuntu.16.04-x64 because preview1 doesn't yet support the ubuntu.18 RID
RUN mkdir /tmp/warmup \
    && cd /tmp/warmup \
    && dotnet new web --no-restore \
    && dotnet restore -p:RuntimeIdentifier=ubuntu.16.04-x64 \
        --source https://dotnet.myget.org/F/dotnet-core/api/v3/index.json \
        --source https://api.nuget.org/v3/index.json \
    && cd / \
    && rm -rf /tmp/warmup

WORKDIR /root/code
