#!/usr/bin/env powershell
#requires -version 4
param(
    # Set to 'microsoft' on build servers
    [string]$RootImageName = 'test',
    # Set on build servers
    [switch]$Nightly = $true,
    # Can be used to filter the build by the top-level folders in this repo '1.0', '2.0', etc
    [string]$Folder = '*'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Functions

function exec($cmd) {
    Write-Host -foregroundcolor Cyan "$(hostname) > $cmd $args"
    & $cmd @args
    if ($LastExitCode -ne 0) {
        write-error 'Command exited with non-zero code'
        exit 1
    }
}

$platform = docker version -f "{{ .Server.Os }}"
$suffix = if ($Nightly) { '-nightly' } else { '' }
$dockerfiles = `
    if ($platform -eq 'windows') { gci $PSScriptRoot/$Folder/nanoserver/*/Dockerfile }
    else { gci $PSScriptRoot/$Folder/stretch/*/Dockerfile,$PSScriptRoot/$Folder/jessie/*/Dockerfile -ErrorAction Ignore }

# Main
$dockerfiles | % {
    $type = $_.Directory.Name
    $version = $_.Directory.Parent.Parent.Name
    $image_os = $_.Directory.Parent.Name
    $tag = switch ($type) {
        'sdk' { "$RootImageName/aspnetcore-build${suffix}:${version}-${image_os}" }
        'kitchensink' { "$RootImageName/aspnetcore-build${suffix}:1.0-${version}-${image_os}" }
        'runtime' { "$RootImageName/aspnetcore${suffix}:${version}-${image_os}" }
        default { throw "Unrecognized image type in $_" }
    }
    write-host "Building $_"
    exec docker build --pull $(split-path -parent $_) -t $tag
}
