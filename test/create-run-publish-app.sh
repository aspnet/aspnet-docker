#!/usr/bin/env bash
set -e  # Exit immediately upon failure

# colors
RED='\033[0;31m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

function __exec {
    local cmd=$1
    shift
    echo -e "${MAGENTA}$(hostname) > $cmd $@${RESET}"
    $cmd $@
}

: ${1?"Need to pass sandbox directory as argument"}
: ${2?"Need to pass sdk image tag as argument"}

cd $1

echo "Testing framework-dependent deployment"
framework=$2
if [[ $framework == 'netcoreapp1.0' || $framework == 'netcoreapp1.1' ]]; then
    __exec dotnet new web --framework $framework
else
    __exec dotnet new web --framework $framework --no-restore
fi

# restore only from $HOME/.nuget/packages to ensure the cache has already been warmed up
__exec dotnet restore \
    --source "$HOME/.nuget/packages" \
    "/p:RuntimeIdentifiers=debian.8-x64"

echo "Testing framework-dependent deployment"
__exec dotnet publish \
    --configuration Release \
    --output publish/framework-dependent

echo "Testing self-contained deployment"
__exec dotnet publish \
    --configuration Release \
    --runtime debian.8-x64 \
    --output publish/self-contained

# Self-contained applications
exec_name="$(basename $(pwd))"
__exec chmod +x publish/self-contained/$exec_name
