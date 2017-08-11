#!/usr/bin/env powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    $BuildNumber,
    [switch]$NoTimestamp
)

$prefix = 'preview1'
$packageNumber = if ($NoTimestamp) {
    "2.1.0"
} else {
    "2.1.0-$prefix-$BuildNumber"
}

$rsVersion = if ($NoTimestamp) {
    ''
} else {
    "-$prefix-$BuildNumber"
}


Get-ChildItem -Recurse "$PSScriptRoot/../2.1/*/Dockerfile" | % {
    Write-Host "Updating $_"
    Set-Content $_ (Get-Content $_ `
    | % {
        if ($_ -like 'ENV ASPNETCORE_PKG_VERSION*') {

            "ENV ASPNETCORE_PKG_VERSION $packageNumber"
        } elseif ($_ -like 'ENV ASPNETCORE_RUNTIMESTORE_DOWNLOAD_URL*') {
            if ($_ -like '*.tar.gz'){
                $rid = 'linux'
                $ext = 'tar.gz'
            } else {
                $rid = 'winx64'
                $ext = 'zip'
            }
            "ENV ASPNETCORE_RUNTIMESTORE_DOWNLOAD_URL https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/store/2.1.0-${BuildNumber}/Build.RS.${rid}${rsVersion}.$ext"
        } else {
            $_
        }
     })
}
