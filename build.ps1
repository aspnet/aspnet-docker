param(
    # Set to 'microsoft' on build servers
    [string]$RootImageName='test'
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

# Main
gci $PSScriptRoot/*/nanoserver/*/Dockerfile | % {
    $type = $_.Directory.Name
    $version = $_.Directory.Parent.Parent.Name
    $tag = switch ($type) {
        'sdk' { "$RootImageName/aspnetcore-build:${version}-nanoserver" }
        'kitchensink' { "$RootImageName/aspnetcore-build:1.0-${version}-nanoserver" }
        'runtime' { "$RootImageName/aspnetcore:${version}-nanoserver" }
        default { throw "Unrecognized image type in $_" }
    }
    exec docker build $(split-path -parent $_) -t $tag
}
