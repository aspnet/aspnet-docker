[cmdletbinding(PositionalBinding = $true)]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    $directory,
    [Parameter(Mandatory = $true, Position = 1)]
    $framework
)

$ErrorActionPreference = 'Stop'

function exec($cmd) {
    Write-Host -foregroundcolor Magenta "$(hostname) > $cmd $args"
    & $cmd @args
    $code = $LastExitCode
    if ($code -ne 0) {
        Write-Error "Command exited with non-zero code: $code"
        exit $code
    }
}

Push-Location $directory
try {
    Write-Host "Testing framework-dependent deployment"
    if ($framework -eq 'netcoreapp1.0' -or $framework -eq 'netcoreapp1.1') {
        exec dotnet new web --framework $framework
    } else {
        exec dotnet new web --framework $framework --no-restore
    }

    # restore only from $HOME/.nuget/packages to ensure the cache has already been warmed up
    exec dotnet restore `
        --source ${env:USERPROFILE}/.nuget/packages `
        "/p:RuntimeIdentifiers=win7-x64"

    Write-Output "Testing self-contained deployment"
    exec dotnet publish `
        --configuration Release `
        --output publish/framework-dependent

    Write-Output "Testing self-contained deployment"
    exec dotnet publish `
        --configuration Release `
        --runtime win7-x64 `
        --output publish/self-contained
}
finally {
    Pop-Location
}
