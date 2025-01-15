#!/bin/bash

# Debugging on part(s) of the script
# set +x

# Parse command line options and arguments
OPTSTRING=":i:w:l:r:p:"

while getopts ${OPTSTRING} option; do
    case "${option}" in
    i) QUICKWP_URL=${OPTARG} ;;
    w) QUICKWP_PLUGINS=${OPTARG} ;;
    l) QUICKWP_LOCALE=${OPTARG} ;;
    r) QUICKWP_REINSTALL=${OPTARG} ;;
    p) QUICKWP_PORT=${OPTARG} ;;
    esac
done

# Set default ip if no commandline parameter given
if [ -z "$QUICKWP_URL" ]; then
    QUICKWP_URL=quickwp.stageserver4.men
fi

# Set default locale if no commandline parameter given
if [ -z "$QUICKWP_LOCALE" ]; then
    QUICKWP_LOCALE=en_US
fi

# Set reinstall default to yes
if [ -z "$QUICKWP_REINSTALL" ]; then
    QUICKWP_REINSTALL=yes
else
    QUICKWP_REINSTALL=no
fi

# Set the default forwarding port for Wordpress if no commandline parameter given
if [ -z "$QUICKWP_PORT" ]; then
    QUICKWP_PORT=
fi

{
    echo "QUICKWP_URL=$QUICKWP_URL"
    echo "QUICKWP_PLUGINS=$QUICKWP_PLUGINS"
    echo "QUICKWP_LOCALE=$QUICKWP_LOCALE"
    echo "QUICKWP_REINSTALL=$QUICKWP_REINSTALL"
    echo "QUICKWP_PORT=$QUICKWP_PORT"
} >./.env

# Reset the installation.
docker stop quickwp && docker rm quickwp && docker rmi -f quickwp_www
echo "Reseting installation ..."
rm -rf ./mysql-database/*
rm -rf ./public_html/*
rm -rf ./log/*
docker compose up --build --force-recreate -d

# tail -f log/entrypoint.log
