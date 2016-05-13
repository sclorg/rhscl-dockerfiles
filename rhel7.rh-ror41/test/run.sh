#!/usr/bin/env bash

. ./utils.sh

IMAGE_NAME="${IMAGE_NAME:-rhscl/ror-41-rhel7}"

function create_container() {
    local name=$1 ; shift
    cidfile="$CIDFILE_DIR/$name"
    # create container with a cidfile in a directory for cleanup
    eval docker run ${DOCKER_ARGS:-} --cidfile $cidfile -d $IMAGE_NAME $CONTAINER_ARGS || return 1
    echo "Created container $(cat $cidfile)"
}

function get_cid() {
  local id="$1" ; shift || return 1
  echo $(cat "$CIDFILE_DIR/$id")
}

function rm_container {
    local name="$1"
    local cid="`get_cid $name`"
    docker kill "$cid"
    docker rm "$cid"
    rm -f "$CIDFILE_DIR/$name"
}

tmpdir="`mktemp -d`"
pushd $tmpdir > /dev/null || exit 1

CIDFILE_DIR="$tmpdir/cidfiles"
mkdir $CIDFILE_DIR || exit 1

run_command_headsup "docker pull $IMAGE_NAME"

# Ruby, Rails and Node.js have to be present and directly available:
run_command_headsup "docker run --rm $IMAGE_NAME /bin/bash -c 'ruby -v' > output"
run_command_headsup "fgrep 'ruby 2.2' output"
run_command_headsup "docker run --rm $IMAGE_NAME /bin/bash -c 'rails -v' > output"
run_command_headsup "fgrep 'Rails 4.1' output"
run_command_headsup "docker run --rm $IMAGE_NAME /bin/bash -c 'node -v' > output"
run_command_headsup "fgrep 'v0.10' output"

# Check Rails welcome page
CONTAINER_ARGS="bash -c 'rails new myapp --skip-bundle && cd myapp && bundle --local && rails s -p 8080'"
DOCKER_ARGS='-p 8080:8080'
run_command_headsup "create_container test_welcome_page"
CONTAINER_ARGS=
DOCKER_ARGS=
for i in `seq 10`; do
    sleep 5
    run_command_headsup 'curl localhost:8080 > output'
    res=$?
    run_command_headsup "fgrep 'Ruby on Rails: Welcome aboard' output"
    test $res = 0 && break
done
rm_container test_welcome_page

# Check asset precompilation works
CONTAINER_ARGS="bash -c 'rails new myapp --skip-bundle && cd myapp && bundle --local && rake assets:precompile'"
run_command_headsup "docker run --rm $IMAGE_NAME $CONTAINER_ARGS"

popd > /dev/null
rm -Rf "$tmpdir"

exit_overall
