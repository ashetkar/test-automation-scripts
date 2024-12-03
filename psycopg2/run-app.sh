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
        python $WORKSPACE/integrations/utils/create_json.py --test_name $test_name --script_name psycopg2/$script_name.py --result PASSED >> temp_report.json 
    else
        sed -n '/Traceback/,$p' unittest_error.log > stack4json.log
        python $WORKSPACE/integrations/utils/create_json.py --test_name $test_name --script_name psycopg2/$script_name.py --result FAILED --file_path stack4json.log >> temp_report.json  
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
run_test "TestUniformLoadBalancer.test_lb_true" "test_uniformloadbalancer" 2> unittest_error.log
run_test "TestUniformLoadBalancer.test_lb_true_multithreaded" "test_uniformloadbalancer" 2> unittest_error.log
run_test "TestUniformLoadBalancer.test_lb_true_node_down" "test_uniformloadbalancer" 2> unittest_error.log
run_test "TestUniformLoadBalancer.test_lb_true_new_node" "test_uniformloadbalancer" 2> unittest_error.log
run_test "TestUniformLoadBalancer.test_lb_true_localhost" "test_uniformloadbalancer" 2> unittest_error.log
run_test "TestUniformLoadBalancer.test_lb_true_pool" "test_uniformloadbalancer" 2> unittest_error.log

run_test "TestTopologyAwareLoadBalancer.test_topology_aware" "test_topologyawareloadbalancer" 2> unittest_error.log
run_test "TestTopologyAwareLoadBalancer.test_topology_aware_multithreaded" "test_topologyawareloadbalancer" 2> unittest_error.log
run_test "TestTopologyAwareLoadBalancer.test_topology_aware_node_down" "test_topologyawareloadbalancer" 2> unittest_error.log
run_test "TestTopologyAwareLoadBalancer.test_topology_aware_add_node" "test_topologyawareloadbalancer" 2> unittest_error.log
run_test "TestTopologyAwareLoadBalancer.test_topology_aware_localhost" "test_topologyawareloadbalancer" 2> unittest_error.log
run_test "TestTopologyAwareLoadBalancer.test_topology_aware_pool" "test_topologyawareloadbalancer" 2> unittest_error.log

run_test "TestMisc.test_default_port_with_cluster_on_different_port" "test_misc" 2> unittest_error.log
run_test "TestMisc.test_default_port" "test_misc" 2> unittest_error.log
run_test "TestMisc.test_all_valid_uris" "test_misc" 2> unittest_error.log

run_test "TestFallbackTopology.test_all_valid_placement_zones" "test_fallback_topology" 2> unittest_error.log
run_test "TestFallbackTopology.test_fallback" "test_fallback_topology" 2> unittest_error.log
run_test "TestFallbackTopology.test_multilevel_fallback_with_node_up" "test_fallback_topology" 2> unittest_error.log

run_test "TestClusterAwareRR.test_cluster_aware_rr_all_cases" "test_cluster_aware_rr" 2> unittest_error.log

run_test "TestTopologyAwareRR.test_topology_aware_rr_all_cases" "test_topology_aware_rr" 2> unittest_error.log
# Finalize the JSON report
sed -i '$ s/,$//' temp_report.json # Remove trailing comma from the last JSON object
echo "]" >> temp_report.json

# Move the temporary report to the final report file
mv temp_report.json "$REPORT_FILE"

# Display the JSON report
cat "$REPORT_FILE"

readlink -f "$REPORT_FILE"

# Deactivate the virtual environment
deactivate

# Exit with the overall status
exit $OVERALL_STATUS
