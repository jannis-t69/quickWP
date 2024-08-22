#!/bin/bash

    echo "Reseting installation ..."
    rm -rf ./mysql-database/*
    rm -rf ./public_html/*

# Remove container and image files
docker stop instantwp && docker rm $_ && docker rmi -f instantwp_web