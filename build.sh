#!/usr/bin/env bash
set -e  # Exit immediately upon failure
set -o pipefail  # Carry failures over pipes

suffix='-nightly'
folder='*'
while [[ $# > 0 ]]; do
    case $1 in
        --no-nightly)
            suffix=''
            ;;
        --folder)
            shift
            folder=$1
            ;;
        *)
            echo "Error: unrecognized command-line parameter $1"
            exit 1
            ;;
    esac
    shift
done

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function build_dockerfiles {
    for dockerfile_dir in ${1}; do
        echo "----- ${dockerfile_dir} -----"
        version="$(dirname $(dirname $dockerfile_dir) | sed -e 's/.\///')"
        image_os="$(basename $(dirname $dockerfile_dir))"
        case ${dockerfile_dir} in
            *runtime )
                tag="test/aspnetcore${suffix}:${version}-${image_os}"
                ;;
            *sdk )
                tag="test/aspnetcore-build${suffix}:${version}-${image_os}"
                ;;
            *kitchensink )
                tag="test/aspnetcore-build${suffix}:1.0-${version}-${image_os}"
                ;;
        esac
        echo "----- Building ${tag} -----"
        docker build --pull -t "${tag}" "${dockerfile_dir}"
    done
}

build_dockerfiles "$( find . -path './.*' -prune -o -name 'Dockerfile' -a -path "**/$folder/stretch/*" -print0 | xargs -0 -n1 dirname )"
build_dockerfiles "$( find . -path './.*' -prune -o -name 'Dockerfile' -a -path "**/$folder/jessie/*" -print0 | xargs -0 -n1 dirname )"
