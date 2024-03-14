#!/bin/bash
set -e

DIR="driver-examples"
if [ -d "$DIR" ]; then
  echo "driver-examples repository is already present"
  cd $DIR
  git checkout master
  git pull
else
  echo "Cloning the driver-examples repository ..."
  git clone git@github.com:yugabyte/driver-examples.git && cd driver-examples
fi

cd java/ysql-jdbc

echo "Compiling the YSQL JDBC tests ..."
mvn compile

echo "Running LoadBalanceConcurrencyExample ..."
YBDB_PATH=<path/to/yugabytedb/installation/directory> mvn exec:java -Dexec.mainClass=com.yugabyte.examples.LoadBalanceConcurrencyExample > $ARTIFACTS_PATH/jdbc-concurrency.log

echo "Running TopologyAwareLBFallbackExample ..."
YBDB_PATH=<path/to/yugabytedb/installation/directory> mvn exec:java -Dexec.mainClass=com.yugabyte.examples.TopologyAwareLBFallbackExample > $ARTIFACTS_PATH/jdbc-fallback.log

echo "Running TopologyAwareLBFallback2Example ..."
YBDB_PATH=<path/to/yugabytedb/installation/directory> mvn exec:java -Dexec.mainClass=com.yugabyte.examples.TopologyAwareLBFallback2Example > $ARTIFACTS_PATH/jdbc-fallback2.log

grep "" $ARTIFACTS_PATH/jdbc-concurrency.log

grep "" $ARTIFACTS_PATH/jdbc-fallback.log

grep "" $ARTIFACTS_PATH/jdbc-fallback2.log

