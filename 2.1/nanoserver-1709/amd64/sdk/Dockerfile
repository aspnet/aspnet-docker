# escape=`

# Installer image
FROM microsoft/windowsservercore:1709 AS installer-env

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Retrieve node and git
## https://nodejs.org/dist/v8.9.4/
ENV NODE_VERSION 8.9.4
ENV NODE_DOWNLOAD_SHA 48946e99ac4484e071df25741d2300f3a656f476c5ff3f8116a4746c07ebe3b7

RUN Invoke-WebRequest -UseBasicParsing https://nodejs.org/dist/v${env:NODE_VERSION}/node-v${env:NODE_VERSION}-win-x64.zip -outfile node.zip; `
    if ((Get-FileHash node.zip -Algorithm sha256).Hash -ne $env:NODE_DOWNLOAD_SHA) { `
        Write-Host 'NODEJS CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    `
    Expand-Archive node.zip -DestinationPath nodejs-tmp; `
    Move-Item nodejs-tmp/node-v${env:NODE_VERSION}-win-x64 nodejs; `
    Remove-Item -Force node.zip; `
    Remove-Item -Force nodejs-tmp

# Build image
FROM microsoft/dotnet-nightly:2.1.300-preview1-sdk-nanoserver-1709

# Set up environment
ENV ASPNETCORE_URLS http://+:80

COPY --from=installer-env ["nodejs", "C:\\Program Files\\nodejs"]
USER ContainerAdministrator
RUN setx PATH "%PATH%;C:\Program Files\nodejs"
USER ContainerUser

# Note: Build image's SHELL is the CMD shell (different than the installer image).
# Ensure packages required for standalone apps are pre-fetched
RUN mkdir %TEMP%\warmup; `
    cd %TEMP%\warmup; `
    dotnet new web --no-restore; `
    dotnet restore -p:RuntimeIdentifier=debian.8-x64 `
        --source https://dotnet.myget.org/F/dotnet-core/api/v3/index.json `
        --source https://api.nuget.org/v3/index.json; `
    cd ..; del /F /S /Q %TEMP%\warmup
