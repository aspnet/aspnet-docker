param(
    [string] $Folder = '*'
)

$ErrorActionPreference = 'Stop'

function exec($cmd) {
    Write-Host -foregroundcolor Cyan ">>> $cmd $args"
    & $cmd @args
    if ($LastExitCode -ne 0) {
        throw 'Command exited with non-zero code'
    }
}

exec $PSScriptRoot\build.ps1 -Folder $Folder
exec $PSScriptRoot\test.ps1 -Folder $Folder
