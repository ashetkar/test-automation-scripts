#!/bin/bash
set -e

DIR="gocql"
REPORT_FILE="$WORKSPACE/artifacts/test_report_gocql.json"

if [ -d "$DIR" ]; then
 echo "gocql repository is already present"
 cd gocql
 git checkout master
 git pull
else
 echo "Cloning the gocql repository"
 git clone git@github.com:yugabyte/gocql.git
 cd gocql
fi

echo "Running tests"

go clean -testcache

# Run the specific test case and capture errors
echo "Running gocql tests..."
go test -v 2>&1 | tee gocql-tests.log

echo "[" >> temp_report.json

if grep "FAIL:" "gocql-tests.log"; then
  # Get the lines with 'FAIL'
  grep -B 1 "FAIL:" gocql-tests.log > stack4json.log
  # test_name=`sed -n '/^.*FAIL:\s\+\(\w\+\).*$/s//\1/p' gocql-tests.log`
  python $WORKSPACE/integrations/utils/create_json.py --test_name "NA" --script_name "go test" --result FAILED --file_path stack4json.log >> temp_report.json
  RESULT=1
else
  python $WORKSPACE/integrations/utils/create_json.py --test_name "NA" --script_name "go test" --result PASSED >> temp_report.json
fi

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

