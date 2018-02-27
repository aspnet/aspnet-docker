# escape=`

# installer image
FROM microsoft/powershell:nanoserver AS installer-env
SHELL ["pwsh.exe", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# retrieve git
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -UseBasicParsing -outfile git.zip https://github.com/git-for-windows/git/releases/download/v2.16.1.windows.1/MinGit-2.16.1-64-bit.zip; `
    Expand-Archive git.zip -DestinationPath git; `
    Remove-Item -Force git.zip

# build image
FROM microsoft/dotnet:2.0-sdk-nanoserver-1709 AS build-env

# install git
COPY --from=installer-env ["git", "C:\\Program Files\\git"]
USER ContainerAdministrator
RUN setx /M PATH "%PATH%;C:\Program Files\git\cmd"
USER ContainerUser

WORKDIR /code
# copy csproj and restore as distinct layers
COPY scripts/Updater/*.csproj ./
COPY scripts/Updater/NuGet.config ./
RUN dotnet restore
# copy everything else and build
COPY scripts/Updater/. ./
RUN dotnet publish -o pub --no-restore -c Release

# copy repo
WORKDIR /repo
COPY . ./

ENTRYPOINT ["dotnet", "/code/pub/Updater.dll"]
