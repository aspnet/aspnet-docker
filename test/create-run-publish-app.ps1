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
    if ($LastExitCode -ne 0) {
        fatal 'Command exited with non-zero code'
    }
}

Push-Location $directory
try {
    Write-Host "Testing framework-dependent deployment"
    exec dotnet new web --framework $framework

    # restore only from $HOME/.nuget/packages to ensure the cache has already been warmed up
    exec dotnet msbuild "/t:Restore;Publish" `
        "/p:RuntimeIdentifiers=win7-x64" `
        "/p:PublishDir=publish/framework-dependent" `
        "/p:RestoreSources=${env:USERPROFILE}/.nuget/packages"

    Write-Output "Testing self-contained deployment"
    exec dotnet publish -r win7-x64 -o publish/self-contained
}
finally {
    Pop-Location
}
