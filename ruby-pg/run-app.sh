#!/bin/bash
set -e

DIR="driver-examples"
REPORT_FILE="$WORKSPACE/artifacts/test_report_ruby-pg_tests.json"

if [ -d "$DIR" ]; then
 echo "$DIR repository is already present"
else
 echo "Cloning the $DIR repository"
 git clone "git@github.com:yugabyte/$DIR.git"
fi

cd $DIR
git checkout main
git pull
cd ruby/ysql

export YBDB_PATH=$YUGABYTE_HOME_DIRECTORY

echo "which gem? "
which gem
echo "ruby -e Gem.user_dir"
ruby -e 'puts Gem.user_dir'
echo "ruby and gem version"
ruby -v
gem -v
echo "listing /var/lib/jenkins/bin"
ls -l /var/lib/jenkins/bin
echo "PATH: $PATH"
echo "GEM_HOME: $GEM_HOME"
export PATH=$PATH:/var/lib/jenkins/bin
echo "Installing the ysql gems..."
gem install yugabytedb-ysql -- --with-pg-config=$YBDB_PATH/postgres/bin/pg_config
echo "Installing the concurrent gems..."
gem install concurrent-ruby

# Function to run individual test cases and capture their results
run_test() {
    local script_name=$1
    local test_case=$2

    # Run the specific test case and capture errors
    echo "Running ${script_name} ${test_case}..."
    ./${script_name} ${test_case} 2>&1 | tee "${script_name}-${test_case}.log"
    if grep "RuntimeError" "${script_name}-${test_case}.log"; then
      # Get the lines after 'Error' which is the stack trace and replace new lines with '\n'
      sed -n '/Error/,$p}' "${script_name}-${test_case}.log" | awk '{printf "%s\\n", $0}' > stack4json.log
      echo "{ \"test_name\": \"$test_case\", \"script_name\": \"$script_name\", \"result\": \"FAILED\", \"error_stack\": \"$(cat stack4json.log)\" }," >> temp_report.json
      RESULT=1
    else
      echo "{ \"test_name\": \"$test_case\", \"script_name\": \"$script_name\", \"result\": \"PASSED\", \"error_stack\": \"\" }," >> temp_report.json
    fi
}

echo "[" > temp_report.json

run_test "cluster_aware_lb_test.rb" 1
run_test "cluster_aware_lb_test.rb" 2
run_test "fallback_options_lb_test.rb" 1
run_test "fallback_options_lb_test.rb" 2
run_test "fallback_options_lb_test.rb" 3
run_test "fallback_lb_test_extended.rb" 1
run_test "fallback_lb_test_extended.rb" 2
run_test "fallback_lb_test_extended.rb" 3
run_test "fallback_lb_test_extended.rb" 4
run_test "load_balance_test.rb" 1
run_test "load_balance_test.rb" 2

sed -i '$ s/,$//' temp_report.json # Remove trailing comma from the last JSON object
echo "]" >> temp_report.json

# Move the temporary report to the final report file
mv temp_report.json "$REPORT_FILE"

# Display the JSON report
echo "TEST REPORT -------------------------"
cat "$REPORT_FILE"

readlink -f "$REPORT_FILE"

exit $RESULT

