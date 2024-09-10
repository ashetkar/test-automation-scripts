#!/bin/bash
set -e

DIR="flyway-tests"
if [ -d "$DIR" ]; then
 echo "$DIR repository is already present"
else
 echo "Cloning the $DIR repository"
 git clone "git@github.com:yugabyte/$DIR.git"
fi

cd $DIR
git checkout restructure-dir # todo change to main
git pull

echo "Building and running the tests..."

export YBDB_PATH=$YUGABYTE_HOME_DIRECTORY

JAVA_HOME=/usr/lib/jvm/zulu-17.jdk mvn clean test

