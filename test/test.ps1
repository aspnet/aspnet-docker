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
        fatal 'Command exited with non-zero code'
    }
}

function fatal {
    Write-Error "$args"
    exit 1
}

function normalize-slashes($str) {
    $str -replace '\\', '/'
}

function get-ip($container) {
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container
}

function WaitForSuccess($endpoint) {
    # wait 1 minutes max
    for ($i = 0; $i -lt 15; $i++) {
        write-host -f gray "Waiting for $endpoint"
        try {
            iwr -UseBasicParsing $endpoint
            return 0
        }
        catch {
            write-host -f gray 'Still waiting'
            sleep -Seconds 4
        }
    }
    fatal "Timed out waiting for response on $endpoint"
}

# Main
$repo_root = normalize-slashes "$PSScriptRoot/.."

gci $PSScriptRoot/../*/nanoserver/sdk/Dockerfile | % {

    $app_name = "app$(get-random)"
    $app_dir = "${repo_root}/.test-assets/${app_name}"
    mkdir $app_dir -ErrorAction Ignore | Out-Null

    echo "---- Generating application directory ${app_dir} ---- "

    $version = $_.Directory.Parent.Parent.Name
    $framework = "netcoreapp${version}"
    $sdk_tag = "$RootImageName/aspnetcore-build:${version}"
    $runtime_tag = "$RootImageName/aspnetcore:${version}"

    echo "---- Testing ${sdk_tag} and ${runtime_tag} ----"
    exec docker run -t `
        -v "${app_dir}:C:/${app_name}" `
        -v "${repo_root}/test:C:/test" `
        --name "build-test-${app_name}" `
        --entrypoint powershell `
        $sdk_tag `
        -Command "C:/test/create-run-publish-app.ps1 C:/$app_name $framework"

    echo "----- Testing ${runtime_tag} with ${sdk_tag} app -----"
    try {
        exec docker run -d -t `
            -v "${app_dir}:C:/${app_name}" `
            --workdir "C:/${app_name}" `
            --name "runtime-test-${app_name}" `
            -p 80:80 `
            --entrypoint dotnet `
            $runtime_tag `
            "C:/${app_name}/publish/framework-dependent/${app_name}.dll"

        $ip = get-ip "runtime-test-${app_name}"
        WaitForSuccess "http://${ip}:80"
    }
    finally {
        exec docker rm -f "runtime-test-${app_name}"
    }

    echo "----- Testing ${runtime_tag} with standalone ${sdk_tag} app -----"
    try {
        exec docker run -d -t `
            -v "${app_dir}:C:/${app_name}" `
            --workdir "C:/${app_name}" `
            --name "runtime-standalone-test-${app_name}" `
            -p 80:80 `
            --entrypoint "C:/${app_name}/publish/self-contained/${app_name}" `
            $runtime_tag

        $ip = get-ip "runtime-standalone-test-${app_name}"
        WaitForSuccess "http://${ip}:80"
    }
    finally {
        exec docker rm -f "runtime-standalone-test-${app_name}"
    }
}
