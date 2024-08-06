#!/bin/bash
set -e

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

cd go/pgx
rm -f go.mod
rm -f go.sum
go mod init main
go mod tidy

echo "Building the example"

go build ybsql_load_balance.go ybsql_load_balance_pool.go ybsql_fallback.go performance_test_parallel.go performace_test_sequential.go

echo "Running tests"

./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY > $ARTIFACTS_PATH/pgx_connect.txt

./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY --pool > $ARTIFACTS_PATH/pgxpool_connect.txt

./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY --fallbackTest 1 > $ARTIFACTS_PATH/pgx_fallback1.txt

./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY --fallbackTest 2 > $ARTIFACTS_PATH/pgx_fallback2.txt

./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY --fallbackTest 3 > $ARTIFACTS_PATH/pgx_fallback3.txt

grep "Closing the application ..." $ARTIFACTS_PATH/pgx_connect.txt

grep "Closing the application ..." $ARTIFACTS_PATH/pgxpool_connect.txt

grep "End of checkNodeDownBehaviorMultiFallback() ..." $ARTIFACTS_PATH/pgx_fallback1.txt

grep "End of checkMultiNodeDown() ..." $ARTIFACTS_PATH/pgx_fallback2.txt

grep "End of checkNodeDownPrimary() ..." $ARTIFACTS_PATH/pgx_fallback3.txt
