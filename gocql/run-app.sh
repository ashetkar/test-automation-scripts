#!/bin/bash
set -e

DIR="gocql"
if [ -d "$DIR" ]; then
 echo "gocql repository is already present"
 cd gocql
 git checkout master
 git pull
else
 echo "Cloning the gocql repository"
 git clone git@github.com:yugabyte/gocql.git
 cd gocql
fi

echo "Running tests"

go clean -testcache

go test -v