# escape=`
FROM microsoft/dotnet:2.0.4-runtime-nanoserver-sac2016

# set up network
ENV ASPNETCORE_URLS http://+:80
ENV ASPNETCORE_PKG_VERSION 2.0.3

# set up the runtime store
RUN $env:DOTNET_HOME = $(Split-Path -Parent (Get-Command dotnet.exe).Source); `
    @('2.0.0', '2.0.3') | % { `
        $downloadUrl = \"https://dist.asp.net/runtimestore/${_}/win-x64/aspnetcore.runtimestore.zip\"; `
        Write-Host \"Downloading and extracting $downloadUrl\"; `
        Invoke-WebRequest $downloadUrl -OutFile cache.zip; `
        Expand-Archive cache.zip -DestinationPath $env:DOTNET_HOME; `
        Remove-Item -Force cache.zip; `
    }
