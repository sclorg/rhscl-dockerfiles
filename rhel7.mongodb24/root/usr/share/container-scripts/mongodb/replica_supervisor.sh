#!/bin/sh
#
# This script registers the current container into MongoDB replica set and
# unregisters it when the container is terminated.

set -o errexit
set -o nounset
set -o pipefail

source  ${CONTAINER_SCRIPTS_PATH}/common.sh

echo "=> Waiting for local MongoDB to accept connections ..."
wait_for_mongo_up
set -x
# Add the current container to the replSet
mongo_add
