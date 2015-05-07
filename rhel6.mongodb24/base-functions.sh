MAX_ATTEMPTS=90
SLEEP_TIME=2

# Wait_mongo waits until the mongo server is up/down
function wait_mongo() {
    operation=-eq
    if [ $1 = "DOWN" -o $1 = "down" ]; then
        operation=-ne
    fi

    local mongo_cmd="mongo admin --host ${2:-localhost:$port} "

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
    return 1
}

# Get option for parametr $1 in $2 file
function get_option() {
    [ -z "$1" -o -z "$2" -o ! -r "$2" ] && return 1

    grep "^\s*$1" $2 | sed -r -e "s|^\s*$1\s*=\s*||"
}

# Get port number from $1 file
function get_port() {
    [ -z "$1" -o ! -r "$1" ] && return 1

    if grep '^\s*port' $1 &>/dev/null; then
        grep '^\s*port' $1 | sed -r -e 's|^\s*port\s*=\s*(\d*)|\1|'
    elif grep '^\s*configsvr' $1 &>/dev/null; then
        echo 27019
    elif grep '^\s*shardsvr' $1 &>/dev/null; then
        echo 27018
    else
        echo ""
    fi
}

# Change config file $2 according environment variables with prefix $1
function update_conf() {
    [ -z "$1" -o -z "$2" -o ! -r "$2" ] && return 1

    for option in $(set | grep $1 | sed -r -e "s|$1||"); do
        # Delete old option from config file
        option_name=$(echo $option | sed -r -e 's|(\w*)=.*|\1|')
        sed -r -e "/^$option_name/d" $2 > $HOME/.tmp.conf
        cat $HOME/.tmp.conf > $2
        rm $HOME/.tmp.conf
        # Add new option into config file
        echo $option >> $2
    done
}
