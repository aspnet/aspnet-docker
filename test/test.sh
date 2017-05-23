#!/usr/bin/env bash
set -e 	# Exit immediately upon failure
set -o pipefail  # Carry failures over pipes

# colors
RED='\033[0;31m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
RESET='\033[0m'

function __exec {
    local cmd=$1
    shift
    echo -e "${CYAN}$(hostname) > $cmd $@${RESET}"
    $cmd $@
}

root_image_name=${1:-test}
repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

function WaitForSuccess {
    # wait 1 minutes max
    for i in $(seq 15); do
        echo -e "${GRAY}Waiting for $1${RESET}"
        curl --silent --output /dev/null $1 && return 0
        sleep 4
    done
    echo -e "${RED}Timed out waiting for response on $1${RESET}"
    return 1
}

pushd "${repo_root}" > /dev/null

# Loop through each sdk Dockerfile in the repo and test the sdk and runtime images.
for version in $( find . -path './.*' -prune -o -path '*/jessie/sdk/Dockerfile' -print0 | dirname $(dirname $(xargs -0 -n1 dirname)) | sed -e 's/aspnet-docker\///' -e 's/.\///' ); do

    echo "---- Generating application directory ${app_dir} ---- "
    app_name="app$(date +%s)"
    app_dir="${repo_root}/.test-assets/${app_name}"
    mkdir -p "${app_dir}"

    sdk_tag="$root_image_name/aspnetcore-build:${version}"
    runtime_tag="$root_image_name/aspnetcore:${version}"
    framework="netcoreapp${version}"

    echo "---- Testing ${sdk_tag} and ${runtime_tag} ----"
    __exec docker run -t -v "${app_dir}:/${app_name}" -v "${repo_root}/test:/test" --name "build-test-${app_name}" --entrypoint /test/create-run-publish-app.sh "${sdk_tag}" "${app_name}" "${framework}"

    echo "----- Testing ${runtime_tag} with ${sdk_tag} app -----"
    container_name="runtime-test-${app_name}"
    __exec docker run -d -t -v "${app_dir}:/${app_name}" --workdir /${app_name} --name $container_name -p 5000:80 --entrypoint dotnet "${runtime_tag}" "/${app_name}/publish/framework-dependent/${app_name}.dll"
    docker logs -f $container_name &
    WaitForSuccess "http://localhost:5000"
    __exec docker rm -f $container_name

    echo "----- Testing ${runtime_tag} with standalone ${sdk_tag} app -----"
    container_name="runtime-standalone-test-${app_name}"
    __exec docker run -d -t -v "${app_dir}:/${app_name}" --workdir /${app_name} --name $container_name -p 5000:80 --entrypoint "/${app_name}/publish/self-contained/${app_name}" "${runtime_tag}"
    docker logs -f $container_name &
    WaitForSuccess "http://localhost:5000"
    __exec docker rm -f $container_name

done

popd > /dev/null
