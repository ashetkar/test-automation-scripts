#!/bin/bash
set -e

DIR="driver-examples"
REPORT_FILE="$WORKSPACE/artifacts/test_report_pgx.json"
OVERALL_STATUS=0

# Function to run individual test cases and capture their results
run_test() {
    local test_name=$1
    local test_num=$2
    local message=$3
    local script_name=$4
    echo "Running $test_name from $script_name..."

    # Run the specific test case and capture errors
    if [ $test_num -eq 4 ]; then
        test_name="load_balance"
        ./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY 2>&1 | tee ${test_name}.log
    elif [ $test_num -eq 0 ]; then
        ./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY --pool 2>&1 | tee ${test_name}.log
    else
        ./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY "--$test_name" "$test_num" 2>&1 | tee ${test_name}.log
    fi
    if ! grep "$message" ${test_name}.log; then
      tail -n 30 ${test_name}.log | awk '{printf "%s\\n", $0}' > stack4json.log
      echo "{ \"test_name\": \"$test_name\", \"script_name\": \"$script_name.py\", \"result\": \"FAILED\", \"error_stack\": \"$(cat stack4json.log)\" }," >> temp_report.json
      OVERALL_STATUS=1
    else
      echo "Example $test_name completed"
      echo "{ \"test_name\": \"$test_name\", \"script_name\": \"$script_name\", \"result\": \"PASSED\", \"error_stack\": \"\" }," >> temp_report.json
    fi
}

# Clone or update the repository
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

go build ybsql_load_balance.go ybsql_load_balance_pool.go ybsql_fallback.go performance_test_parallel.go performace_test_sequential.go ybsql_read_replica1.go ybsql_read_replica2.go

echo "Running tests"

# Initialize the JSON report
echo "[" > temp_report.json

run_test " " "4" "Closing the application ..." "pgx/start.sh"

run_test "pool" "0" "Closing the application ..." "pgx/start.sh"

run_test "fallbackTest" "1" "End of checkNodeDownBehaviorMultiFallback() ..." "pgx/start.sh"

run_test "fallbackTest" "2" "End of checkMultiNodeDown() ..." "pgx/start.sh"

run_test "fallbackTest" "3" "End of checkNodeDownPrimary() ..." "pgx/start.sh"

# Finalize the JSON report
sed -i '$ s/,$//' temp_report.json # Remove trailing comma from the last JSON object
echo "]" >> temp_report.json

# Move the temporary report to the final report file
mv temp_report.json "$REPORT_FILE"

# Display the JSON report
echo "TEST REPORT -------------------------"
cat "$REPORT_FILE"

readlink -f "$REPORT_FILE"

# Exit with the overall status
exit $OVERALL_STATUS