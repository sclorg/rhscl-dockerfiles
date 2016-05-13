#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Used for wait_for_mongo_* functions
MAX_ATTEMPTS=60
SLEEP_TIME=1

export MONGODB_CONFIG_PATH=/etc/mongod.conf
export MONGODB_PID_FILE=/var/lib/mongodb/mongodb.pid
export MONGODB_KEYFILE_PATH=/var/lib/mongodb/keyfile
export CONTAINER_PORT=27017

# container_addr returns the current container external IP address
function container_addr() {
  echo -n $(cat ${HOME}/.address)
}

# mongo_addr returns the IP:PORT of the currently running MongoDB instance
function mongo_addr() {
  echo -n "$(container_addr):${CONTAINER_PORT}"
}

# cache_container_addr waits till the container gets the external IP address and
# cache it to disk
function cache_container_addr() {
  echo -n "=> Waiting for container IP address ..."
  local i
  for i in $(seq "$MAX_ATTEMPTS"); do
    if ip -oneline -4 addr show up scope global | grep -Eo '[0-9]{,3}(\.[0-9]{,3}){3}' > "${HOME}"/.address; then
      echo " $(mongo_addr)"
      return 0
    fi
    sleep $SLEEP_TIME
  done
  echo "Failed to get Docker container IP address." && exit 1
}

# wait_for_mongo_up waits until the mongo server accepts incomming connections
function wait_for_mongo_up() {
  local mongo_host
  mongo_host="${1-}"
  local mongo_cmd
  mongo_cmd="mongo admin "

  if [ -n "${mongo_host}" ]; then
    mongo_cmd+="--host ${mongo_host}:${CONTAINER_PORT} "
  fi

  local i
  for i in $(seq $MAX_ATTEMPTS); do
    echo "=> Waiting for MongoDB service startup ${mongo_host} ..."
    if $mongo_cmd --eval 'help' &>/dev/null; then
      echo "=> MongoDB service has started"
      return 0
    fi
    sleep $SLEEP_TIME
  done
  echo "=> Giving up: Failed to start MongoDB service!"
  exit 1
}

# wait_for_mongo_down waits until the mongo server is down
function wait_for_mongo_down() {
  local i
  for i in $(seq $MAX_ATTEMPTS); do
    echo "=> Waiting for MongoDB service shutdown ..."
    if ! mongo admin --eval 'help' &>/dev/null; then
      echo "=> MongoDB service has stopped"
      return 0
    fi
    sleep $SLEEP_TIME
  done
  echo "=> Giving up: Failed to stop MongoDB service"
  exit 1
}

# endpoints returns list of IP addresses with other instances of MongoDB
# To get list of endpoints, you need to have headless Service named 'mongodb'.
# NOTE: This won't work with standalone Docker container.
function endpoints() {
  service_name=${MONGODB_SERVICE_NAME:-mongodb}
  dig ${service_name} A +search +short 2>/dev/null
}

# build_mongo_config builds the MongoDB replicaSet config used for the cluster
# initialization.
# Takes a list of space-separated member IPs as the first argument.
function build_mongo_config() {
  local current_endpoints
  current_endpoints="$1"
  local members
  members="{ _id: 0, host: \"$(mongo_addr)\"},"
  local member_id
  member_id=1
  local container_addr
  container_addr="$(container_addr)"
  local node
  for node in ${current_endpoints}; do
    if [ "$node" != "$container_addr" ]; then
      members+="{ _id: ${member_id}, host: \"${node}:${CONTAINER_PORT}\"},"
      let member_id++
    fi
  done
  echo -n "var config={ _id: \"${MONGODB_REPLICA_NAME}\", members: [ ${members%,} ] }"
}

# mongo_initiate initiates the replica set.
# Takes a list of space-separated member IPs as the first argument.
function mongo_initiate() {
  local mongo_wait
  mongo_wait="while (rs.status().startupStatus || (rs.status().hasOwnProperty(\"myState\") && rs.status().myState != 1)) { printjson( rs.status() ); sleep(1000); }; printjson( rs.status() );"
  config=$(build_mongo_config "$1")
  echo "=> Initiating MongoDB replica using: ${config}"
  mongo admin --eval "${config};rs.initiate(config);${mongo_wait}"
}

# get the address of the current primary member
function mongo_primary_member_addr() {
  local rc=0

  endpoints | grep -v "$(container_addr)" |
  (
    while read mongo_node; do
      cmd_output="$(mongo admin -u admin -p "$MONGODB_ADMIN_PASSWORD" --host "$mongo_node:$CONTAINER_PORT" --eval 'print(rs.isMaster().primary)' --quiet || true)"

      # Trying to find IP:PORT in output and filter out error message because mongo prints it to stdout
      ip_and_port_regexp='[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+:[0-9]\+'
      if addr="$(echo "$cmd_output" | grep -x "$ip_and_port_regexp")"; then
        echo -n "$addr"
        exit 0
      fi

      echo >&2 "Cannot get address of primary from $mongo_node node: $cmd_output"
    done

    exit 1
  ) || rc=$?

  if [ $rc -ne 0 ]; then
    echo >&2 "Cannot get address of primary node: after checking all nodes we don't have the address"
    return 1
  fi
}

# mongo_remove removes the current MongoDB from the cluster
function mongo_remove() {
  local primary_addr
  # if we cannot determine the IP address of the primary, exit without an error
  # to allow callers to proceed with their logic
  primary_addr="$(mongo_primary_member_addr || true)"
  if [ -z "$primary_addr" ]; then
    return
  fi

  local mongo_addr
  mongo_addr="$(mongo_addr)"

  echo "=> Removing ${mongo_addr} on ${primary_addr} ..."
  mongo admin -u admin -p "${MONGODB_ADMIN_PASSWORD}" \
    --host "${primary_addr}" --eval "rs.remove('${mongo_addr}');" || true
}

# mongo_add advertise the current container to other mongo replicas
function mongo_add() {
  local primary_addr
  # if we cannot determine the IP address of the primary, exit without an error
  # to allow callers to proceed with their logic
  primary_addr="$(mongo_primary_member_addr || true)"
  if [ -z "$primary_addr" ]; then
    return
  fi

  local mongo_addr
  mongo_addr="$(mongo_addr)"

  echo "=> Adding ${mongo_addr} to ${primary_addr} ..."
  mongo admin -u admin -p "${MONGODB_ADMIN_PASSWORD}" \
    --host "${primary_addr}" --eval "rs.add('${mongo_addr}');"
}

# run_mongod_supervisor runs the MongoDB replica supervisor that manages
# registration of the new members to the MongoDB replica cluster
function run_mongod_supervisor() {
  ${CONTAINER_SCRIPTS_PATH}/replica_supervisor.sh 2>&1 &
}

# mongo_create_admin creates the MongoDB admin user with password: MONGODB_ADMIN_PASSWORD
# $1 - login parameters for mongo (optional)
# $2 - host where to connect (localhost by default)
function mongo_create_admin() {
  if [[ -z "${MONGODB_ADMIN_PASSWORD:-}" ]]; then
    echo "=> MONGODB_ADMIN_PASSWORD is not set. Authentication can not be set up."
    exit 1
  fi

  # Set admin password
  local js_command="db.addUser({user: 'admin', pwd: '${MONGODB_ADMIN_PASSWORD}', roles: ['dbAdminAnyDatabase', 'userAdminAnyDatabase' , 'readWriteAnyDatabase','clusterAdmin' ]});"
  if ! mongo admin ${1:-} --host ${2:-"localhost"} --eval "${js_command}"; then
    echo "=> Failed to create MongoDB admin user."
    exit 1
  fi
}

# mongo_create_user creates the MongoDB database user: MONGODB_USER,
# with password: MONGDOB_PASSWORD, inside database: MONGODB_DATABASE
# $1 - login parameters for mongo (optional)
# $2 - host where to connect (localhost by default)
function mongo_create_user() {
  # Ensure input variables exists
  if [[ -z "${MONGODB_USER:-}" ]]; then
    echo "=> MONGODB_USER is not set. Failed to create MongoDB user: ${MONGODB_USER}"
    exit 1
  fi
  if [[ -z "${MONGODB_PASSWORD:-}" ]]; then
    echo "=> MONGODB_PASSWORD is not set. Failed to create MongoDB user: ${MONGODB_USER}"
    exit 1
  fi
  if [[ -z "${MONGODB_DATABASE:-}" ]]; then
    echo "=> MONGODB_DATABASE is not set. Failed to create MongoDB user: ${MONGODB_USER}"
    exit 1
  fi

  # Create database user
  local js_command="db.getSiblingDB('${MONGODB_DATABASE}').addUser({user: '${MONGODB_USER}', pwd: '${MONGODB_PASSWORD}', roles: [ 'readWrite' ]});"
  if ! mongo admin ${1:-} --host ${2:-"localhost"} --eval "${js_command}"; then
    echo "=> Failed to create MongoDB user: ${MONGODB_USER}"
    exit 1
  fi
}

# mongo_reset_passwords sets the MongoDB passwords to match MONGODB_PASSWORD
# and MONGODB_ADMIN_PASSWORD
# $1 - login parameters for mongo (optional)
# $2 - host where to connect (localhost by default)
function mongo_reset_passwords() {
  # Reset password of MONGODB_USER
  if [[ -n "${MONGODB_USER:-}" && -n "${MONGODB_PASSWORD:-}" && -n "${MONGODB_DATABASE:-}" ]]; then
    local js_command="db.changeUserPassword('${MONGODB_USER}', '${MONGODB_PASSWORD}')"
    if ! mongo ${MONGODB_DATABASE} ${1:-} --host ${2:-"localhost"} --eval "${js_command}"; then
      echo "=> Failed to reset password of MongoDB user: ${MONGODB_USER}"
      exit 1
    fi
  fi

  # Reset password of admin
  if [[ -n "${MONGODB_ADMIN_PASSWORD:-}" ]]; then
    local js_command="db.changeUserPassword('admin', '${MONGODB_ADMIN_PASSWORD}')"
    if ! mongo admin --eval "${js_command}"; then
      echo "=> Failed to reset password of MongoDB user: ${MONGODB_USER}"
      exit 1
    fi
  fi
}

# setup_keyfile fixes the bug in mounting the Kubernetes 'Secret' volume that
# mounts the secret files with 'too open' permissions.
function setup_keyfile() {
  if [ -z "${MONGODB_KEYFILE_VALUE-}" ]; then
    echo "ERROR: You have to provide the 'keyfile' value in $MONGODB_KEYFILE_VALUE"
    exit 1
  fi
  echo ${MONGODB_KEYFILE_VALUE} > ${MONGODB_KEYFILE_PATH}
  chmod 0600 ${MONGODB_KEYFILE_PATH}
}
