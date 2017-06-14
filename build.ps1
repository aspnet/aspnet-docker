param(
    # Set to 'microsoft' on build servers
    [string]$RootImageName='test',
    # Set on build servers
    [switch]$Nightly
)

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

$suffix = if ($Nightly) { '-nightly' } else { '' }

# Main
gci $PSScriptRoot/*/nanoserver/*/Dockerfile | % {
    $type = $_.Directory.Name
    $version = $_.Directory.Parent.Parent.Name
    $tag = switch ($type) {
        'sdk' { "$RootImageName/aspnetcore-build${suffix}:${version}" }
        'kitchensink' { "$RootImageName/aspnetcore-build${suffix}:1.0-${version}" }
        'runtime' { "$RootImageName/aspnetcore${suffix}:${version}" }
        default { throw "Unrecognized image type in $_" }
    }
    exec docker build --pull $(split-path -parent $_) -t $tag
}
