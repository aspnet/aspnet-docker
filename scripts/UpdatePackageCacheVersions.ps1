#!/usr/bin/env pwsh
#requires -version 5
#

<#
.SYNOPSIS
    Updates packagescache.csproj files
.PARAMETER NetCoreApp10Versions
    Path to a file that contains a list of package references to update for netcoreapp1.0.
.PARAMETER NetCoreApp11Versions
    Path to a file that contains a list of package references to update for netcoreapp1.1.
#>
param(
    [string]$NetCoreApp10Versions,
    [string]$NetCoreApp11Versions
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 1.0

function LoadXml([string]$path) {
    $xml = New-Object xml
    $xml.PreserveWhitespace = $true
    $xml.Load($path)
    return $xml
}

function SaveXml($doc, [string]$path) {
    Write-Host -ForegroundColor Magenta "Wrote to $path"
    $settings = New-Object System.XML.XmlWriterSettings
    $settings.OmitXmlDeclaration = $true
    $settings.Encoding = New-Object System.Text.UTF8Encoding( $true )
    $writer = [System.XML.XMLTextWriter]::Create($path, $settings)
    $doc.Save($writer)
    $writer.Close()
}

function Get-Versions([string]$file) {
    Write-Host "New versions:"
    [xml]$xml = Get-Content $file
    $versions = [PSCustomObject] @{}
    foreach ($group in $xml.SelectNodes('//PackageReference')) {
        $pkgId = $group.Attributes['Include'].Value
        $version = $group.Attributes['Version'].Value
        $private = $group.Attributes['PrivateAssets'].Value
        if ($private -eq 'All') {
            continue
        }

        Add-Member -InputObject $versions -MemberType NoteProperty -Name $pkgId -Value $version
        Write-Host -f DarkGray "   $pkgId $version"
    }
    return $versions
}

function Update-PackageRefs([string]$tfm, [xml]$file, $versions) {
    foreach ($group in $file.SelectNodes('/Project/ItemGroup')) {
        $condition = $group.Attributes['Condition'].Value
        if (-not $condition -or ($condition -notlike "*'$tfm'*")) {
            continue
        }

        foreach ($pkg in $group.SelectNodes('PackageReference')) {
            $pkgId = $pkg.Attributes['Include'].Value
            $version = $pkg.Attributes['Version'].Value

            if ($pkgId -and -not (Get-Member -Name $pkgId -InputObject $versions)) {
                continue
            }

            $newVersion = $versions.$pkgId

            if ($newVersion -ne $version)  {
                Write-Host -f DarkGray "   ${pkgId}: $version => $newVersion"
                $pkg.Attributes['Version'].Value = $newVersion
            }
        }
    }
}

$files = Get-ChildItem "*/*/*/packagescache.csproj" -Recurse

if ($NetCoreApp10Versions) {
    $versions = Get-Versions $NetCoreApp10Versions

    $files | % {
        $source = LoadXml $_
        Write-Host "Upgrading $_"
        Update-PackageRefs 'netcoreapp1.0' $source $versions
        SaveXml $source $_
    }
}

if ($NetCoreApp11Versions) {
    $versions = Get-Versions $NetCoreApp11Versions

    $files | % {
        $source = LoadXml $_
        Write-Host "Upgrading $_"
        Update-PackageRefs 'netcoreapp1.1' $source $versions
        SaveXml $source $_
    }
}
