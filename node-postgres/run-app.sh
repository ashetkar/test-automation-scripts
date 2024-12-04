#!/bin/bash
set -e

echo "Installing node-postgres smart driver package"

npm install @yugabytedb/pg

echo "Installing node-postgres smart driver pool package"

npm install @yugabytedb/pg-pool

echo "Installing winston logging package"

npm install winston

DIR="driver-examples"
REPORT_FILE="$WORKSPACE/artifacts/test_report_node_postgres.json"
OVERALL_STATUS=0

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

# Function to run individual test cases and capture their results
run_test() {
    local test_name=$1
    local script_name=$2
    echo "Running $test_name from $script_name..."

    # Run the specific test case and capture errors
    node "$test_name.js"  2>&1 | tee ${test_name}.log
    if ! grep "Test Completed" ${test_name}.log; then
      if grep "Verification failed:" ${test_name}.log; then
         # Get the lines after 'Verification failed:' which is the stack trace
        sed -n '/Verification failed:/,$p' "${test_name}.log" > stack4json.log
      else
        # Cluster creation or cleanup failed, get the last 10 lines 
        tail -n 10 ${test_name}.log > stack4json.log
      fi
      python $WORKSPACE/integrations/utils/create_json.py --test_name $test_name --script_name $script_name --result FAILED --file_path stack4json.log >> temp_report.json
      OVERALL_STATUS=1
    else
      echo "Test $test_name completed"
      python $WORKSPACE/integrations/utils/create_json.py --test_name $test_name --script_name $script_name --result PASSED >> temp_report.json
    fi
}

cd nodejs
npm install

echo "Exporting environment variable YB_PATH with the value of the path of the YugabyteDB installation directory."

export YB_PATH="$YUGABYTE_HOME_DIRECTORY"

echo "Exporting log level."

export LOG_LEVEL="silly"

# Initialize the JSON report
echo "[" > temp_report.json

echo "Running tests"

run_test "yb-fallback-star-1" "node-postgres/start.sh"

run_test "yb-fallback-star-2" "node-postgres/start.sh"

run_test "yb-fallback-test-1" "node-postgres/start.sh"

run_test "yb-fallback-test-2" "node-postgres/start.sh"

run_test "yb-fallback-test-3" "node-postgres/start.sh"

run_test "yb-fallback-topology-aware-1" "node-postgres/start.sh"

run_test "yb-fallback-topology-aware-2" "node-postgres/start.sh"

run_test "yb-fallback-topology-aware-3" "node-postgres/start.sh"

run_test "yb-load-balance-with-add-node" "node-postgres/start.sh"

run_test "yb-load-balance-with-stop-node" "node-postgres/start.sh"

run_test "yb-pooling-with-load-balance" "node-postgres/start.sh"

run_test "yb-pooling-with-topology-aware" "node-postgres/start.sh"

run_test "yb-topology-aware-with-add-node" "node-postgres/start.sh"

run_test "yb-topology-aware-with-stop-node" "node-postgres/start.sh"

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