#!/usr/bin/env bash
set -e 	# Exit immediately upon failure
set -o pipefail  # Carry failures over pipes

docker_repo="microsoft/aspnetcore"
repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

if [ -z "${DEBUGTEST}" ]; then
    optional_docker_run_args="--rm"
fi

function WaitForSuccess {
    for i in $(seq 60); do
        echo '.'
        curl --silent --output /dev/null $1 && return 0
        sleep 1
    done
    return 1
}

pushd "${repo_root}" > /dev/null

# Loop through each sdk Dockerfile in the repo and test the sdk and runtime images.
for sdk_tag in $( find . -path './.*' -prune -o -path '*/jessie/build-msbuild/Dockerfile' -print0 | xargs -0 -n1 dirname | sed -e 's/aspnet-docker\///' -e 's/.\///' -e 's/jessie\///' -e 's/\//-/g' ); do

    app_name="app$(date +%s)"
    app_dir="${repo_root}/.test-assets/${app_name}"
    mkdir -p "${app_dir}"
    echo "---- Generating application directory ${app_dir} ---- "

    full_sdk_tag="${docker_repo}:${sdk_tag}"

    # microsoft/aspnetcore:1.0-build-msbuild => microsoft/aspnetcore:1.0-runtime
    runtime_tag="$( echo "${full_sdk_tag}" | sed -e 's/build-msbuild/runtime/' -e 's/build-projectjson/runtime/' )"

    echo "---- Testing ${full_sdk_tag} and ${runtime_tag} ----"
    docker run -t ${optional_docker_run_args} -v "${app_dir}:/${app_name}" -v "${repo_root}/test:/test" --name "build-test-${app_name}" --entrypoint /test/create-run-publish-app.sh "${full_sdk_tag}" "${app_name}" "${sdk_tag}"

    echo "----- Testing ${runtime_tag} with ${sdk_tag} app -----"
    docker run -d -t -v "${app_dir}:/${app_name}" --workdir /${app_name} --name "runtime-test-${app_name}" -p 5000:80 --entrypoint dotnet "${runtime_tag}" "/${app_name}/publish/framework-dependent/${app_name}.dll"
    WaitForSuccess "http://localhost:5000"
    docker stop "runtime-test-${app_name}"

    echo "----- Testing ${runtime_tag} with ${sdk_tag} app -----"
    docker run -d -t -v "${app_dir}:/${app_name}" --workdir /${app_name} --name "runtime-standalone-test-${app_name}" -p 5000:80 --entrypoint "/${app_name}/publish/self-contained/${app_name}" "${runtime_tag}"
    WaitForSuccess "http://localhost:5000"
    docker stop "runtime-standalone-test-${app_name}"

done

popd > /dev/null