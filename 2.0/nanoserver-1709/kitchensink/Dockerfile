# escape=`

# Installer image
FROM microsoft/windowsservercore:1709 AS installer-env

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# versions of stuff
ENV NETCORE_1_0_RUNTIME_VERSION 1.0.10
ENV NETCORE_1_1_RUNTIME_VERSION 1.1.7

# Retrieve node and git
ENV NODE_VERSION 6.13.0
ENV NODE_DOWNLOAD_SHA 3d3d72c5c93a50d5a19f65f0de196b5237792a99b89fac2b61e62da4f566c842

RUN Invoke-WebRequest -UseBasicParsing https://nodejs.org/dist/v${env:NODE_VERSION}/node-v${env:NODE_VERSION}-win-x64.zip -outfile node.zip; `
    if ((Get-FileHash node.zip -Algorithm sha256).Hash -ne $env:NODE_DOWNLOAD_SHA) { `
        Write-Host 'NODEJS CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    `
    Expand-Archive node.zip -DestinationPath nodejs-tmp; `
    Move-Item nodejs-tmp/node-v${env:NODE_VERSION}-win-x64 nodejs; `
    Remove-Item -Force node.zip; `
    Remove-Item -Force nodejs-tmp; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -UseBasicParsing https://github.com/git-for-windows/git/releases/download/v2.16.2.windows.1/MinGit-2.16.2-64-bit.zip -outfile git.zip; `
    Expand-Archive git.zip -DestinationPath git; `
    Remove-Item -Force git.zip

# Retrieve additional runtimes
RUN @(\"https://dotnetcli.blob.core.windows.net/dotnet/Runtime/${env:NETCORE_1_0_RUNTIME_VERSION}/dotnet-win-x64.${env:NETCORE_1_0_RUNTIME_VERSION}.zip\", `
     \"https://dotnetcli.blob.core.windows.net/dotnet/Runtime/${env:NETCORE_1_1_RUNTIME_VERSION}/dotnet-win-x64.${env:NETCORE_1_1_RUNTIME_VERSION}.zip\" ) `
     | % { `
        Invoke-WebRequest $_ -UseBasicParsing -OutFile dotnet.zip; `
        # Ignore errors and don't use -Force. We want to keep the existing dotnet.exe instead of overwriting `
        Expand-Archive dotnet.zip -DestinationPath dotnet -ErrorAction SilentlyContinue; `
        Remove-Item -Force dotnet.zip; `
     }

# Retrieve Docker SDK for when building a solution that has the Docker tools project.
RUN Invoke-WebRequest -UseBasicParsing https://distaspnet.blob.core.windows.net/sdk/Microsoft.Docker.Sdk.zip -OutFile sdk.zip; `
    Expand-Archive sdk.zip -DestinationPath sdks; `
    Remove-Item -Force sdk.zip


# Kitchen Sink image
FROM microsoft/dotnet:2.0.6-sdk-2.1.104-nanoserver-1709

# Note: Kitchen Sink image's SHELL is the CMD shell (different than the installer image).

# Set up environment
ENV ASPNETCORE_URLS http://+:80
ENV ASPNETCORE_PKG_VERSION 2.0.6

# Install node, bower, and git
COPY --from=installer-env ["nodejs", "C:\\Program Files\\nodejs"]
RUN ""C:\Program Files\nodejs\npm"" install -g gulp bower
COPY --from=installer-env ["git", "C:\\Program Files\\git"]
RUN setx PATH "%PATH%;C:\Program Files\nodejs;C:\Program Files\git\cmd"

# Add additional runtimes
COPY --from=installer-env ["dotnet\\host", "C:\\Program Files\\dotnet\\host"]
COPY --from=installer-env ["dotnet\\shared", "C:\\Program Files\\dotnet\\shared"]

# Add Docker SDK
COPY --from=installer-env ["sdks", "C:\\Program Files\\dotnet\\sdk\\2.0.3\\Sdks"]

# Warmup up NuGet package cache
RUN mkdir C:\warmup
COPY packagescache.csproj C:\warmup\packagescache.csproj
RUN dotnet restore C:\warmup\packagescache.csproj `
        --source https://api.nuget.org/v3/index.json `
        --verbosity quiet `
    && del /F /S /Q C:\warmup

# Workaround for https://github.com/Microsoft/DockerTools/issues/87. This instructs NuGet to use 4.5 behavior in which
# all errors when attempting to restore a project are ignored and treated as warnings instead. This allows the VS
# tooling to use -nowarn:MSB3202 to ignore issues with the .dcproj project
ENV RestoreUseSkipNonexistentTargets false
