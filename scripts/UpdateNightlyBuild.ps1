#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    $AspNetCoreVersion
)

Get-ChildItem -Recurse "$PSScriptRoot/../2.1/*/Dockerfile" | % {
    Write-Host "Updating $_"
    Set-Content $_ (Get-Content $_ `
            | % {
            if ($_ -like 'ENV ASPNETCORE_VERSION *') {
                "ENV ASPNETCORE_VERSION $AspNetCoreVersion"
            }
            else {
                $_
            }
        })
}
