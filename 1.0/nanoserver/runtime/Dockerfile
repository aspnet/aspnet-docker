# escape=`
FROM microsoft/dotnet:1.0.5-runtime-nanoserver-10.0.14393.1715

# set up network
ENV ASPNETCORE_URLS http://+:80

# set env var for packages cache
ENV DOTNET_HOSTING_OPTIMIZATION_CACHE C:/packagecache

# set up package caches
RUN @('1.0.0', '1.0.1', '1.0.3', '1.0.4', '1.0.5') | % { `
        $downloadUrl = \"https://dist.asp.net/packagecache/${_}/win7-x64/aspnetcore.cache.zip\"; `
        $fileName = \"cache.${_}.zip\"; `
        Write-Host \"Downloading and extracting $downloadUrl\"; `
        Invoke-WebRequest $downloadUrl -OutFile $fileName; `
        Expand-Archive $fileName -DestinationPath ${env:DOTNET_HOSTING_OPTIMIZATION_CACHE}; `
        Remove-Item -Force $fileName `
    }
