#!/bin/bash

source /usr/share/cont-layer/common/functions.sh

source /usr/share/cont-layer/mongodb/common/base-functions.sh

# Shutdown mongod on SIGINT/SIGTERM
function cleanup() {
    echo "=> Shutting down MongoDB server"
    if [ -s $pidfile ]; then
        set +e
        kill $(cat $pidfile)
        set -e
    fi
    wait_mongo "DOWN"
    status=$?

    if [ $status -ne 0 -a -s $pidfile ]; then
        set +e
        kill -9 $(cat $pidfile)
        set -e
        wait_mongo "DOWN"
    fi

    exit 0
}

MAX_ATTEMPTS=90
SLEEP_TIME=2

mongos_config_file="/etc/mongos.conf"

# Change config file according MONGOS_CONFIG_* variables
update_conf "MONGOS_CONFIG_" $mongos_config_file

# Get options from config file
pidfile=$(get_option "pidfilepath" $mongos_config_file)

# Get used port
port=$(get_port $mongos_config_file)
port=${port:-27017}

trap 'cleanup' SIGINT SIGTERM

# Run scripts before mongod start
cont_source_hooks pre-init.d mongodb

# Add default config file
mongos_common_args="-f $mongos_config_file "
mongo_local_args="--bind_ip localhost "

# Start background MongoDB service with disabled authentication
mongos $mongos_common_args $mongo_local_args &
wait_mongo "UP"

# Run scripts with started mongod
cont_source_hooks init.d mongodb

# Stop background MongoDB service to exec mongos
set +e
kill $(cat $pidfile)
set -e
wait_mongo "DOWN"
status=$?

if [ $status -ne 0 ]; then
    set +e
    kill -9 $(cat $pidfile)
    set -e
    wait_mongo "DOWN"
fi

# Run scripts after mongod stoped
cont_source_hooks post-init.d mongodb

# Start MongoDB service with enabled authentication
exec mongos $mongos_common_args
