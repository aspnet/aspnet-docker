#!/usr/bin/env pwsh
#requires -version 5
#

<#
.SYNOPSIS
    Updates packagescache.csproj files
.PARAMETER PkgProjPath
    Path to a .csproj file from aspnet/Coherence-Final that has PackageReference items
    for the latest package cache settings
#>
param(
    [string]$PkgProjPath
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

function Get-ProjectProperty([string]$file, [string] $propertyName) {
    Write-Host "New versions:"
    [xml]$xml = Get-Content $file
    $prop = $xml.SelectSingleNode("/Project/PropertyGroup/$propertyName") | select -last 1
    return $prop.InnerText
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

$files = Get-ChildItem "**/packagescache.csproj" -Recurse
$tempFile = New-TemporaryFile

try {
    if ($PkgProjPath.StartsWith("http")) {
        $tempFile = New-TemporaryFile
        Invoke-WebRequest -Uri $PkgProjPath -OutFile $tempFile
        $PkgProjPath = $tempFile
    }

    $versions = Get-Versions $PkgProjPath
    $targetFramework = Get-ProjectProperty $PkgProjPath 'TargetFramework'

    Write-Host -ForegroundColor Yellow "Target framework = $targetFramework"

    $files | % {
        $source = LoadXml $_
        Write-Host "Upgrading $_"
        Update-PackageRefs $targetFramework $source $versions
        SaveXml $source $_
    }
}
finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile
    }
}
