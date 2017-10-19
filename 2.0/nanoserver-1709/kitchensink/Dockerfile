# escape=`

# Installer image
FROM microsoft/windowsservercore:1709 AS installer-env

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Retrieve node and git
ENV NODE_VERSION 6.11.3

RUN Invoke-WebRequest -UseBasicParsing https://nodejs.org/dist/v${env:NODE_VERSION}/node-v${env:NODE_VERSION}-win-x64.zip -outfile node.zip; `
    Expand-Archive node.zip -DestinationPath nodejs-tmp; `
    Move-Item nodejs-tmp/node-v${env:NODE_VERSION}-win-x64 nodejs; `
    Remove-Item -Force node.zip; `
    Remove-Item -Force nodejs-tmp; `
    Invoke-WebRequest -UseBasicParsing https://github.com/git-for-windows/git/releases/download/v2.14.1.windows.1/MinGit-2.14.1-64-bit.zip -outfile git.zip; `
    Expand-Archive git.zip -DestinationPath git; `
    Remove-Item -Force git.zip

# Retrieve additional runtimes
RUN ('https://dotnetcli.blob.core.windows.net/dotnet/preview/Binaries/1.0.7/dotnet-win-x64.1.0.7.zip', `
     'https://dotnetcli.blob.core.windows.net/dotnet/release/1.1.0/Binaries/1.1.4/dotnet-win-x64.1.1.4.zip' ) `
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


# Build image
FROM microsoft/dotnet:2.0.0-sdk-2.0.2-nanoserver-1709

# Set up environment
ENV ASPNETCORE_URLS http://+:80
ENV ASPNETCORE_PKG_VERSION 2.0.0

# Install node, bower, and git
COPY --from=installer-env ["nodejs", "C:\\Program Files\\nodejs"]
RUN ""C:\Program Files\nodejs\npm"" install -g gulp bower
COPY --from=installer-env ["git", "C:\\Program Files\\git"]
RUN setx PATH "%PATH%;C:\Program Files\nodejs;C:\Program Files\git\cmd"

# Add additional runtimes
COPY --from=installer-env ["dotnet\\host", "C:\\Program Files\\dotnet\\host"]
COPY --from=installer-env ["dotnet\\shared", "C:\\Program Files\\dotnet\\shared"]

# Add Docker SDK
COPY --from=installer-env ["sdks", "C:\\Program Files\\dotnet\\sdk\\2.0.2\\Sdks"]

# Warmup up NuGet package cache
RUN mkdir C:\warmup
COPY packagescache.csproj C:\warmup\packagescache.csproj
RUN dotnet restore C:\warmup\packagescache.csproj `
        --source https://api.nuget.org/v3/index.json `
        --verbosity quiet `
    && del /F /S /Q C:\warmup
