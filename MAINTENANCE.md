# Maintainers’ Guide

This guide is meant for the maintainers of this repository and it is about
releasing new versions of ASP.NET Docker Image for each release.

## Releasing a New Version

> **NOTE:** It is recommended to do the following steps on a Mac/Linux machine as
some of the steps rely on symbolic links who does not properly work with
Git on Windows.

#### Step 1: New folder and Dockerfile

Create a new folder at the root with the image name and place the Dockerfile
updated over there.

We store all images in `master` branch (without tags) and this enables
us to maintain all versions at the same time easily.

Example:

    mkdir 1.0.0-beta6

#### Step 2: Move README

README.md is the file that is shown as the Docker Image description on
the Docker Hub page of the image. However Docker Hub has a bug (by design)
and requires README.md to be next to a Dockerfile that gets built.

In order to achieve that we keep the README.md right next to the latest
Dockerfile and update the symbolic link (also called README.md) to this
file, this enables image description to show up on GitHub properly as well.

Move README.md that lives in the latest image to this folder and update 
the symlink.

    mv 1.0.0-beta5/README.md 1.0.0-beta6
    unlink README.md
    ln -s 1.0.0-beta6/README.md README.md

#### Step 3: Update README

Update the relevant sections of `README.md` to reflect the latest version.

#### Step 4: Create a pull request

Do not directly push to `aspnet/aspnet-docker` repo. All commits must come
through GitHub pull requests and should be merged from the GitHub web UI.

#### Step 5: Update Docker Hub

Once the image is merged, it does not normally show up on Docker Hub because
the `latest` tag is not pointing to the folder of the new version.

Someone with the admin privileges on Microsoft organization on Docker Hub
must go to the Automated Build Settings of the repository and add the new
tag to the list and update the `latest` tag to point to this new folder as well.

Once the tags are updated, the automated build will be kicked off for all the
image tags, go to the Build Details page of the image to watch the results.
