# escape=`

# Installer image
FROM microsoft/windowsservercore:1709 AS installer-env

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Retrieve node and git
## https://nodejs.org/dist/v8.9.4/
ENV NODE_VERSION 8.9.4
ENV NODE_DOWNLOAD_SHA 48946e99ac4484e071df25741d2300f3a656f476c5ff3f8116a4746c07ebe3b7

RUN Invoke-WebRequest -UseBasicParsing https://nodejs.org/dist/v${env:NODE_VERSION}/node-v${env:NODE_VERSION}-win-x64.zip -outfile node.zip; `
    if ((Get-FileHash node.zip -Algorithm sha256).Hash -ne $env:NODE_DOWNLOAD_SHA) { `
        Write-Host 'NODEJS CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    `
    Expand-Archive node.zip -DestinationPath nodejs-tmp; `
    Move-Item nodejs-tmp/node-v${env:NODE_VERSION}-win-x64 nodejs; `
    Remove-Item -Force node.zip; `
    Remove-Item -Force nodejs-tmp

## https://github.com/git-for-windows/git/releases
ENV GIT_VERSION 2.16.1
ENV GIT_DOWNLOAD_SHA 14fde7abfa14f505605517b00c8b1bf09eec78e3653516f30dc43084d8df7ede

RUN Invoke-WebRequest -UseBasicParsing https://github.com/git-for-windows/git/releases/download/v${env:GIT_VERSION}.windows.1/MinGit-${env:GIT_VERSION}-64-bit.zip -outfile git.zip; `
    if ((Get-FileHash git.zip -Algorithm sha256).Hash -ne $env:GIT_DOWNLOAD_SHA) { `
        Write-Host 'GIT CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    `
    Expand-Archive git.zip -DestinationPath git; `
    Remove-Item -Force git.zip;


# Build image
FROM microsoft/dotnet-nightly:2.1.300-preview1-sdk-nanoserver-1709

# Note: Build image's SHELL is the CMD shell (different than the installer image).

# Set up environment
ENV ASPNETCORE_URLS http://+:80

# Install node, bower, and git
COPY --from=installer-env ["nodejs", "C:\\Program Files\\nodejs"]
COPY --from=installer-env ["git", "C:\\Program Files\\git"]
USER ContainerAdministrator
RUN setx PATH "%PATH%;C:\Program Files\nodejs;C:\Program Files\git\cmd"
USER ContainerUser
