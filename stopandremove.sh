#!/bin/bash

# Remove container
docker stop instantwp && docker rm $_ && docker rmi -f instantwp_web