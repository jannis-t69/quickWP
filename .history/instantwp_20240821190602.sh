#!/bin/bash
# set -x
function installwp {
docker compose up --build --force-recreate -d
}

# Capture url parameters from arguments.
OPTSTRING=":ip:pl:lo:r:p:"

while getopts ${OPTSTRING} option
do
    case "${option}" in
    ip) INSTANTWP_URL=${OPTARG};;
    pl) INSTANTWP_PLUGINS=${OPTARG};;
    lo) INSTANTWP_LOCALE=${OPTARG};;
    r) INSTANTWP_REINSTALL=${OPTARG};;
    p) INSTANTWP_PORT=${OPTARG};;
    esac
done

# If domain us not set default to local ip
if [ -z "$INSTANTWP_URL" ]
then
    INSTANTWP_URL=192.168.2.0
fi
# If we dont have a locale set from above, default to Finnish
if [ -z "$INSTANTWP_LOCALE" ]
then
    INSTANTWP_LOCALE=en_US
fi


# If reinstall set the config
if [ -z "$INSTANTWP_REINSTALL" ]
then
    INSTANTWP_REINSTALL=yes
else
    INSTANTWP_REINSTALL=no
fi

# Set the default forwarding port for Wordpress
if [ -z "$INSTANTWP_PORT" ]
then
    INSTANTWP_PORT=6080
fi

export INSTANTWP_URL=$INSTANTWP_URL
export INSTANTWP_PLUGINS=$INSTANTWP_PLUGINS
export INSTANTWP_LOCALE=$INSTANTWP_LOCALE
export INSTANTWP_REINSTALL=$INSTANTWP_REINSTALL
export INSTANTWP_PORT=$INSTANTWP_PORT

# Reset the installation.
if [ "$INSTANTWP_REINSTALL" = no ]
then
    docker stop instantwp
    installwp
    exit
else
    docker stop instantwp && docker rm instantwp && docker rmi -f instantwp_web
    echo "Cleaning up WordPress..."
    rm -rf ./mysql-data/*
    rm -rf ./public/*
    installwp
    exit
fi
