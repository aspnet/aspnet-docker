# escape=`
FROM microsoft/dotnet-nightly:2.0.0-preview2-runtime-nanoserver-10.0.14393.1358

# set up network
ENV ASPNETCORE_URLS http://+:80

# set up the runtime store
RUN $downloadUrl = 'https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/store/2.0.0-preview2-215/Build.RS.winx64.zip'; `
    Write-Host \"Downloading and extracting $downloadUrl\"; `
    Invoke-WebRequest $downloadUrl -OutFile cache.zip; `
    $env:DOTNET_HOME = $(Split-Path -Parent (Get-Command dotnet.exe).Source); `
    Expand-Archive cache.zip -DestinationPath $env:DOTNET_HOME; `
    Remove-Item -Force cache.zip
