#!/usr/bin/env powershell
#requires -version 5
param(
    # Set to 'microsoft' on build servers
    [string]$RootImageName = 'test',
    # Can be used to filter the build by the top-level folders in this repo '1.0', '2.0', etc
    [string]$Folder = '*'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Functions

function exec($cmd) {
    Write-Host -foregroundcolor Cyan ">>> $cmd $args"
    & $cmd @args
    if ($LastExitCode -ne 0) {
        write-error 'Command exited with non-zero code'
        exit 1
    }
}

$active_os = docker version -f "{{ .Server.Os }}"
$manifest = (Get-Content (Join-Path $PSScriptRoot manifest.json) | ConvertFrom-Json)
# Main
$manifest.repos | % {
    $repo = $_
    $repoName = $repo.name -replace 'microsoft/',"$RootImageName/"
    Write-Host -foregroundcolor magenta "Building ${repoName}"

    $repo.images | % {
        $_.platforms |
            ? { $_.os -eq "$active_os" } |
            ? { $Folder -eq '*' -or $_.dockerfile -like "$Folder*" } |
            % {
                $dockerfile = Join-Path $PSScriptRoot $_.dockerfile
                $tag_details = $_.tags | % { $_.PSobject.Properties } | select -first 1
                $full_tag_name = "${repoName}:$($tag_details.name)"
                exec docker build --pull $dockerfile --tag $full_tag_name
            }
    }
}
