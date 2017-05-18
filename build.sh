#!/usr/bin/env bash
set -e  # Exit immediately upon failure
set -o pipefail  # Carry failures over pipes

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function build_dockerfiles {
    for dockerfile_dir in ${1}; do
        echo "----- ${dockerfile_dir} -----"
        tag="$( sed -e 's/.\///' -e 's/jessie\///' -e 's/\//-/g' <<< "${dockerfile_dir}" )"
        case $tag in
            *-runtime )
                docker_repo="test/aspnetcore"
                ;;
            *-sdk|*-kitchensink )
                docker_repo="test/aspnetcore-build"
                ;;
        esac
        image_name="$docker_repo:$tag"
        echo "----- Building ${image_name} -----"
        docker build --pull -t "${image_name}" "${dockerfile_dir}"
    done
}

build_dockerfiles "$( find . -path './.*' -prune -o -name 'Dockerfile' -a -path '**/jessie/*' -print0 | xargs -0 -n1 dirname )"
