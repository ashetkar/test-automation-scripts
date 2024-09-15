#!/bin/bash

# Stop all the docker containers
docker stop $(docker ps -a -q)

# Remove all the docker containers
docker rm $(docker ps -a -q)