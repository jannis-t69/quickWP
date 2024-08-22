#!/bin/bash

    echo "Reseting installation ..."
    rm -rf ./mysql-database/*
    rm -rf ./public_html/*
    rm -rf ./public_html/*

# Remove container and image files
docker stop quickwp && docker rm $_ && docker rmi -f quickwp_www