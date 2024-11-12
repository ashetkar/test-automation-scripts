#!/bin/bash
set -e

DIR="driver-examples"
REPORT_FILE="$WORKSPACE/artifacts/test_report_psycopg2.json"
OVERALL_STATUS=0

# Function to run individual test cases and capture their results
run_test() {
    local test_name=$1
    local script_name=$2
    echo "Running $test_name from $script_name.py..."
    
    # Run the specific test case and capture errors
    python3 -m unittest "${script_name}.${test_name}"
    local exit_status=$?
    if [ $exit_status -eq 0 ]; then
        echo "{ \"test_name\": \"$test_name\", \"script_name\": \"$script_name.py\", \"result\": \"PASSED\", \"error_stack\": \"\" }," >> temp_report.json
    else
        echo "{ \"test_name\": \"$test_name\", \"script_name\": \"$script_name.py\", \"result\": \"FAILED\", \"error_stack\": \"$(tail -n 10 unittest_error.log)\" }," >> temp_report.json
        OVERALL_STATUS=1
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

cd python-psycopg2/

# Setup Python virtual environment
python3 -m venv $WORKSPACE/environments/psycopg2-test
source $WORKSPACE/environments/psycopg2-test/bin/activate
pip install psycopg2-yugabytedb

export YB_PATH=$YUGABYTE_HOME_DIRECTORY

# Initialize the JSON report
echo "[" > temp_report.json

# Run all the individual tests you want
run_test "TestUniformLoadBalancer.test_2" "test_uniformloadbalancer" 2> unittest_error.log
run_test "TestUniformLoadBalancer.test_3" "test_uniformloadbalancer" 2> unittest_error.log
run_test "TestUniformLoadBalancer.test_4" "test_uniformloadbalancer" 2> unittest_error.log
run_test "TestUniformLoadBalancer.test_5" "test_uniformloadbalancer" 2> unittest_error.log
run_test "TestUniformLoadBalancer.test_6" "test_uniformloadbalancer" 2> unittest_error.log
run_test "TestUniformLoadBalancer.test_7" "test_uniformloadbalancer" 2> unittest_error.log

run_test "TestTopologyAwareLoadBalancer.test_2" "test_topologyawareloadbalancer" 2> unittest_error.log
run_test "TestTopologyAwareLoadBalancer.test_3" "test_topologyawareloadbalancer" 2> unittest_error.log
run_test "TestTopologyAwareLoadBalancer.test_4" "test_topologyawareloadbalancer" 2> unittest_error.log
run_test "TestTopologyAwareLoadBalancer.test_5" "test_topologyawareloadbalancer" 2> unittest_error.log
run_test "TestTopologyAwareLoadBalancer.test_6" "test_topologyawareloadbalancer" 2> unittest_error.log
run_test "TestTopologyAwareLoadBalancer.test_7" "test_topologyawareloadbalancer" 2> unittest_error.log

run_test "TestMisc.test_2" "test_misc" 2> unittest_error.log
run_test "TestMisc.test_3" "test_misc" 2> unittest_error.log
# Finalize the JSON report
sed -i '$ s/,$//' temp_report.json # Remove trailing comma from the last JSON object
echo "]" >> temp_report.json

# Move the temporary report to the final report file
mv temp_report.json "$REPORT_FILE"

# Display the JSON report
cat "$REPORT_FILE"

# Deactivate the virtual environment
deactivate

# Exit with the overall status
exit $OVERALL_STATUS
