# escape=`
FROM microsoft/dotnet:2.0.0-preview2-runtime-nanoserver-10.0.14393.1480

# set up network
ENV ASPNETCORE_URLS http://+:80

# set up the runtime store
RUN $downloadUrl = 'https://distaspnet.blob.core.windows.net/runtimestore/2.0.0-preview2-final/win-x64/aspnetcore.runtimestore.zip'; `
    Write-Host \"Downloading and extracting $downloadUrl\"; `
    Invoke-WebRequest $downloadUrl -OutFile cache.zip; `
    $env:DOTNET_HOME = $(Split-Path -Parent (Get-Command dotnet.exe).Source); `
    Expand-Archive cache.zip -DestinationPath $env:DOTNET_HOME; `
    Remove-Item -Force cache.zip
