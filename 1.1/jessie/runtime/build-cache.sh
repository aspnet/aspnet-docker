#!/usr/bin/env sh
set -e

curl -sSLo /tmp/packagescache.tar.gz $1
mkdir -p $DOTNET_HOSTING_OPTIMIZATION_CACHE
tar xf /tmp/packagescache.tar.gz -C $DOTNET_HOSTING_OPTIMIZATION_CACHE
rm /tmp/packagescache.tar.gz

link_lowercase() {
    filename=$(basename $1)
    dir=$(dirname $1)
    lower_filename=$(echo $filename | awk '{print tolower($0)}')
    ln -s $1 $dir/$lower_filename
    echo "Created symlink '$1' => '$dir/$lower_filename'"
}

# create lower case symlinks because NuGet 3.5 (project.json) and NuGet 4 (MSBuild)
# results in different casing in deps.json which affects cache lookup

for shafile in $DOTNET_HOSTING_OPTIMIZATION_CACHE/x64/*/*/*.sha512; do
    link_lowercase $shafile
done

for dir in $DOTNET_HOSTING_OPTIMIZATION_CACHE/x64/*; do
    link_lowercase $dir
done
