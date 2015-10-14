#!/bin/bash

# Tool to refresh content in this repository
# Copyright (C) 2015 Red Hat, Inc.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


# This is a script to refresh content in this repository.
# It uses these files in current directory as input:
#   config.generated -- includes list of images that are generated using rhscl2dockerfile tool
#   config.remote    -- list of images that have upstream elsewhere
#   config.local     -- list of images that have upstream in this repository and are not generated

set -ex

# removes comments and empty lines from a file
strip_comments() {
  cat $@ | sed -e 's:#.*$::g' -e '/^[[:space:]]*$/d'
}

# checks whether image name lives here
lives_here() {
  [ -v REGENERATE_LOCALS ] && return 1
  grep -e "^[[:space:]]*$1[[:space:]]*\$" config.local
  return $?
}

# 1. clones rhscl2dockerfile repository
# 2. generates all the images
# 3. takes only the images from config.generated and for every entry in config.generated:
# 3a. removes old content in this repository
# 3b. adds new content from the generated content into this repository
refresh_generated() {
  r2d_repo=https://github.com/sclorg/rhscl2dockerfile.git

  # generate the dockerfiles first
  workingdir=$(mktemp -d /tmp/rhscl2dockerfile-repo-XXXXXX)
  git clone "$r2d_repo" "$workingdir"
  pushd "$workingdir"
  ./generate.py
  popd

  # now update all entries specified in config.generated
  strip_comments config.generated | while read image ; do
    lives_here "$image" && continue
    git rm -r "$image"
    cp -r "$workingdir/$image" "$image"

    # produce some sane info about where the image comes from
    echo "This image was generated from $r2d_repo (subdirectory $image) at `date -u`." >"$image/README.generation"
    git add "$image"
    echo "* $image" >>clog
  done
  rm -rf "$workingdir"
}

# for every entry in confit.remote
# 1. clones remote directory
# 2. removes old content in the directory of the image in this repository
# 3. adds new content from the remote repository into this repository
# It also renames Dockerfile.rhel{6,7} to Dockerfile
refresh_remotes() {
  strip_comments config.remote* | while read entry ; do
    # parse the entry
    image=$(echo "$entry" | awk '{print $1}')
    repo=$(echo "$entry" | awk '{print $2}')
    path=$(echo "$entry" | awk '{print $3}')
    branch=$(echo "$entry" | awk '{print $4}')
    lives_here "$image" && continue

    # remove old content if exists
    [ -d $image ] && git rm -r $image

    # clone remote repo and copy content
    workingdir=$(mktemp -d /tmp/remote-repo-XXXXXX)
    git clone $repo $workingdir
    pushd "$workingdir"
    [ -n "$branch" ] && git checkout "$branch"
    popd
    cp -r $workingdir/$path $image
    rm -rf $image/.git

    # some repositories contain more Dockerfiles in the repository, try to use the correct one
    [[ $image =~ rhel7 ]] && [ -f $image/Dockerfile.rhel7 ] && [ ! -L $image/Dockerfile.rhel7 ] && mv -f $image/Dockerfile.rhel7 $image/Dockerfile
    [[ $image =~ rhel6 ]] && [ -f $image/Dockerfile.rhel6 ] && [ ! -L $image/Dockerfile.rhel6 ] && mv -f $image/Dockerfile.rhel6 $image/Dockerfile

    # produce some sane info about where the image comes from
    echo "This image was pulled from $repo (subdirectory $path) at `date -u`." >$image/README.generation
    git add $image
    echo "* $image" >>clog

    # clean-up
    rm -rf $workingdir
  done
}

echo "Refreshed content for the following images:" >clog

refresh_generated

refresh_remotes


