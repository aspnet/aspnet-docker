# escape=`
FROM microsoft/dotnet:2.0.6-sdk-2.1.101-nanoserver-sac2016

# set up environment
ENV ASPNETCORE_URLS http://+:80
ENV NETCORE_1_0_RUNTIME_VERSION 1.0.10
ENV NETCORE_1_1_RUNTIME_VERSION 1.1.7
ENV ASPNETCORE_PKG_VERSION 2.0.6
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

RUN @(\"https://dotnetcli.blob.core.windows.net/dotnet/Runtime/${env:NETCORE_1_0_RUNTIME_VERSION}/dotnet-win-x64.${env:NETCORE_1_0_RUNTIME_VERSION}.zip\", `
     \"https://dotnetcli.blob.core.windows.net/dotnet/Runtime/${env:NETCORE_1_1_RUNTIME_VERSION}/dotnet-win-x64.${env:NETCORE_1_1_RUNTIME_VERSION}.zip\" ) `
     | % { `
        Invoke-WebRequest $_ -UseBasicParsing -OutFile dotnet.zip; `
        # Ignore errors and don't use -Force. We want to keep the existing dotnet.exe instead of overwriting `
        Expand-Archive dotnet.zip -DestinationPath \"${Env:ProgramFiles}/dotnet\" -ErrorAction SilentlyContinue; `
        Remove-Item -Force dotnet.zip; `
     }

# Add Docker SDK for when building a solution that has the Docker tools project.
RUN Invoke-WebRequest -UseBasicParsing https://distaspnet.blob.core.windows.net/sdk/Microsoft.Docker.Sdk.zip -OutFile sdk.zip; `
    Expand-Archive sdk.zip -DestinationPath \"${Env:ProgramFiles}/dotnet/sdk/${env:DOTNET_SDK_VERSION}/Sdks\"; `
    Remove-Item -Force sdk.zip

# warmup up NuGet package cache
COPY packagescache.csproj C:/warmup/packagescache.csproj
RUN dotnet restore C:/warmup/packagescache.csproj `
        --source https://dotnet.myget.org/F/aspnetcore-dev/api/v3/index.json `
        --source https://dotnet.myget.org/F/dotnet-core/api/v3/index.json `
        --source https://api.nuget.org/v3/index.json `
        --verbosity quiet; `
    Remove-Item -Recurse -Force C:/warmup

# Workaround for https://github.com/Microsoft/DockerTools/issues/87. This instructs NuGet to use 4.5 behavior in which
# all errors when attempting to restore a project are ignored and treated as warnings instead. This allows the VS
# tooling to use -nowarn:MSB3202 to ignore issues with the .dcproj project
ENV RestoreUseSkipNonexistentTargets false
