# escape=`
FROM microsoft/dotnet:1.0.4-sdk-nanoserver-10.0.14393.953

# Install node
ENV NODE_VERSION 6.10.0

RUN Invoke-WebRequest https://nodejs.org/dist/v${env:NODE_VERSION}/node-v${env:NODE_VERSION}-win-x64.zip -outfile node.zip; `
    Expand-Archive node.zip -DestinationPath ${env:TEMP}/nodejs-tmp; `
    Move-Item ${env:TEMP}/nodejs-tmp/node-v${env:NODE_VERSION}-win-x64 ${env:ProgramFiles}/nodejs; `
    Remove-Item -Force node.zip; `
    $env:PATH += \";${env:ProgramFiles}/nodejs\"; `
    & npm install -g gulp bower

RUN setx /M PATH $($Env:PATH + ';' + $Env:ProgramFiles + '\nodejs')

# set up network
ENV ASPNETCORE_URLS http://+:80

# warmup up NuGet package cache
COPY packagescache.csproj C:/warmup/packagescache.csproj

RUN dotnet restore C:/warmup/packagescache.csproj `
      --source https://api.nuget.org/v3/index.json; `
    Remove-Item -Recurse -Force C:/warmup
