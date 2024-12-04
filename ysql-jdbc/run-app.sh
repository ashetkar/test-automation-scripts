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
    local tname=${test_name%.main}
    YBDB_PATH=$YUGABYTE_HOME_DIRECTORY mvn exec:java -Dexec.mainClass=com.yugabyte.ysql.${tname}  2>&1 | tee ${test_name}.log
    if ! grep "BUILD SUCCESS" ${test_name}.log; then
      # Get the lines between '[WARNING]' and 'BUILD FAILURE' which is the stack trace
      sed -n '/\[WARNING\]/,/BUILD FAILURE/{/\[WARNING\]/b;/BUILD FAILURE/b;p}' ${test_name}.log > stack4json.log
      python $WORKSPACE/integrations/utils/create_json.py --test_name $test_name --script_name $script_name --result FAILED --file_path stack4json.log >> temp_report.json  
      RESULT=1
    else
      python $WORKSPACE/integrations/utils/create_json.py --test_name $test_name --script_name $script_name --result PASSED >> temp_report.json  
    fi
}

echo "[" > temp_report.json

run_test "LoadBalanceConcurrencyExample.main"   "ysql-jdbc/start.sh"
run_test "TopologyAwareLBFallbackExample.main"  "ysql-jdbc/start.sh"
run_test "TopologyAwareLBFallback2Example.main" "ysql-jdbc/start.sh"
run_test "ReadReplicaSupportExample.main"       "ysql-jdbc/start.sh"
run_test "ReadReplicaSupportHikariExample.main" "ysql-jdbc/start.sh"

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

