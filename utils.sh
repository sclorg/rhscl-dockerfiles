#!/usr/bin/env bash

function print_result {
    local RESET='\e[0m'
    local RED='\e[0;31m'
    local GREEN='\e[0;32m'
    local YELLOW='\e[1;33m'
    local PASS="${RESET}${GREEN}[PASS]"
    local FAIL="${RESET}${RED}[FAIL]"
    local WORKING="${RESET}${YELLOW}[....]"
    local STATUS="$1"
    shift

    if [ "${STATUS}" = pass ]; then
        echo -en "${PASS}"
    elif [ "${STATUS}" = fail ]; then
        echo -en "${FAIL}"
    elif [ "${STATUS}" = working ]; then
        echo -en "${WORKING}"
    else
        return
    fi

    echo -en " ${@}${RESET}"
    echo
}

function get_status {
    if [ "$1" = "$2" ]; then
        echo pass
    else
        echo fail
    fi
}

function run_command {
    local cmd="$1"
    local expected="${2:-0}"
    local msg="${3:-Running command '$cmd'}"
    print_result working "$msg"
    eval $cmd
    local res="$?"
    status=`get_status "$res" "$expected"`
    print_result "$status" "$msg"
    return "$res"
}
