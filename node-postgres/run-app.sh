#!/bin/bash
set -e

echo "Installing node-postgres smart driver package"

npm install @yugabytedb/pg

echo "Installing node-postgres smart driver pool package"

npm install @yugabytedb/pg-pool

DIR="driver-examples"
if [ -d "$DIR" ]; then
 echo "driver-examples repository is already present"
 cd driver-examples
 git checkout main
 git pull
else
 echo "Cloning the driver examples repository"
 git clone git@github.com:yugabyte/driver-examples.git
 cd driver-examples
fi

cd nodejs
npm install

echo "Exporting environment variable YB_PATH with the value of the path of the YugabyteDB installation directory."

export YB_PATH="$YUGABYTE_HOME_DIRECTORY"

echo "Running tests"

node yb-fallback-star-1.js > $ARTIFACTS_PATH/yb-fallback-star-1.txt

if [ $(grep -c "Test Completed" $ARTIFACTS_PATH/yb-fallback-star-1.txt) -eq 0 ]
then
  echo "yb-fallback-star-1 failed"
  cat $ARTIFACTS_PATH/yb-fallback-star-1.txt
else
  echo "Test 1 (yb-fallback-star-1) completed"
fi

node yb-fallback-star-2.js > $ARTIFACTS_PATH/yb-fallback-star-2.txt

if [ $(grep -c "Test Completed" $ARTIFACTS_PATH/yb-fallback-star-2.txt) -eq 0 ]
then
  echo "yyb-fallback-star-2 failed"
  cat $ARTIFACTS_PATH/yb-fallback-star-2.txt
else
  echo "Test 2 (yb-fallback-star-2) completed"
fi

node yb-fallback-topology-aware-1 > $ARTIFACTS_PATH/yb-fallback-topology-aware-1.txt

if [ $(grep -c "Test Completed" $ARTIFACTS_PATH/yb-fallback-topology-aware-1.txt) -eq 0 ]
then
  echo "yb-fallback-topology-aware-1 failed"
  cat $ARTIFACTS_PATH/yb-fallback-topology-aware-1.txt
else
  echo "Test 3 (yb-fallback-topology-aware-1) completed"
fi

node yb-fallback-topology-aware-2.js > $ARTIFACTS_PATH/yb-fallback-topology-aware-2.txt

if [ $(grep -c "Test Completed" $ARTIFACTS_PATH/yb-fallback-topology-aware-2.txt) -eq 0 ]
then
  echo "yb-fallback-topology-aware-2 failed"
  cat $ARTIFACTS_PATH/yb-fallback-topology-aware-2.txt
else
  echo "Test 4 (yb-fallback-topology-aware-2) completed"
fi

node yb-fallback-topology-aware-3.js > $ARTIFACTS_PATH/yb-fallback-topology-aware-3.txt

if [ $(grep -c "Test Completed" $ARTIFACTS_PATH/yb-fallback-topology-aware-3.txt) -eq 0 ]
then
  echo "yb-fallback-topology-aware-3 failed"
  cat $ARTIFACTS_PATH/yb-fallback-topology-aware-3.txt
else
  echo "Test 5 (yb-fallback-topology-aware-3) completed"
fi

node yb-load-balance-with-add-node.js > $ARTIFACTS_PATH/yb-load-balance-with-add-node.txt

if [ $(grep -c "Test Completed" $ARTIFACTS_PATH/yb-load-balance-with-add-node.txt) -eq 0 ]
then
  echo "yb-load-balance-with-add-node failed"
  cat $ARTIFACTS_PATH/yb-load-balance-with-add-node.txt
else
  echo "Test 6 (yb-load-balance-with-add-node) completed"
fi

node yb-load-balance-with-stop-node.js > $ARTIFACTS_PATH/yb-load-balance-with-stop-node.txt

if [ $(grep -c "Test Completed" $ARTIFACTS_PATH/yb-load-balance-with-stop-node.txt) -eq 0 ]
then
  echo "yb-load-balance-with-stop-node failed"
  cat $ARTIFACTS_PATH/yb-load-balance-with-stop-node.txt
else
  echo "Test 7 (yb-load-balance-with-stop-node) completed"
fi

node yb-pooling-with-load-balance.js > $ARTIFACTS_PATH/yb-pooling-with-load-balance.txt

if [ $(grep -c "Test Completed" $ARTIFACTS_PATH/yb-pooling-with-load-balance.txt) -eq 0 ]
then
  echo "yb-pooling-with-load-balance failed"
  cat $ARTIFACTS_PATH/yb-pooling-with-load-balance.txt
else
  echo "Test 8 (yb-pooling-with-load-balance) completed"
fi

node yb-pooling-with-topology-aware.js > $ARTIFACTS_PATH/yb-pooling-with-topology-aware.txt

if [ $(grep -c "Test Completed" $ARTIFACTS_PATH/yb-pooling-with-topology-aware.txt) -eq 0 ]
then
  echo "yb-pooling-with-topology-aware failed"
  cat $ARTIFACTS_PATH/yb-pooling-with-topology-aware.txt
else
  echo "Test 9 (yb-pooling-with-topology-aware) completed"
fi

node yb-topology-aware-with-add-node.js > $ARTIFACTS_PATH/yb-topology-aware-with-add-node.txt

if [ $(grep -c "Test Completed" $ARTIFACTS_PATH/yb-topology-aware-with-add-node.txt) -eq 0 ]
then
  echo "yb-topology-aware-with-add-node failed"
  cat $ARTIFACTS_PATH/yb-topology-aware-with-add-node.txt
else
  echo "Test 10 (yb-topology-aware-with-add-node) completed"
fi

node yb-topology-aware-with-stop-node.js > $ARTIFACTS_PATH/yb-topology-aware-with-stop-node.txt

if [ $(grep -c "Test Completed" $ARTIFACTS_PATH/yb-topology-aware-with-stop-node.txt) -eq 0 ]
then
  echo "yb-topology-aware-with-stop-node failed"
  cat $ARTIFACTS_PATH/yb-topology-aware-with-stop-node.txt
else
  echo "Test 11 (yb-topology-aware-with-stop-node) completed"
fi

grep "Test Completed" $ARTIFACTS_PATH/yb-fallback-star-1.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-fallback-star-2.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-fallback-topology-aware-1.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-fallback-topology-aware-2.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-fallback-topology-aware-3.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-load-balance-with-add-node.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-load-balance-with-stop-node.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-pooling-with-load-balance.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-pooling-with-topology-aware.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-topology-aware-with-add-node.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-topology-aware-with-stop-node.txt