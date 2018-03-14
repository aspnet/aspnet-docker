# escape=`
FROM microsoft/dotnet:1.1.7-sdk-1.1.8-nanoserver-sac2016

# set up environment
ENV ASPNETCORE_URLS http://+:80
ENV NODE_VERSION 6.13.0
ENV NODE_DOWNLOAD_SHA 3d3d72c5c93a50d5a19f65f0de196b5237792a99b89fac2b61e62da4f566c842

# Install node, bower, and git
RUN Invoke-WebRequest -UseBasicParsing https://nodejs.org/dist/v${env:NODE_VERSION}/node-v${env:NODE_VERSION}-win-x64.zip -outfile node.zip; `
    if ((Get-FileHash node.zip -Algorithm sha256).Hash -ne $env:NODE_DOWNLOAD_SHA) { `
        Write-Host 'NODEJS CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    `
    Expand-Archive node.zip -DestinationPath ${env:TEMP}/nodejs-tmp; `
    Move-Item ${env:TEMP}/nodejs-tmp/node-v${env:NODE_VERSION}-win-x64 ${env:ProgramFiles}/nodejs; `
    Remove-Item -Force node.zip; `
    $env:PATH += \";${env:ProgramFiles}/nodejs\"; `
    & npm install -g gulp bower; `
    Invoke-WebRequest -UseBasicParsing https://github.com/git-for-windows/git/releases/download/v2.16.2.windows.1/MinGit-2.16.2-64-bit.zip -outfile git.zip; `
    Expand-Archive git.zip -DestinationPath $Env:ProgramFiles/git; `
    Remove-Item -Force git.zip

RUN setx /M PATH $($Env:PATH + ';' + $Env:ProgramFiles + '/nodejs' + ';' + $Env:ProgramFiles + '/git/cmd')

# Add Docker SDK for when building a solution that has the Docker tools project.
RUN Invoke-WebRequest -UseBasicParsing https://distaspnet.blob.core.windows.net/sdk/Microsoft.Docker.Sdk.zip -OutFile sdk.zip; `
    Expand-Archive sdk.zip -DestinationPath \"${Env:ProgramFiles}/dotnet/sdk/${env:DOTNET_SDK_VERSION}/Sdks\"; `
    Remove-Item -Force sdk.zip

# warmup up NuGet package cache
COPY packagescache.csproj C:/warmup/packagescache.csproj
RUN dotnet restore C:/warmup/packagescache.csproj `
        --source https://api.nuget.org/v3/index.json `
        --verbosity quiet; `
    Remove-Item -Recurse -Force C:/warmup
