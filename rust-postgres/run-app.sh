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

cargo run --bin ybsql_load_balance > $ARTIFACTS_PATH/rust_ybsql_load_balance.txt 2>&1

echo "Example 1 (ybsql_load_balance) completed"

cargo run --bin ybsql_fallback_example1 > $ARTIFACTS_PATH/rust_ybsql_fallback_example1.txt 2>&1

echo "Example 2 (ybsql_fallback_example1) completed"

cargo run --bin ybsql_fallback_example2 > $ARTIFACTS_PATH/rust_ybsql_fallback_example2.txt 2>&1

echo "Example 3 (ybsql_fallback_example2) completed"

cargo run --bin ybsql_fallback_example3 > $ARTIFACTS_PATH/rust_ybsql_fallback_example3.txt 2>&1

echo "Example 4 (ybsql_fallback_example3) completed"

cargo run --bin ulb_multithread > $ARTIFACTS_PATH/rust_ulb_multithread.txt 2>&1

echo "Example 5 (ulb_multithread) completed"

cargo run --bin talb_multithread > $ARTIFACTS_PATH/rust_talb_multithread.txt 2>&1

echo "Example 6 (talb_multithread) completed"

grep "End of Example" $ARTIFACTS_PATH/rust_ybsql_load_balance.txt

grep "End of Example" $ARTIFACTS_PATH/rust_ybsql_fallback_example1.txt

grep "End of Example" $ARTIFACTS_PATH/rust_ybsql_fallback_example2.txt

grep "End of Example" $ARTIFACTS_PATH/rust_ybsql_fallback_example3.txt

grep "End of Example" $ARTIFACTS_PATH/rust_ulb_multithread.txt

grep "End of Example" $ARTIFACTS_PATH/rust_talb_multithread.txt