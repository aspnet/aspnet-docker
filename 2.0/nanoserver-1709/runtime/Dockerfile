# escape=`

# Installer image
FROM microsoft/windowsservercore:1709 AS installer-env

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Retrieve the runtime store
ENV ASPNETCORE_RUNTIMESTORE_DOWNLOAD_URL https://dist.asp.net/runtimestore/2.0.0/win-x64/aspnetcore.runtimestore.zip

RUN Write-Host \"Downloading and extracting ${env:ASPNETCORE_RUNTIMESTORE_DOWNLOAD_URL}\"; `
    Invoke-WebRequest $env:ASPNETCORE_RUNTIMESTORE_DOWNLOAD_URL -OutFile cache.zip; `
    Expand-Archive cache.zip -DestinationPath RuntimeStore; `
    Remove-Item -Force cache.zip


# Runtime image
FROM microsoft/dotnet:2.0.0-runtime-nanoserver-1709

# Note: Runtime image's SHELL is the CMD shell (different than the installer image).

# Set up network
ENV ASPNETCORE_URLS http://+:80
ENV ASPNETCORE_PKG_VERSION 2.0.0

# Set up the runtime store
COPY --from=installer-env ["RuntimeStore", "C:\\Program Files\\dotnet"]
