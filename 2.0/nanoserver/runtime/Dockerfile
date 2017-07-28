# escape=`
FROM microsoft/dotnet:2.0.0-runtime-nanoserver-10.0.14393.1480

# set up network
ENV ASPNETCORE_URLS http://+:80
ENV ASPNETCORE_PKG_VERSION 2.0.0
ENV ASPNETCORE_RUNTIMESTORE_DOWNLOAD_URL https://dist.asp.net/runtimestore/2.0.0/win-x64/aspnetcore.runtimestore.zip

# set up the runtime store
RUN Write-Host \"Downloading and extracting ${env:ASPNETCORE_RUNTIMESTORE_DOWNLOAD_URL}\"; `
    Invoke-WebRequest $env:ASPNETCORE_RUNTIMESTORE_DOWNLOAD_URL -OutFile cache.zip; `
    $env:DOTNET_HOME = $(Split-Path -Parent (Get-Command dotnet.exe).Source); `
    Expand-Archive cache.zip -DestinationPath $env:DOTNET_HOME; `
    Remove-Item -Force cache.zip
