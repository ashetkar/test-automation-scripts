#!/bin/bash
set -e

DIR="flyway-tests"
REPORT_FILE="$WORKSPACE/artifacts/test_report_flyway_plugin.json"

if [ -d "$DIR" ]; then
 echo "$DIR repository is already present"
else
 echo "Cloning the $DIR repository"
 git clone "git@github.com:yugabyte/$DIR.git"
fi

cd $DIR
git checkout main
git pull

echo "Building and running the tests..."

export YBDB_PATH=$YUGABYTE_HOME_DIRECTORY
export JAVA_HOME=/usr/lib/jvm/zulu-17.jdk

# Function to run individual test cases and capture their results
run_test() {
    local test_name=$1
    local script_name=$2

    # Run the specific test case and capture errors
    local tname="com.yugabyte.${test_name/./#}"
    echo "Running ${tname}..."
    mvn test -Dtest=${tname} 2>&1 | tee ${test_name}.log
    if ! grep "BUILD SUCCESS" ${test_name}.log; then
      # Get the lines between 'FAILURE!' and 'BUILD FAILURE' which is the stack trace and replace new lines with '\n'
      sed -n '/FAILURE!/,/BUILD FAILURE/{/FAILURE!/b;/BUILD FAILURE/b;p}' ${test_name}.log | awk '{printf "%s\\n", $0}' > stack4json.log
      echo "{ \"test_name\": \"$test_name\", \"script_name\": \"$script_name\", \"result\": \"FAILED\", \"error_stack\": \"$(cat stack4json.log)\" }," >> temp_report.json
      RESULT=1
    else
      echo "{ \"test_name\": \"$test_name\", \"script_name\": \"$script_name\", \"result\": \"PASSED\", \"error_stack\": \"\" }," >> temp_report.json
    fi
}

mvn clean compile --no-transfer-progress

echo "[" > temp_report.json

run_test "TestBaseline.baselineTest"      "flyway/start.sh"
run_test "TestBaseline.dlabsTest"         "flyway/start.sh"
run_test "TestYBLocking.advisoryLockTest" "flyway/start.sh"

sed -i '$ s/,$//' temp_report.json # Remove trailing comma from the last JSON object
echo "]" >> temp_report.json
sed -i 's/\t/    /g' temp_report.json # Replace tabs with spaces

# Move the temporary report to the final report file
mv temp_report.json "$REPORT_FILE"

# Display the JSON report
echo "TEST REPORT -------------------------"
cat "$REPORT_FILE"

readlink -f "$REPORT_FILE"

exit $RESULT


