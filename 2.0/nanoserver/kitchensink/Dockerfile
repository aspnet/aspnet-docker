# escape=`
FROM microsoft/dotnet-nightly:2.0.0-preview3-sdk-nanoserver-10.0.14393.1480

# set up environment
ENV ASPNETCORE_URLS http://+:80
ENV NODE_VERSION 6.11.1
ENV ASPNETCORE_BUILD_VERSION 2.0.0-rtm-26424

# Install node, bower, and git
RUN Invoke-WebRequest -UseBasicParsing https://nodejs.org/dist/v${env:NODE_VERSION}/node-v${env:NODE_VERSION}-win-x64.zip -outfile node.zip; `
    Expand-Archive node.zip -DestinationPath ${env:TEMP}/nodejs-tmp; `
    Move-Item ${env:TEMP}/nodejs-tmp/node-v${env:NODE_VERSION}-win-x64 ${env:ProgramFiles}/nodejs; `
    Remove-Item -Force node.zip; `
    $env:PATH += \";${env:ProgramFiles}/nodejs\"; `
    & npm install -g gulp bower; `
    Invoke-WebRequest -UseBasicParsing https://github.com/git-for-windows/git/releases/download/v2.13.1.windows.1/MinGit-2.13.1-64-bit.zip -outfile git.zip; `
    Expand-Archive git.zip -DestinationPath $Env:ProgramFiles/git; `
    Remove-Item -Force git.zip

RUN setx /M PATH $($Env:PATH + ';' + $Env:ProgramFiles + '/nodejs' + ';' + $Env:ProgramFiles + '/git/cmd')

RUN ('https://dotnetcli.blob.core.windows.net/dotnet/preview/Binaries/1.0.5/dotnet-win-x64.1.0.5.zip', `
     'https://dotnetcli.blob.core.windows.net/dotnet/release/1.1.0/Binaries/1.1.2/dotnet-win-x64.1.1.2.zip' ) `
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
        --source https://dotnet.myget.org/F/aspnetcore-release/api/v3/index.json `
        --source https://dotnet.myget.org/F/dotnet-core/api/v3/index.json `
        --source https://api.nuget.org/v3/index.json; `
    Remove-Item -Recurse -Force C:/warmup
