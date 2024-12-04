#!/bin/bash
set -e

DIR="driver-examples"
REPORT_FILE="$WORKSPACE/artifacts/test_report_rust_postgres.json"
OVERALL_STATUS=0

# Function to run individual test cases and capture their results
run_test() {
    local test_name=$1
    local script_name=$2
    echo "Running $test_name from $script_name..."

    # Run the specific test case and capture errors
    cargo run --bin "$test_name"  2>&1 | tee ${test_name}.log
    if ! grep "End of Example" ${test_name}.log; then
      tail -n 30 ${test_name}.log > stack4json.log
      python $WORKSPACE/integrations/utils/create_json.py --test_name $test_name --script_name $script_name --result FAILED --file_path stack4json.log >> temp_report.json
      OVERALL_STATUS=1
    else
      echo "Example $test_name completed"
      python $WORKSPACE/integrations/utils/create_json.py --test_name $test_name --script_name $script_name --result PASSED >> temp_report.json
    fi
}

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

# Initialize the JSON report
echo "[" > temp_report.json

echo "Running examples"

run_test "ybsql_load_balance" "rust-postgres/start.sh"

run_test "ybsql_fallback_example1" "rust-postgres/start.sh"

run_test "ybsql_fallback_example2" "rust-postgres/start.sh"

run_test "ybsql_fallback_example3" "rust-postgres/start.sh"

run_test "ulb_multithread" "rust-postgres/start.sh"

run_test "talb_multithread" "rust-postgres/start.sh"

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