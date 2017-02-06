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
if [[ "$(dotnet --version)" != "1.0.0-preview2"* ]]; then
    if [[ $2 == "1.1"* ]]; then
        framework='netcoreapp1.1'
    else
        framework='netcoreapp1.0'
    fi
    __exec dotnet new web --framework $framework

    # restore only from $HOME/.nuget/packages to ensure the cache has already been warmed up
    __exec dotnet msbuild "/t:Restore;Publish" \
        "/p:RuntimeIdentifiers=debian.8-x64" \
        "/p:PublishDir=publish/framework-dependent" \
        "/p:RestoreSources=$HOME/.nuget/packages"

else
    __exec dotnet new -t web
fi

echo "Testing self-contained deployment"
if [[ $2 == *"projectjson"* ]]; then
    runtimes_section="  },\n  \"runtimes\": {\n    \"debian.8-x64\": {}\n  }"
    sed -i '/"type": "platform"/d' ./project.json
    sed -i "s/^  }$/${runtimes_section}/" ./project.json

    # restore only from $HOME/.nuget/packages to ensure the cache has already been warmed up
    __exec dotnet restore --source "$HOME/.nuget/packages"
    __exec dotnet publish -o publish/self-contained
else
    __exec dotnet publish -r debian.8-x64 -o publish/self-contained
fi
