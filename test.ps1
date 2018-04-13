#!/usr/bin/env pwsh
#requires -version 5
param(
    # Set to 'microsoft' on build servers
    [string]$RootImageName = 'test',
    # Set to Docker host IP if running within a container
    [string]$HostIP = 'localhost',
    [string]$Folder = '*'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "`$Folder = $Folder"

# Functions

function exec($cmd) {
    Write-Host -ForegroundColor Cyan ">>> $cmd $args"
    $originalErrorPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $cmd @args
    $exitCode = $LastExitCode
    $ErrorActionPreference = $originalErrorPreference
    if ($exitCode -ne 0) {
        Write-Host -ForegroundColor Red "<<< [$exitCode] $cmd $args"
        fatal 'Command exited with non-zero code'
    }
}

function fatal {
    Write-Error "$args"
    exit 1
}

function Get-Ip($container, $active_os) {
    if ($active_os -eq "windows") {
        docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container
    }
    else {
        $HostIP
    }
}

function Get-TestRid($tagName) {
    if ($active_os -eq "windows") {
        return "win7-x64"
    }
    else {
        if ($tagName -like '*bionic*') {
            return "ubuntu.18.04-x64"
        }
        else {
            return "debian.8-x64"
        }
    }
}

function Join-Paths($path, $childPaths) {
    $childPaths | % { $path = Join-Path $path $_ }
    return $path
}

function WaitForSuccess($endpoint) {
    # wait 1 minutes max
    for ($i = 0; $i -lt 15; $i++) {
        Write-Host -f gray "Waiting for $endpoint"
        try {
            Invoke-WebRequest -UseBasicParsing $endpoint | Write-Host
            return 0
        }
        catch {
            Write-Host -f gray 'Still waiting'
            Start-Sleep -s 4
        }
    }
    fatal "Timed out waiting for response on $endpoint"
}

function test_image ($version, $sdk_tag, $runtime_tag) {
    $framework = "netcoreapp${version}"
    $build_context = "$PSScriptRoot/test"
    $rid = Get-TestRid $sdk_tag
    $no_restore_flag = switch ($version) {
        # not supported in 1.x SDKs
        '1.0' { '' }
        '1.1' { '' }
        default { '--no-restore' }
    }

    write-host -foregroundcolor magenta "----- Testing: TFM: $framework, RID: $rid, SDK: $sdk_tag, Runtime: $runtime_tag -----"

    $scenario = @(@{
            name      = 'portable'
            test_file = $portable_test_file
        },
        @{
            name      = 'selfcontained'
            test_file = $self_contained_test_file
        })

    $scenario | % {
        Write-Host "----- Running test $($_.name) ${sdk_tag} and ${runtime_tag} -----"
        $app_name = "app$(get-random)"
        $app_tagname = "$app_name-$($_.name)"

        try {
            exec docker build `
                --build-arg BUILD_IMG=$sdk_tag `
                --build-arg RUNTIME_IMG=$runtime_tag `
                --build-arg FRAMEWORK=$framework `
                --build-arg RUNTIME_IDENTIFIER=$rid `
                --build-arg NO_RESTORE_FLAG=$no_restore_flag `
                -t $app_tagname `
                -f $_.test_file `
                $build_context

            exec docker run --rm -d -t `
                --name $app_name `
                -p 5000:80 `
                $app_tagname

            $ip = Get-Ip $app_name $active_os
            WaitForSuccess "http://${ip}:${test_port}"
        }
        finally {
            # Test cleanup
            & docker logs $app_name
            & docker kill $app_name
            & docker rmi $app_tagname
        }
    }
}

# Main

$active_os = docker version -f "{{ .Server.Os }}"

if ($active_os -eq "windows") {
    # We call directly into the container IP address on Windows. Loopback port mapping isn't yet supported
    $test_port = 80
    $portable_test_file = "Dockerfile.test.portable.nanoserver"
    $self_contained_test_file = "Dockerfile.test.selfcontained.nanoserver"
}
else {
    $test_port = 5000
    $portable_test_file = "Dockerfile.test.portable.linux"
    $self_contained_test_file = "Dockerfile.test.selfcontained.linux"
}

$manifest = Get-Content (Join-Path $PSScriptRoot manifest.json) | ConvertFrom-Json

# Main

push-location "$PSScriptRoot/test"

try {
    $testCount = 0
    $manifest.repos | % {
        $repo = $_
        $repoName = $repo.name -replace 'microsoft/', "$RootImageName/"

        $repo.images | % {
            $_.platforms |
                ? { $_.os -eq "$active_os" } |
                ? { $Folder -eq '*' -or $_.dockerfile -like "$Folder" } |
                ? { $_.dockerfile -like '*/sdk' } |
                % {
                $testCount += 1
                $version = $_.dockerfile.Substring(0, 3)
                $sdk_tag_info = $_.tags | % { $_.PSobject.Properties } | select -first 1
                $sdk_tag = "${repoName}:$($sdk_tag_info.name)"
                $runtime_tag = switch ($version) {
                    # map the 1.1.X-1.1.Y sdk tags to the runtime tag name
                    "1.1" { $sdk_tag -replace '-1.1.\d+', '' }
                    # map the 2.0.X-2.1.Y sdk tags to the runtime tag name
                    "2.0" { $sdk_tag -replace '-2.1.\d+', '' }
                    Default { $sdk_tag }
                }
                $runtime_tag = $runtime_tag -replace '-build', ''

                test_image $version $sdk_tag $runtime_tag

                if ($version -eq '1.1') {
                    # Users should be able to compile with microsoft/aspnetcore-build:1.1 and run with microsoft/aspnetcore:1.0
                    $one_oh_runtime = $manifest.repos |
                        ? { $_.name -notlike '*-build*' } |
                        % { $_.images } |
                        % { $_.platforms | ? { $_.os -eq "$active_os" } | ? { $_.dockerfile -like "1.0/*/runtime" } } | select -first 1
                    $one_oh_runtime | out-host
                    $one_oh_version = $one_oh_runtime.tags | % { $_.PSobject.Properties } | select -first 1
                    $one_oh_runtime_tag = "${repoName}:$($one_oh_version.name)" -replace '-build', ''
                    test_image '1.0' $sdk_tag $one_oh_runtime_tag
                }
            }
        }
    }

    if ($testCount -eq 0) {
        throw 'No tests were run'
    }

}
finally {
    Pop-Location
}
