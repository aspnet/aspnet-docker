#!/usr/bin/env powershell
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

function Join-Paths($path, $childPaths) {
    $childPaths | %{ $path = Join-Path $path $_ }
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
    $no_restore_flag = switch ($version) {
        # not supported in 1.x SDKs
        '1.0' { '' }
        '1.1' { '' }
        default { '--no-restore' }
    }

    write-host -foregroundcolor magenta "----- Testing: TFM: $framework, SDK: $sdk_tag, Runtime: $runtime_tag -----"

    $app_name = "app$(get-random)"
    $publish_path = "${container_root}publish"

    Write-Host "----- Building app with ${sdk_tag} -----"

    $app_build_tag = "$app_name-build"
    try {
        Write-Host "----- Building $docker_test_file as $app_build_tag from ${sdk_tag} -----"

        (Get-Content (Join-Path $PSScriptRoot -ChildPath $docker_test_file)).
                Replace("{image}", $sdk_tag) `
        | docker build `
            --build-arg FRAMEWORK=$framework `
            --build-arg BUILD_ARGS=$no_restore_flag `
            -t $app_build_tag `
            -

        Write-Host "----- Publishing framework-dependent app with ${sdk_tag} -----"
        $app_volume_name = "$app_name-framework-dependent"
        try {
            exec docker run --rm `
                --name "publish-framework-dependent-$app_name" `
                -v ${app_volume_name}:${publish_path} `
                $app_build_tag `
                dotnet publish --configuration Release --output $publish_path $no_restore_flag

            Write-Host "----- Running framework-dependent app with ${runtime_tag} -----"
            $app_container_name = "runtime-framework-dependent-${app_name}"
            try {
                exec docker run -d -t `
                    --entrypoint dotnet `
                    --name $app_container_name `
                    -p ${host_port}:80 `
                    -v ${app_volume_name}:${publish_path} `
                    --workdir ${publish_path} `
                    $runtime_tag `
                    test.dll

                $ip = Get-Ip $app_container_name $active_os
                WaitForSuccess "http://${ip}:${host_port}"
            }
            finally {
                exec docker logs $app_container_name
                exec docker rm -f $app_container_name
            }
        }
        finally {
            exec docker volume rm $app_volume_name
        }

        Write-Host "----- Publishing self-contained app with ${sdk_tag} -----"
        $app_volume_name = "$app_name-self-contained"
        try {
            exec docker run --rm `
                --name "publish-self-contained-$app_name" `
                -v ${app_volume_name}:${publish_path} `
                $app_build_tag `
                dotnet publish --configuration Release --runtime $rid --output $publish_path $no_restore_flag

            if ($active_os -eq "linux" -and $version -eq "2.0") {
                # Temporary workaround https://github.com/dotnet/corefx/blob/master/Documentation/project-docs/dogfooding.md#option-2-self-contained
                exec docker run --rm `
                    -v ${app_volume_name}:${publish_path} `
                    $runtime_tag `
                    chmod u+x ${publish_path}/test
            }

            Write-Host "----- Running self-contained app with ${runtime_tag} -----"
            $app_container_name = "runtime-self-contained-${app_name}"
            try {
                exec docker run -d -t `
                    --entrypoint $self_contained_entrypoint `
                    --name $app_container_name `
                    -p ${host_port}:80 `
                    -v ${app_volume_name}:${publish_path} `
                    --workdir ${publish_path} `
                    $runtime_tag

                $ip = Get-Ip $app_container_name $active_os
                WaitForSuccess "http://${ip}:${host_port}"
            }
            finally {
                exec docker logs $app_container_name
                exec docker rm -f $app_container_name
            }
        }
        finally {
            exec docker volume rm $app_volume_name
        }
    }
    finally {
        exec docker rmi -f $app_build_tag
    }
}

# Main

$active_os = docker version -f "{{ .Server.Os }}"

if ($active_os -eq "windows") {
    $container_root = "C:\"
    $host_port = "80"
    $rid="win7-x64"
    $docker_test_file = "Dockerfile.test.nanoserver"
    $self_contained_entrypoint = "test.exe"
}
else {
    $container_root = "/"
    $host_port = "5000"
    $rid = "debian.8-x64"
    $docker_test_file = "Dockerfile.test.linux"
    $self_contained_entrypoint = "./test"
}

$manifest = Get-Content (Join-Paths $PSScriptRoot ('..', 'manifest.json')) | ConvertFrom-Json

# Main

push-location $PSScriptRoot

try
{
    $testCount = 0
    $manifest.repos | % {
        $repo = $_
        $repoName = $repo.name -replace 'microsoft/',"$RootImageName/"

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
                        # map the 1.1.5-1.1.6 sdk tags to the runtime tag name
                        "1.1" { $sdk_tag -replace '-1.1.7','' }
                        # map the 2.0.4-2.1.3 sdk tags to the runtime tag name
                        "2.0" { $sdk_tag -replace '-2.1.4','' }
                        # map the 2.1.300 sdk tags to the runtime tag name
                        "2.1" { $sdk_tag -replace '2.1.300','2.1.0' }
                        Default { $sdk_tag }
                    }
                    $runtime_tag = $runtime_tag -replace '-build',''

                    test_image $version $sdk_tag $runtime_tag

                    if ($version -eq '1.1') {
                        # Users should be able to compile with microsoft/aspnetcore-build:1.1 and run with microsoft/aspnetcore:1.0
                        $one_oh_runtime = $manifest.repos |
                            ? { $_.name -notlike '*-build*' } |
                            % { $_.images } |
                            % { $_.platforms | ? { $_.os -eq "$active_os" } | ? { $_.dockerfile -like "1.0/*/runtime" } } | select -first 1
                        $one_oh_runtime | out-host
                        $one_oh_version = $one_oh_runtime.tags | % { $_.PSobject.Properties } | select -first 1
                        $one_oh_runtime_tag = "${repoName}:$($one_oh_version.name)" -replace '-build',''
                        test_image '1.0' $sdk_tag $one_oh_runtime_tag
                    }
                }
        }
    }

    # TODO find a way to test the 1.1 sdk with the 1.0 runtime image
    if (($testCount -eq 0) -and ($Folder -ne '1.0/*')) {
        throw 'No tests were run'
    }
}
finally {
    Pop-Location
}
