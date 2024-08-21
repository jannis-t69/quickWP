#!/bin/bash

echo "Cleaning up WordPress..."
rm -rf ./mysql-data/*
rm -rf ./public/*

# Remove container and image files
docker stop instantwp && docker rm $_ && docker rmi -f instantwp_web