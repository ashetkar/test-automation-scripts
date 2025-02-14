#!/bin/bash
set -e

DIR="hashicorp-vault-ysql-plugin"
REPORT_FILE="$WORKSPACE/artifacts/test_report_vault_ysql_plugin.json"

if [ -d "$DIR" ]; then
 echo "hashicorp-vault-ysql-plugin repository is already present"
 cd hashicorp-vault-ysql-plugin
 git checkout master
 git pull
else
 echo "Cloning the hashicorp-vault-ysql-plugin repository"
 git clone git@github.com:yugabyte/hashicorp-vault-ysql-plugin.git
 cd hashicorp-vault-ysql-plugin
fi

echo "Running tests"

go clean -testcache

go test -v 2>&1 | tee vault-ysql-plugin-tests.log

echo "[" >> temp_report.json

if grep "FAIL:" "vault-ysql-plugin-tests.log"; then
  # Get the lines with 'FAIL'
  grep -B 1 "FAIL:" vault-ysql-plugin-tests.log > stack4json.log
  # test_name=`sed -n '/^.*FAIL:\s\+\(\w\+\).*$/s//\1/p' gocql-tests.log`
  python $WORKSPACE/integrations/utils/create_json.py --test_name "vault-ysql-plugin-tests" --script_name "hashicorp-vault-dynamic-secret-ysql-plugin/start.sh" --result FAILED --file_path stack4json.log >> temp_report.json
  RESULT=1
else
  python $WORKSPACE/integrations/utils/create_json.py --test_name "vault-ysql-plugin-tests" --script_name "hashicorp-vault-dynamic-secret-ysql-plugin/start.sh" --result PASSED >> temp_report.json
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