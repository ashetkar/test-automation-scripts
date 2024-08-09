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

echo "Test 1 (yb-fallback-star-1) completed"

node yb-fallback-star-2.js > $ARTIFACTS_PATH/yb-fallback-star-2.txt

echo "Test 2 (yb-fallback-star-2) completed"

node yb-fallback-test-1.js > $ARTIFACTS_PATH/yb-fallback-test-1.txt

echo "Test 3 (yb-fallback-test-1) completed"

node yb-fallback-test-2.js > $ARTIFACTS_PATH/yb-fallback-test-2.txt

echo "Test 4 (yb-fallback-test-2) completed"

node yb-fallback-test-2.js > $ARTIFACTS_PATH/yb-fallback-test-3.txt

echo "Test 5 (yb-fallback-test-2) completed"

node yb-fallback-topology-aware-1 > $ARTIFACTS_PATH/yb-fallback-topology-aware-1.txt

echo "Test 6 (yb-fallback-topology-aware-1) completed"

node yb-fallback-topology-aware-2.js > $ARTIFACTS_PATH/yb-fallback-topology-aware-2.txt

echo "Test 7 (yb-fallback-topology-aware-2) completed"

node yb-fallback-topology-aware-3.js > $ARTIFACTS_PATH/yb-fallback-topology-aware-3.txt

echo "Test 8 (yb-fallback-topology-aware-3) completed"

node yb-load-balance-with-add-node.js > $ARTIFACTS_PATH/yb-load-balance-with-add-node.txt

echo "Test 9 (yb-load-balance-with-add-node) completed"

node yb-load-balance-with-stop-node.js > $ARTIFACTS_PATH/yb-load-balance-with-stop-node.txt

echo "Test 10 (yb-load-balance-with-stop-node) completed"

node yb-pooling-with-load-balance.js > $ARTIFACTS_PATH/yb-pooling-with-load-balance.txt

echo "Test 11 (yb-pooling-with-load-balance) completed"

node yb-pooling-with-topology-aware.js > $ARTIFACTS_PATH/yb-pooling-with-topology-aware.txt

echo "Test 12 (yb-pooling-with-topology-aware) completed"

node yb-topology-aware-with-add-node.js > $ARTIFACTS_PATH/yb-topology-aware-with-add-node.txt

echo "Test 13 (yb-topology-aware-with-add-node) completed"

node yb-topology-aware-with-stop-node.js > $ARTIFACTS_PATH/yb-topology-aware-with-stop-node.txt

echo "Test 14 (yb-topology-aware-with-stop-node) completed"

grep "Test Completed" $ARTIFACTS_PATH/yb-fallback-star-1.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-fallback-star-2.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-fallback-test-1.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-fallback-test-2.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-fallback-test-3.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-fallback-topology-aware-1.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-fallback-topology-aware-2.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-fallback-topology-aware-3.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-load-balance-with-add-node.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-load-balance-with-stop-node.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-pooling-with-load-balance.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-pooling-with-topology-aware.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-topology-aware-with-add-node.txt

grep "Test Completed" $ARTIFACTS_PATH/yb-topology-aware-with-stop-node.txt