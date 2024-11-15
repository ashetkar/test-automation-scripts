#!/bin/bash
set -e

DIR="driver-examples"
REPORT_FILE="$WORKSPACE/artifacts/test_report_jdbc_ysql.json"

if [ -d "$DIR" ]; then
  echo "driver-examples repository is already present"
  cd $DIR
  git checkout main
  git pull
else
  echo "Cloning the driver-examples repository ..."
  git clone git@github.com:yugabyte/driver-examples.git && cd driver-examples
fi

cd java/ysql-jdbc

echo "Compiling the YSQL JDBC tests ..."
mvn clean compile

RESULT=0

# Function to run individual test cases and capture their results
run_test() {
    local test_name=$1
    local script_name=$2
    echo "Running $test_name from $script_name..."

    # Run the specific test case and capture errors
    YBDB_PATH=$YUGABYTE_HOME_DIRECTORY mvn exec:java -Dexec.mainClass=com.yugabyte.ysql.${test_name}  2>&1 | tee ${test_name}.log
    if ! grep "BUILD SUCCESS" ${test_name}.log; then
      # Get the lines between '[WARNING]' and 'BUILD FAILURE' which is the stack trace and replace new lines with '\n'
      sed -n '/\[WARNING\]/,/BUILD FAILURE/{/\[WARNING\]/b;/BUILD FAILURE/b;p}' ${test_name}.log | awk '{printf "%s\\n", $0}' > stack4json.log
      echo "{ \"test_name\": \"$test_name\", \"script_name\": \"$script_name\", \"result\": \"FAILED\", \"error_stack\": \"$(cat stack4json.log)\" }," >> temp_report.json
      RESULT=1
    else
      echo "{ \"test_name\": \"$test_name\", \"script_name\": \"$script_name\", \"result\": \"PASSED\", \"error_stack\": \"\" }," >> temp_report.json
    fi
}

echo "[" > temp_report.json

run_test "LoadBalanceConcurrencyExample"   "JDBC Smart Driver"
run_test "TopologyAwareLBFallbackExample"  "JDBC Smart Driver"
run_test "TopologyAwareLBFallback2Example" "JDBC Smart Driver"
run_test "ReadReplicaSupportExample"       "JDBC Smart Driver"
run_test "ReadReplicaSupportHikariExample" "JDBC Smart Driver"

sed -i '$ s/,$//' temp_report.json # Remove trailing comma from the last JSON object
echo "]" >> temp_report.json

# Move the temporary report to the final report file
mv temp_report.json "$REPORT_FILE"

# Display the JSON report
echo "TEST REPORT -------------------------"
cat "$REPORT_FILE"

readlink -f "$REPORT_FILE"

exit $RESULT

