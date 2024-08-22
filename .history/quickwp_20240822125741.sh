#!/bin/bash
# set +x
# Capture url parameters from arguments.
OPTSTRING=":i:w:l:r:p:"

while getopts ${OPTSTRING} option
do
    case "${option}" in
    i) QUICKWP_URL=${OPTARG};;
    w) QUICKWP_PLUGINS=${OPTARG};;
    l) QUICKWP_LOCALE=${OPTARG};;
    r) QUICKWP_REINSTALL=${OPTARG};;
    p) QUICKWP_PORT=${OPTARG};;
    esac
done

# If domain us not set default to local ip
if [ -z "$QUICKWP_URL" ]
then
    QUICKWP_URL=192.168.2.5
fi

# If we dont have a locale set from above, default to Finnish
if [ -z "$QUICKWP_LOCALE" ]
then
    QUICKWP_LOCALE=en_US
fi

# If reinstall set the config
if [ -z "$QUICKWP_REINSTALL" ]
then
    QUICKWP_REINSTALL=yes
else
    QUICKWP_REINSTALL=no
fi

# Set the default forwarding port for Wordpress
if [ -z "$QUICKWP_PORT" ]
then
    QUICKWP_PORT=6080
fi

{
echo "QUICKWP_URL=$QUICKWP_URL"
echo "QUICKWP_PLUGINS=$QUICKWP_PLUGINS"
echo "QUICKWP_LOCALE=$QUICKWP_LOCALE"
echo "QUICKWP_REINSTALL=$QUICKWP_REINSTALL"
echo "QUICKWP_PORT=$QUICKWP_PORT"
} > ./.env

# export QUICKWP_URL=$QUICKWP_URL
# export QUICKWP_PLUGINS=$QUICKWP_PLUGINS
# export QUICKWP_LOCALE=$QUICKWP_LOCALE
# export QUICKWP_REINSTALL=$QUICKWP_REINSTALL
# export QUICKWP_PORT=$QUICKWP_PORT

# Reset the installation.
if [ "$QUICKWP_REINSTALL" = no ]
then
    docker stop QUICKWP
    docker compose up --build --force-recreate --project-name -d
    exit
else
    docker stop QUICKWP && docker rm QUICKWP && docker rmi -f QUICKWP_web
    echo "Cleaning up WordPress..."
    rm -rf ./mysql-data/*
    rm -rf ./public/*
    docker compose up --build --force-recreate -d
    exit
fi
