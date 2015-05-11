#!/bin/bash

source /usr/share/cont-layer/common/functions.sh

source /usr/share/cont-layer/mongodb/common/base-functions.sh

# Shutdown mongod on SIGINT/SIGTERM
function cleanup() {
    echo "=> Shutting down MongoDB server"
    if [ -s $dbpath/mongod.lock ]; then
        mongod $mongod_common_args --shutdown
    fi
    wait_mongo "DOWN"

    exit 0
}

MAX_ATTEMPTS=90
SLEEP_TIME=2

mongod_config_file="/etc/mongod.conf"

# Change config file according MONGOD_CONFIG_* variables
update_conf "MONGOD_CONFIG_" $mongod_config_file

# Get options from config file
dbpath=$(get_option "dbpath" $mongod_config_file)

# Get used port
port=$(get_port $mongod_config_file)
port=${port:-27017}

trap 'cleanup' SIGINT SIGTERM

# Run scripts before mongod start
cont_source_hooks pre-init.d mongodb

# Add default config file
mongod_common_args="-f $mongod_config_file "
mongo_local_args="--bind_ip localhost "

# Start background MongoDB service with disabled authentication
mongod $mongod_common_args $mongo_local_args &
wait_mongo "UP"

# Run scripts with started mongod
cont_source_hooks init.d mongodb

# Stop background MongoDB service to exec mongod
mongod $mongod_common_args $mongo_local_args --shutdown
wait_mongo "DOWN"

# Run scripts after mongod stoped
cont_source_hooks post-init.d mongodb

# Start MongoDB service with enabled authentication
exec mongod $mongod_common_args
