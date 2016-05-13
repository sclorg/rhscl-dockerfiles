#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

source ${CONTAINER_SCRIPTS_PATH}/common.sh

current_endpoints=$(endpoints)
if [ -n "${MONGODB_INITIAL_REPLICA_COUNT:-}" ]; then
  echo -n "=> Waiting for $MONGODB_INITIAL_REPLICA_COUNT MongoDB endpoints ..."
  while [[ "$(echo "${current_endpoints}" | wc -l)" -lt ${MONGODB_INITIAL_REPLICA_COUNT} ]]; do
    sleep 2
    current_endpoints=$(endpoints)
  done
else
  echo "Attention: MONGODB_INITIAL_REPLICA_COUNT is not set and it could lead to a improperly configured replica set."
  echo "To fix this, set MONGODB_INITIAL_REPLICA_COUNT variable to the number of members in the replica set in"
  echo "the configuration of post deployment hook."

  echo -n "=> Waiting for MongoDB endpoints ..."
  while [ -z "${current_endpoints}" ]; do
    sleep 2
    current_endpoints=$(endpoints)
  done
fi
echo "${current_endpoints}"

# Let initialize the first member of the cluster
mongo_node="$(echo -n ${current_endpoints} | cut -d ' ' -f 1):${CONTAINER_PORT}"

echo "=> Waiting for all endpoints to accept connections..."
for node in ${current_endpoints}; do
  wait_for_mongo_up ${node} &>/dev/null
done

echo "=> Initiating the replSet ${MONGODB_REPLICA_NAME} ..."
# Start the MongoDB without authentication to initialize and kick-off the cluster:
# This MongoDB server is just temporary and will be removed later in this
# script.
export MONGODB_REPLICA_NAME
MONGODB_NO_SUPERVISOR=1 MONGODB_NO_AUTH=1 run-mongod mongod &
wait_for_mongo_up

# This will perform the 'rs.initiate()' command on the current MongoDB.
mongo_initiate "${current_endpoints}"

echo "=> Creating MongoDB users ..."
mongo_create_admin
mongo_create_user "-u admin -p ${MONGODB_ADMIN_PASSWORD}"

echo "=> Waiting for replication to finish ..."
# TODO: Replace this with polling or a Mongo script that will check if all
#       members of the cluster are now properly replicated (user accounts are
#       created on all members).
sleep 10

# Some commands will force MongoDB client to re-connect. This is not working
# well in combination with '--eval'. In that case the 'mongo' command will fail
# with return code 254.
echo "=> Initiate Pod giving up the PRIMARY role ..."
mongo admin -u admin -p "${MONGODB_ADMIN_PASSWORD}" --quiet --eval "rs.stepDown(120);" &>/dev/null || true

# Wait till the new PRIMARY member is elected
echo "=> Waiting for the new PRIMARY to be elected ..."
mongo admin -u admin -p "${MONGODB_ADMIN_PASSWORD}" --quiet --host ${mongo_node} --eval "var done=false;while(done==false){var members=rs.status().members;for(i=0;i<members.length;i++){if(members[i].stateStr=='PRIMARY' && members[i].name!='$(mongo_addr)'){done=true}};sleep(500)};" &>/dev/null

# Remove the initialization container MongoDB from cluster and shutdown
echo "=> The new PRIMARY member is $(mongo_primary_member_addr), shutting down current member ..."
mongo_remove

mongod -f ${MONGODB_CONFIG_PATH} --shutdown &>/dev/null
wait_for_mongo_down

echo "=> Successfully initialized replSet"
