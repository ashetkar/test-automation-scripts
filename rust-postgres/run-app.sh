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

cd rust/rust_ysql

echo "Building the example"

cargo build

echo "Exporting environment variable YB_PATH with the value of the path of the YugabyteDB installation directory."

export YB_PATH="$YUGABYTE_HOME_DIRECTORY"

echo "Running examples"

cargo run --bin ybsql_load_balance 2>&1 | tee $ARTIFACTS_PATH/rust_ybsql_load_balance.txt

echo "Example 1 (ybsql_load_balance) completed"

cargo run --bin ybsql_fallback_example1 2>&1 | tee $ARTIFACTS_PATH/rust_ybsql_fallback_example1.txt

echo "Example 2 (ybsql_fallback_example1) completed"

cargo run --bin ybsql_fallback_example2 2>&1 | tee $ARTIFACTS_PATH/rust_ybsql_fallback_example2.txt

echo "Example 3 (ybsql_fallback_example2) completed"

cargo run --bin ybsql_fallback_example3 2>&1 | tee $ARTIFACTS_PATH/rust_ybsql_fallback_example3.txt

echo "Example 4 (ybsql_fallback_example3) completed"

cargo run --bin ulb_multithread 2>&1 | tee $ARTIFACTS_PATH/rust_ulb_multithread.txt

echo "Example 5 (ulb_multithread) completed"

cargo run --bin talb_multithread 2>&1 | tee $ARTIFACTS_PATH/rust_talb_multithread.txt

echo "Example 6 (talb_multithread) completed"

grep "End of Example" $ARTIFACTS_PATH/rust_ybsql_load_balance.txt

grep "End of Example" $ARTIFACTS_PATH/rust_ybsql_fallback_example1.txt

grep "End of Example" $ARTIFACTS_PATH/rust_ybsql_fallback_example2.txt

grep "End of Example" $ARTIFACTS_PATH/rust_ybsql_fallback_example3.txt

grep "End of Example" $ARTIFACTS_PATH/rust_ulb_multithread.txt

grep "End of Example" $ARTIFACTS_PATH/rust_talb_multithread.txt