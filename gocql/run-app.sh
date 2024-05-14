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

go test -v > $ARTIFACTS_PATH/gocql-TestGetKey-output.txt

# Allow some time for server init
sleep 10

echo "Checking the gocql test reports"
if [ $(grep -c "FAIL" $ARTIFACTS_PATH/gocql-TestGetKey-output.txt) -ne 0 ]
then
  cat $ARTIFACTS_PATH/gocql-TestGetKey-output.txt
fi

! grep "FAIL" $ARTIFACTS_PATH/gocql-TestGetKey-output.txt
