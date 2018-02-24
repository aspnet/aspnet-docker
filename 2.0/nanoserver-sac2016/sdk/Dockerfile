# escape=`
FROM microsoft/dotnet:2.0.5-sdk-2.1.4-nanoserver-sac2016

# set up environment
ENV ASPNETCORE_URLS http://+:80
ENV NODE_VERSION 6.12.3
ENV ASPNETCORE_PKG_VERSION 2.0.5

# Install node, bower, and git
RUN Invoke-WebRequest -UseBasicParsing https://nodejs.org/dist/v${env:NODE_VERSION}/node-v${env:NODE_VERSION}-win-x64.zip -outfile node.zip; `
    Expand-Archive node.zip -DestinationPath ${env:TEMP}/nodejs-tmp; `
    Move-Item ${env:TEMP}/nodejs-tmp/node-v${env:NODE_VERSION}-win-x64 ${env:ProgramFiles}/nodejs; `
    Remove-Item -Force node.zip; `
    $env:PATH += \";${env:ProgramFiles}/nodejs\"; `
    & npm install -g gulp bower; `
    Invoke-WebRequest -UseBasicParsing https://github.com/git-for-windows/git/releases/download/v2.16.2.windows.1/MinGit-2.16.2-64-bit.zip -outfile git.zip; `
    Expand-Archive git.zip -DestinationPath $Env:ProgramFiles/git; `
    Remove-Item -Force git.zip

RUN setx /M PATH $($Env:PATH + ';' + $Env:ProgramFiles + '/nodejs' + ';' + $Env:ProgramFiles + '/git/cmd')

# warmup up NuGet package cache
COPY packagescache.csproj C:/warmup/packagescache.csproj

RUN dotnet restore C:/warmup/packagescache.csproj `
        --source https://api.nuget.org/v3/index.json `
        --verbosity quiet; `
    Remove-Item -Recurse -Force C:/warmup
