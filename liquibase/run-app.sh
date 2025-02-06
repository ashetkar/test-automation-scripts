#!/bin/bash
set -e
REPORT_FILE="$WORKSPACE/artifacts/test_report_liquibase_plugin.json"

echo "Cloning the liquibase extension repository"

rm -rf liquibase-yugabytedb
git clone -q git@github.com:liquibase/liquibase-yugabytedb.git && cd liquibase-yugabytedb
$YUGABYTE_HOME_DIRECTORY/bin/ysqlsh -f ./src/test/resources/docker/yugabytedb-init.sql

echo "Editing the config file"

rm src/test/resources/harness-config.yml && cp $INTEGRATIONS_HOME_DIRECTORY/liquibase/harness-config.yml src/test/resources
sed -i 's@${YUGABYTE_RELEASE_NUMBER}@'"$YUGABYTE_RELEASE_NUMBER"'@' src/test/resources/harness-config.yml

echo "Building the Liquibase tests"
JAVA_HOME=/usr/lib/jvm/zulu-11.jdk mvn -ntp -q clean install

# Function to run individual test cases and capture their results
run_test() {
    local test_name=$1
    local script_name=$2

    if [ $test_name == " " ]; then
      tc_name="default"
    else
      tc_name=$test_name

    # Run the specific test case and capture errors
    JAVA_HOME=/usr/lib/jvm/zulu-11.jdk mvn -ntp test ${test_name} 2>&1 | tee ${tc_name}.log
    
    if ! grep "BUILD SUCCESS" ${tc_name}.log; then
      # Get the lines between 'FAILURE!' and 'BUILD FAILURE' which is the stack trace
      sed -n '/FAILURE!/,/BUILD FAILURE/{/FAILURE!/b;/BUILD FAILURE/b;p}' ${tc_name}.log > stack4json.log
      python $WORKSPACE/integrations/utils/create_json.py --test_name $tc_name --script_name $script_name --result FAILED --file_path stack4json.log >> temp_report.json  
      RESULT=1
    else
      python $WORKSPACE/integrations/utils/create_json.py --test_name $tc_name --script_name $script_name --result PASSED >> temp_report.json  
    fi
}

echo "[" > temp_report.json

echo "Running the Liquibase tests"
run_test " "                                 "liquibase/start.sh"
run_test "FoundationalExtensionHarnessSuite" "liquibase/start.sh"
run_test "AdvancedExtensionHarnessSuite"     "liquibase/start.sh"

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


