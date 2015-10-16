#!/bin/sh
#
# This script registers the current container into MongoDB replica set and
# unregisters it when the container is terminated.

source /var/lib/mongodb/common.sh

# Redirect all stdout && stderr into a FIFO pipe
exec 1<&-
exec 2<&-
exec 1<>$1
exec 2>&1

echo "=> Waiting for local MongoDB to accept connections ..."
wait_for_mongo_up
set -x
# Add the current container to the replSet
mongo_add
