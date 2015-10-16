#!/bin/bash

source /var/lib/mongodb/common.sh

echo -n "=> Waiting for MongoDB endpoints ..."
while true; do
  if [ ! -z "$(endpoints)" ]; then
    echo $(endpoints)
    break
  fi
  sleep 2
done

# Let initialize the first member of the cluster
current_endpoints=$(endpoints)
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
MONGODB_NO_SUPERVISOR=1 MONGODB_NO_AUTH=1 /usr/local/bin/run-mongod.sh mongod &
wait_for_mongo_up

# This will perform the 'rs.initiate()' command on the current MongoDB.
mongo_initiate

echo "=> Creating MongoDB users ..."
mongo_create_users

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
