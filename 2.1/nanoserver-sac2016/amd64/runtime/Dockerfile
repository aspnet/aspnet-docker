# escape=`
FROM microsoft/nanoserver:sac2016

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# set up network
ENV ASPNETCORE_URLS http://+:80

# Retrieve ASP.NET Core Runtime
ENV ASPNETCORE_VERSION 2.1.0-preview1-28243

RUN Invoke-WebRequest -OutFile aspnetcore.zip https://dotnetcli.blob.core.windows.net/dotnet/Runtime/$Env:ASPNETCORE_VERSION/aspnetcore-runtime-$Env:ASPNETCORE_VERSION-win-x64.zip; `
    Expand-Archive aspnetcore.zip -DestinationPath  $Env:ProgramFiles\dotnet; `
    Remove-Item -Force aspnetcore.zip
RUN setx /M PATH $($Env:PATH + ';' + $Env:ProgramFiles + '\dotnet')
