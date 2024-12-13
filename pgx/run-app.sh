#!/bin/bash
set -e

DIR="driver-examples"
REPORT_FILE="$WORKSPACE/artifacts/test_report_pgx.json"
OVERALL_STATUS=0

# Function to run individual test cases and capture their results
run_test() {
    local test_name=$1
    local tc_name=$2
    local message=$3
    local script_name=$4

    # Run the specific test case and capture errors
    if [ $tc_name == "basic" ]; then
        test_name="load_balance"
        echo "Running ybsql_load_balance from $script_name..."
        ./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY 2>&1 | tee ${test_name}_${tc_name}.log
    elif [ $tc_name == "pool" ]; then
        tc_name="test"
        echo "Running pool example from $script_name..."
        ./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY --pool 2>&1 | tee ${test_name}_${tc_name}.log
    else
        echo "Running ${test_name}_${tc_name} from $script_name..."
        ./ybsql_load_balance $YUGABYTE_HOME_DIRECTORY "--$test_name" "$tc_name" 2>&1 | tee ${test_name}_${tc_name}.log
    fi
    if ! grep "$message" ${test_name}_${tc_name}.log; then
      tail -n 30 ${test_name}_${tc_name}.log > stack4json.log
      local tname="${test_name}_${tc_name}"
      python $WORKSPACE/integrations/utils/create_json.py --test_name $tname --script_name $script_name --result FAILED --file_path stack4json.log >> temp_report.json
      OVERALL_STATUS=1
    else
      local tname="${test_name}_${tc_name}"
      echo "Example $tname completed"
      python $WORKSPACE/integrations/utils/create_json.py --test_name $tname --script_name $script_name --result PASSED >> temp_report.json
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

go build ybsql_load_balance.go ybsql_load_balance_pool.go ybsql_fallback.go performance_test_parallel.go performace_test_sequential.go ybsql_read_replica1.go ybsql_read_replica2.go multiple_pool_example.go

echo "Running tests"

# Initialize the JSON report
echo "[" > temp_report.json

run_test " " "basic" "Closing the application ..." "pgx/start.sh"

run_test "pool" "pool" "Closing the application ..." "pgx/start.sh"

run_test "fallbackTest" "checkNodeDownBehaviorMultiFallback" "End of checkNodeDownBehaviorMultiFallback() ..." "pgx/start.sh"

run_test "fallbackTest" "checkMultiNodeDown" "End of checkMultiNodeDown() ..." "pgx/start.sh"

run_test "fallbackTest" "checkNodeDownPrimary" "End of checkNodeDownPrimary() ..." "pgx/start.sh"

run_test "rr" "clusterAwareRRTest" "Closing the application ..." "pgx/start.sh"

run_test "rr" "topologyAwareRRTest" "Closing the application ..." "pgx/start.sh"

# Finalize the JSON report
sed -i '$ s/,$//' temp_report.json # Remove trailing comma from the last JSON object
echo "]" >> temp_report.json
sed -i 's/\t/    /g' temp_report.json # Replace tabs with spaces

# Move the temporary report to the final report file
mv temp_report.json "$REPORT_FILE"

# Display the JSON report
echo "TEST REPORT -------------------------"
cat "$REPORT_FILE"

readlink -f "$REPORT_FILE"

# Exit with the overall status
exit $OVERALL_STATUS
