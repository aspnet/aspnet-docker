# escape=`
FROM microsoft/dotnet-nightly:2.0.0-preview3-runtime-nanoserver-10.0.14393.1480

# set up network
ENV ASPNETCORE_URLS http://+:80

# set up the runtime store
RUN $downloadUrl = 'https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/store/dev-277/Build.RS.winx64-rtm-26182.zip'; `
    Write-Host \"Downloading and extracting $downloadUrl\"; `
    Invoke-WebRequest $downloadUrl -OutFile cache.zip; `
    $env:DOTNET_HOME = $(Split-Path -Parent (Get-Command dotnet.exe).Source); `
    Expand-Archive cache.zip -DestinationPath $env:DOTNET_HOME; `
    Remove-Item -Force cache.zip
