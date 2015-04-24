#!/bin/bash

# this function sources *.sh in the following directories in this order:
# /usr/share/cont-layer/$1/$2.d
# /usr/share/cont-volume/$1/$2.d
source_scripts() {
    [ -z "$2" ] && return
    for dir in cont-layer cont-volume ; do
        full_dir="/usr/share/$dir/${1}/${2}.d"
        for i in ${full_dir}/*.sh; do
            if [ -r "$i" ]; then
                . "$i"
            fi
        done
    done
}

# Wait_mongo waits until the mongo server is up/down
function wait_mongo() {
    operation=-eq
    if [ $1 = "DOWN" -o $1 = "down" ]; then
        operation=-ne
    fi

    local mongo_host="${2-}"
    local mongo_cmd="mongo admin "

    if [ ! -z "${mongo_host}" ]; then
        mongo_cmd+="--host ${mongo_host}:${CONTAINER_PORT} "
    fi

    for i in $(seq $MAX_ATTEMPTS); do
        echo "=> ${mongo_host} Waiting for MongoDB daemon $1"
        set +e
        $mongo_cmd --eval "quit()" &>/dev/null
        status=$?
        set -e
        if [ $status $operation 0 ]; then
            echo "=> MongoDB daemon is $1"
            return 0
        fi
        sleep $SLEEP_TIME
    done
    echo "=> Giving up: MongoDB daemon is not $1!"
    exit 1
}

# Shutdown mongod on SIGINT/SIGTERM
function cleanup() {
    echo "=> Shutting down MongoDB server"
    if [ -s $dbpath/mongod.lock ]; then
        mongod $mongo_common_args --shutdown
    fi
    wait_mongo "DOWN"

    exit 0
}

MAX_ATTEMPTS=90
SLEEP_TIME=2

mongod_config_file="/etc/mongod.conf"
dbpath="/var/lib/mongodb/data"

# Change config file according MONGODB_CONFIGURE_* variables
for x in $(set | grep MONGOD_CONFIG); do
    option=$(echo $x | sed -r -e 's|MONGOD_CONFIG_||' | tr '[:upper:]' '[:lower:]')
    option_name=$(echo $option | sed -r -e 's|(.*)=.*|\1|')
    sed -i -e "/^$option_name/d" $mongod_config_file
    echo $option >> $mongod_config_file
    if [ $option_name = "dbpath"]; then
        dbpath=$option_name
    fi
done

trap 'cleanup' SIGINT SIGTERM

# Run scripts before mongod start
source_scripts mongodb pre-initdb

# Add default config file
mongo_common_args="-f $mongod_config_file "
mongo_local_args="--bind_ip localhost "

# Start background MongoDB service with disabled authentication
mongod $mongo_common_args $mongo_local_args &
wait_mongo "UP"

# Run scripts with started mongod
source_scripts mongodb initdb

# Stop background MongoDB service to exec mongod
mongod $mongo_common_args $mongo_local_args --shutdown
wait_mongo "DOWN"

# Run scripts after mongod stoped
source_scripts mongodb post-initdb

# Start MongoDB service with enabled authentication
exec mongod  $mongo_common_args
