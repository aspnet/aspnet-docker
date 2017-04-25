#!/usr/bin/env bash
set -e 	# Exit immediately upon failure
set -o pipefail  # Carry failures over pipes

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
docker_repo="test/aspnetcore"

function build_dockerfiles {
    for dockerfile_dir in ${1}; do
        echo "----- ${dockerfile_dir} -----"
        tag="${docker_repo}:$( sed -e 's/.\///' -e 's/jessie\///' -e 's/\//-/g' <<< "${dockerfile_dir}" )"
        echo "----- Building ${tag} -----"
        docker build --pull -t "${tag}" "${dockerfile_dir}"
    done
}

build_dockerfiles "$( find . -path './.*' -prune -o -name 'Dockerfile' -a -path '**/jessie/*' -print0 | xargs -0 -n1 dirname )"
