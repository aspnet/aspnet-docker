# escape=`
FROM microsoft/dotnet:2.0.0-preview1-runtime-nanoserver-10.0.14393.1358

# set up network
ENV ASPNETCORE_URLS http://+:80

# set up the runtime store
ENV ASPNETCORE_RUNTIME_STORE_VERSION 2.0.0-preview1
RUN $downloadUrl = \"https://distaspnet.blob.core.windows.net/packagecache/${env:ASPNETCORE_RUNTIME_STORE_VERSION}/win-x64/aspnetcore.runtimestore.zip\"; `
    Write-Host \"Downloading and extracting $downloadUrl\"; `
    Invoke-WebRequest $downloadUrl -OutFile cache.zip; `
    $env:DOTNET_HOME = $(Split-Path -Parent (Get-Command dotnet.exe).Source); `
    Expand-Archive cache.zip -DestinationPath $env:DOTNET_HOME; `
    Remove-Item -Force cache.zip
