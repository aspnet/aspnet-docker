# escape=`

# Installer image
FROM microsoft/windowsservercore:1709 AS installer-env

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Retrieve the runtime store
RUN  @('2.0.0', '2.0.3') | % { `
        $downloadUrl = \"https://dist.asp.net/runtimestore/${_}/win-x64/aspnetcore.runtimestore.zip\"; `
        Write-Host \"Downloading and extracting $downloadUrl\"; `
        Invoke-WebRequest $downloadUrl -OutFile cache.zip; `
        Expand-Archive cache.zip -DestinationPath RuntimeStore; `
        Remove-Item -Force cache.zip; `
    }

# Runtime image
FROM microsoft/dotnet:2.0.4-runtime-nanoserver-1709

# Note: Runtime image's SHELL is the CMD shell (different than the installer image).

# Set up network
ENV ASPNETCORE_URLS http://+:80
ENV ASPNETCORE_PKG_VERSION 2.0.3

# Set up the runtime store
COPY --from=installer-env ["RuntimeStore", "C:\\Program Files\\dotnet"]
