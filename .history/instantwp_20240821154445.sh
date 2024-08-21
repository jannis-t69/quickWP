#!/bin/bash

function installwp {
# Capture url parameters from arguments.
while getopts u:p:l: option
do
    case "${option}"
    in
    u) INSTANTWP_URL=${OPTARG};;
    p) INSTANTWP_PLUGINS=${OPTARG};;
    l) INSTANTWP_LOCALE=${OPTARG};;
    esac
done

# If we dont have a locale set from above, default to Finnish
if [ -z "$INSTANTWP_LOCALE" ]; then
    INSTANTWP_LOCALE=en_US
fi

# If domain us not set default to local ip
if [ -z "$INSTANTWP_URL" ]; then
    INSTANTWP_URL=192.168.2.5
fi

export INSTANTWP_URL=$INSTANTWP_URL
export INSTANTWP_PLUGINS=$INSTANTWP_PLUGINS
export INSTANTWP_LOCALE=$INSTANTWP_LOCALE

# docker stop instantwp

docker compose up --build --force-recreate -d
}
 Remove container


# Handle cleanup command.
# if [ "$1" = "clean" ]; then
    echo "Cleaning up WordPress..."
    rm -rf ./mysql-data/*
    rm -rf ./public/*
#   exit
# fi