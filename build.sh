#!/usr/bin/env bash
set -e  # Exit immediately upon failure
set -o pipefail  # Carry failures over pipes

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function build_dockerfiles {
    for dockerfile_dir in ${1}; do
        echo "----- ${dockerfile_dir} -----"
        version="$(dirname $(dirname $dockerfile_dir) | sed -e 's/.\///')"
        case ${dockerfile_dir} in
            *runtime )
                tag="test/aspnetcore:$version"
                ;;
            *sdk )
                tag="test/aspnetcore-build:$version"
                ;;
            *kitchensink )
                tag="test/aspnetcore-build:1.0-$version"
                ;;
        esac
        echo "----- Building ${tag} -----"
        docker build --pull -t "${tag}" "${dockerfile_dir}"
    done
}

build_dockerfiles "$( find . -path './.*' -prune -o -name 'Dockerfile' -a -path '**/jessie/*' -print0 | xargs -0 -n1 dirname )"
