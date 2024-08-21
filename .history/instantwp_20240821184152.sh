#!/bin/bash
# set -x
function installwp {

export INSTANTWP_URL=$INSTANTWP_URL
export INSTANTWP_PLUGINS=$INSTANTWP_PLUGINS
export INSTANTWP_LOCALE=$INSTANTWP_LOCALE
export INSTANTWP_REINSTALL=$INSTANTWP_REINSTALL

docker compose up --build --force-recreate -d
}

# Capture url parameters from arguments.
OPTSTRING=":ip:pl:l:r:"

while getopts ${OPTSTRING} option
do
    case "${option}" in
    ip) INSTANTWP_URL=${OPTARG};;
    pl) INSTANTWP_PLUGINS=${OPTARG};;
    lo) INSTANTWP_LOCALE=${OPTARG};;
    r) INSTANTWP_REINSTALL=${OPTARG};;
    esac
done

# If we dont have a locale set from above, default to Finnish
if [ -z "$INSTANTWP_LOCALE" ]
then
    echo $INSTANTWP_LOCALE
    INSTANTWP_LOCALE=en_US
fi

# If domain us not set default to local ip
if [ -z "$INSTANTWP_URL" ]
then
    INSTANTWP_URL=192.168.2.5
fi

# If reinstall set the config
if [ -z "$INSTANTWP_REINSTALL" ]
then
    echo $INSTANTWP_REINSTALL
    INSTANTWP_REINSTALL=yes
else
    echo $INSTANTWP_REINSTALL
    INSTANTWP_REINSTALL=no
fi
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
