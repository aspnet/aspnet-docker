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
if [[ $2 == "1.1"* ]]; then
    framework="netcoreapp1.1"
else
    framework='netcoreapp1.0'
fi
__exec dotnet new web --framework $framework

# restore only from $HOME/.nuget/packages to ensure the cache has already been warmed up
__exec dotnet msbuild "/t:Restore;Publish" \
    "/p:RuntimeIdentifiers=debian.8-x64" \
    "/p:PublishDir=publish/framework-dependent" \
    "/p:RestoreSources=$HOME/.nuget/packages"

echo "Testing self-contained deployment"
__exec dotnet publish -r debian.8-x64 -o publish/self-contained

