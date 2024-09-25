#!/bin/bash
set -e

DIR="driver-examples"
if [ -d "$DIR" ]; then
  echo "driver-examples repository is already present"
  cd $DIR
  git checkout main
  git pull
else
  echo "Cloning the driver-examples repository ..."
  git clone git@github.com:yugabyte/driver-examples.git && cd driver-examples
fi

cd java/ysql-jdbc

echo "Compiling the YSQL JDBC tests ..."
mvn clean compile

echo "Running LoadBalanceConcurrencyExample ..."
YBDB_PATH=$YUGABYTE_HOME_DIRECTORY mvn exec:java -Dexec.mainClass=com.yugabyte.ysql.LoadBalanceConcurrencyExample 2>&1 | tee jdbc-concurrency.log

echo "Running TopologyAwareLBFallbackExample ..."
YBDB_PATH=$YUGABYTE_HOME_DIRECTORY mvn exec:java -Dexec.mainClass=com.yugabyte.ysql.TopologyAwareLBFallbackExample 2>&1 | tee jdbc-fallback.log

echo "Running TopologyAwareLBFallback2Example ..."
YBDB_PATH=$YUGABYTE_HOME_DIRECTORY mvn exec:java -Dexec.mainClass=com.yugabyte.ysql.TopologyAwareLBFallback2Example 2>&1 | tee jdbc-fallback2.log

echo "Running ReadReplicaSupportExample..."
YBDB_PATH=$YUGABYTE_HOME_DIRECTORY mvn exec:java -Dexec.mainClass=com.yugabyte.ysql.ReadReplicaSupportExample 2>&1 | tee read-replica.log

echo "Running ReadReplicaSupportHikariExample..."
YBDB_PATH=$YUGABYTE_HOME_DIRECTORY mvn exec:java -Dexec.mainClass=com.yugabyte.ysql.ReadReplicaSupportHikariExample 2>&1 | tee read-replica-hikari.log

RESULT=0

if ! grep "BUILD SUCCESS" jdbc-concurrency.log; then
 echo "LoadBalanceConcurrencyExample failed!"
 RESULT=1
fi

if ! grep "BUILD SUCCESS" jdbc-fallback.log; then
 echo "TopologyAwareLBFallbackExample failed!"
 RESULT=1
fi

if ! grep "BUILD SUCCESS" jdbc-fallback2.log; then
 echo "TopologyAwareLBFallback2Example failed!"
 RESULT=1
fi

if ! grep "BUILD SUCCESS" read-replica.log; then
 echo "ReadReplicaSupportExample failed!"
 RESULT=1
fi

if ! grep "BUILD SUCCESS" read-replica-hikari.log; then
 echo "ReadReplicaSupportHikariExample failed!"
 RESULT=1
fi

exit $RESULT

