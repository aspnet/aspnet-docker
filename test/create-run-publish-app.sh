#!/usr/bin/env bash
set -e  # Exit immediately upon failure

: ${1?"Need to pass sandbox directory as argument"}
: ${2?"Need to pass sdk image tag as argument"}

cd $1

echo "Testing framework-dependent deployment"
if [[ $2 == "1.1-build-msbuild" ]]; then
    dotnet new3 web --framework 1.1
else
    dotnet new -t web
fi

dotnet restore /p:RuntimeIdentifiers=debian.8-x64
dotnet publish -o publish/framework-dependent

echo "Testing self-contained deployment"
if [[ $2 == *"projectjson"* ]]; then
    runtimes_section="  },\n  \"runtimes\": {\n    \"debian.8-x64\": {}\n  }"
    sed -i '/"type": "platform"/d' ./project.json
    sed -i "s/^  }$/${runtimes_section}/" ./project.json

    dotnet restore
    dotnet publish -o publish/self-contained
else
    dotnet publish -r debian.8-x64 -o publish/self-contained
fi
