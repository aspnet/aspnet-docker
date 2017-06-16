param(
    # Set to 'microsoft' on build servers
    [string]$RootImageName='test',
    # Set to Docker host IP if running within a container
    [string]$HostIP='localhost',
    # Set if testing nightly images
    [switch]$Nightly=$true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Functions

function exec($cmd) {
    Write-Host -foregroundcolor Cyan "$(hostname) > $cmd $args"
    & $cmd @args
    if ($LastExitCode -ne 0) {
        fatal 'Command exited with non-zero code'
    }
}

function fatal {
    Write-Error "$args"
    exit 1
}

function Get-Ip($container, $platform) {
    if ($platform -eq "windows") {
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
            Invoke-WebRequest -UseBasicParsing $endpoint
            return 0
        }
        catch {
            Write-Host -f gray 'Still waiting'
            Start-Sleep -s 4
        }
    }
    fatal "Timed out waiting for response on $endpoint"
}

# Main
$suffix = if ($Nightly) { '-nightly' } else { '' }
$platform = docker version -f "{{ .Server.Os }}"
if ($platform -eq "windows") {
    $container_root = "C:\"
    $host_port = "80"
    $image_os = "nanoserver"
    $rid="win7-x64"
}
else {
    $container_root = "/"
    $host_port = "5000"
    $image_os = "jessie"
    $rid="debian.8-x64"
}

Get-ChildItem (Join-Paths $PSScriptRoot ("..", "*", $image_os, "sdk", "Dockerfile")) | % {

    $app_name = "app$(get-random)"
    $publish_path = "${container_root}publish"
    $version = $_.Directory.Parent.Parent.Name
    $sdk_tag = "$RootImageName/aspnetcore-build${suffix}:${version}"
    $runtime_tag = "$RootImageName/aspnetcore${suffix}:${version}"

    Write-Host "----- Building app with ${sdk_tag} -----"
    if ($version -eq '1.0' -or $version -eq '1.1') {
        $optional_new_params = ""
    } else {
        $optional_new_params = "--no-restore"
    }

    $app_build_tag = "$app_name-build"
    try {
        $framework ="netcoreapp${version}"
        exec {
            (Get-Content (Join-Path $PSScriptRoot -ChildPath "Dockerfile.test.$image_os")).
                Replace("{image}", $sdk_tag) `
            | docker build `
                --build-arg FRAMEWORK=$framework `
                --build-arg OPTIONAL_NEW_PARAMS=$optional_new_params `
                -t $app_build_tag `
                -
        }

        Write-Host "----- Publishing framework-dependent app with ${sdk_tag} -----"
        $app_volume_name = "$app_name-framework-dependent"
        try {
            exec docker run --rm `
                --name "publish-framework-dependent-$app_name" `
                -v ${app_volume_name}:${publish_path} `
                $app_build_tag `
                dotnet publish --configuration Release --output $publish_path

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

                $ip = Get-Ip $app_container_name $platform
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
                dotnet publish --configuration Release --runtime $rid --output $publish_path

            if ($platform -eq "linux" -and $version -eq "2.0") {
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
                    --entrypoint ./test `
                    --name $app_container_name `
                    -p ${host_port}:80 `
                    -v ${app_volume_name}:${publish_path} `
                    --workdir ${publish_path} `
                    $runtime_tag

                $ip = Get-Ip $app_container_name $platform
                WaitForSuccess "http://${ip}:${host_port}"
            }
            finally {
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
