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
# It uses these files in current directory as input (may be changed using args):
#   config.generated -- includes list of images that are generated using rhscl2dockerfile tool
#   config.remote    -- list of images that have upstream elsewhere
#   config.local     -- list of images that have upstream in this repository and are not generated

set -e

# removes comments and empty lines from a file
strip_comments() {
  cat $@ | sed -e 's:#.*$::g' -e '/^[[:space:]]*$/d'
}

# checks whether image name lives here
lives_here() {
  [ -v REGENERATE_LOCALS ] && return 1
  grep -e "^[[:space:]]*$1[[:space:]]*\$" $CONFIG_LOCAL
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
  echo "Clonning repo $r2d_repo ..."
  git clone -q "$r2d_repo" "$workingdir"
  pushd "$workingdir"
  ./generate.py
  popd

  # now update all entries specified in config.generated
  strip_comments $CONFIG_GENERATED | while read image ; do
    lives_here "$image" && continue
    if test -d "$image"; then
        git rm -rf "$image"
    fi
    cp -r "$workingdir/$image" "$image"

    # produce some sane info about where the image comes from
    echo "This image was generated from $r2d_repo (subdirectory $image)." >"$image/README.generation"
    git add "$image"
    echo "* $image" >>clog
  done
  rm -rf "$workingdir"
}

# for every entry in config.remote
# 1. clones remote directory
# 2. removes old content in the directory of the image in this repository
# 3. adds new content from the remote repository into this repository
# It also renames Dockerfile.rhel{6,7} to Dockerfile
refresh_remotes() {
  strip_comments $CONFIG_REMOTE | while read entry ; do
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
    echo "Clonning repo $repo ..."
    git clone -q $repo $workingdir
    pushd "$workingdir"
    [ -n "$branch" ] && git checkout "$branch"
    popd
    cp -r $workingdir/$path $image
    rm -rf $image/.git

    # some repositories contain more Dockerfiles in the repository, try to use the correct one
    [[ $image =~ rhel7 ]] && [ -f $image/Dockerfile.rhel7 ] && [ ! -L $image/Dockerfile.rhel7 ] && mv -f $image/Dockerfile.rhel7 $image/Dockerfile
    [[ $image =~ rhel6 ]] && [ -f $image/Dockerfile.rhel6 ] && [ ! -L $image/Dockerfile.rhel6 ] && mv -f $image/Dockerfile.rhel6 $image/Dockerfile

    # do not include specific build id in the Dockerfile
    sed -i -e 's/^\(FROM\s*\)\(rhel7.*\)$/\1rhel:7.2-released/' $image/Dockerfile

    # remove osbs logs
    rm -rf $image/.osbs-logs

    # if current directory doesn't include README or README.md, but it is located in upper directory, then include that one
    if [ "$path" != "." ] && ! [ -f $image/README.md ] && ! [ -f $image/README ] ; then
      [ -f $workingdir/$path/../README ] && cp $workingdir/$path/../README $image/
      [ -f $workingdir/$path/../README.md ] && cp $workingdir/$path/../README.md $image/
    fi

    # produce some sane info about where the image comes from
    echo "This image was pulled from $(echo $repo | sed -e 's/[a-z0-9\.]*redhat.com/internal-url-hidden/g') (subdirectory $path)." >$image/README.generation
    git add $image
    echo "* $image" >>clog

    # clean-up
    rm -rf $workingdir
  done
}

# lists tracked or untracked dockerfiles (depending on argument) that are in git:
# * tracked: 0 = print tracked dockerfiles, 1 = print untracked dockerfiles
show_tracked() {
  print_tracked=${1-0}
  list_tracked=$(mktemp /tmp/tracked-list-XXXXXX)
  strip_comments $CONFIG_GENERATED $CONFIG_LOCAL $CONFIG_REMOTE | awk '{print $1}' >"$list_tracked"
  git ls-files | grep -e "/" | sed -e 's|/.*||g' | sort | uniq | while read d ; do
    grep -e "^[[:space:]]*${d}[[:space:]]*$" "$list_tracked" >/dev/null && r=0 || r=1
    [ "$print_tracked" -eq $r ] && echo "$d"
  done | sort
  rm -f "$list_tracked"
}

show_configured() {
  strip_comments $CONFIG_GENERATED $CONFIG_LOCAL $CONFIG_REMOTE | awk '{print $1}' | sort
}

show_missing() {
  strip_comments $CONFIG_GENERATED $CONFIG_LOCAL $CONFIG_REMOTE | awk '{print $1}' | while read d ; do
    [ -d "$d" ] || echo "$d"
  done | sort
}

usage() {
  echo "Usage: `basename $0` [ -h|--help ] [ -t|--tracked ] [ -n|--not-tracked ]"
  echo
  echo "Without arguments it generates content of the repository based on config.* files and adds changes into git staging area."
  echo
  echo "Options:"
  echo "  -h|--help                     Print this help"
  echo "  -t|--list-tracked             Print tracked Dockerfiles (either generated or hosting here)"
  echo "  -n|--list-not-tracked         Print non-tracked Dockerfiles (those that are not generated or hosting here)"
  echo "  -c|--list-configured          Print configured Dockerfiles (either generated or hosting here)"
  echo "  -m|--list-missing             Print configured but missing Dockerfiles"
  echo "  -r|--config-remote <file>     Set configuration of remote repos to file <file>"
  echo "  -g|--config-generate <file>  Set configuration of generated repos to file <file>"
  echo "  -l|--config-local <file>      Set configuration of local repos to file <file>"
  echo "  -d|--debug                    Sets set -x"
}

CONFIG_LOCAL='config.local'
CONFIG_GENERATED='config.generated'
CONFIG_REMOTE='config.remote'
while [ $# -ge 1 ] ; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -t|--list-tracked)
      show_tracked 0
      exit 0
      ;;
    -n|--list-not-tracked)
      show_tracked 1
      exit 0
      ;;
    -c|--list-configured)
      show_configured
      exit 0
      ;;
    -m|--list-missing)
      show_missing
      exit 0
      ;;
    -r|--config-remote)
      CONFIG_REMOTE="$2"
      shift
      ;;
    -l|--config-local)
      CONFIG_LOCAL="$2"
      shift
      ;;
    -g|--config-generate)
      CONFIG_GENERATED="$2"
      shift
      ;;
    -d|--debug)
      set -x
      ;;
    *)
      usage
      exit 1
      ;;
  esac
  shift
done

echo "This program regenerates content of this repository based on $CONFIG_GENERATED $CONFIG_LOCAL $CONFIG_REMOTE files and adds the new files into git staging."
while true; do
    read -p "Do you want to proceed with regeneration? (yes/no): " yn
    case $yn in
        [Yy]* ) break ;;
        [Nn]* ) exit ;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "Refreshed content for the following images:" >clog

refresh_generated

refresh_remotes

echo 'Done.'

