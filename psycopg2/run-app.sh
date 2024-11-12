#!/bin/bash
set -e

# Initialize variables
DIR="driver-examples"
REPORT_FILE="test_report_psycopg2.json"
TESTS=("test_uniformloadbalancer.py" "test_topologyawareloadbalancer.py" "test_misc.py")
REPORT=()
OVERALL_STATUS=0  # This will be set to 1 if any test fails

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

# Setup Python virtual environment
cd python-psycopg2/
python3 -m venv $WORKSPACE/environments/psycopg2-test
source $WORKSPACE/environments/psycopg2-test/bin/activate
pip install psycopg2-yugabytedb

export YB_PATH=$YUGABYTE_HOME_DIRECTORY

# Run tests and collect results
for TEST_SCRIPT in "${TESTS[@]}"; do
    TEST_NAME="${TEST_SCRIPT%.*}"  # Extracts 'test_uniformloadbalancer' from 'test_uniformloadbalancer.py'
    python3 "$TEST_SCRIPT"
    EXIT_STATUS=$?

    if [ $EXIT_STATUS -eq 0 ]; then
        RESULT="PASSED"
    else
        RESULT="FAILED"
        OVERALL_STATUS=1  # Mark overall status as failed if any test fails
    fi

    # Append test result to JSON array
    REPORT+=("{\"test_name\": \"$TEST_NAME\", \"script_name\": \"$TEST_SCRIPT\", \"result\": \"$RESULT\"}")
done

deactivate

# Generate final JSON report
echo "[" > $WORKSPACE/artifacts/$REPORT_FILE
(IFS=,; echo "${REPORT[*]}") >> $WORKSPACE/artifacts/$REPORT_FILE
echo "]" >> $WORKSPACE/artifacts/$REPORT_FILE

# Display the JSON report
cat $REPORT_FILE

# Exit with overall status
exit $OVERALL_STATUS
