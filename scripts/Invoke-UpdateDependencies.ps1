[cmdletbinding()]
param(
    [switch]$CleanupDocker,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$UpdateDependenciesParams
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$imageName = "update-dependencies"

try {
    $repoRoot = Split-Path -Path "$PSScriptRoot" -Parent

    & docker build -t $imageName -f $PSScriptRoot\Updater\Dockerfile --pull $repoRoot
    if ($LastExitCode -ne 0) {
        throw "Failed to build the update dependencies tool"
    }

    & docker run --rm --user ContainerAdministrator $imageName @UpdateDependenciesParams
    if ($LastExitCode -ne 0) {
        throw "Failed to update dependencies"
    }
}
finally {
    if ($CleanupDocker) {
        & docker rmi -f $imageName
        & docker system prune -f
    }
}
