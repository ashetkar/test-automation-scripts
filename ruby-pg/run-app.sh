#!/bin/bash
set -e

DIR="driver-examples"
REPORT_FILE="$WORKSPACE/artifacts/test_report_ruby-pg_tests.json"

if [ -d "ruby-pg" ]; then
 echo "ruby-pg repository is already present"
else
 echo "Cloning the ruby-pg repository"
 git clone "git@github.com:yugabyte/ruby-pg.git"
fi

cd ruby-pg
git checkout logger-fix
git pull
export PATH=$PATH:/var/lib/jenkins/bin
gem install rake
gem install rake-compiler
rake clean compile
gem build yugabytedb-ysql.gemspec
echo "Installing the ysql gem..."
gem install --local yugabytedb-ysql-0.7.gem
cd ..

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

echo "which gem? $(which gem)"
echo "Gem.user_dir: $(ruby -e 'puts Gem.user_dir')"
echo "ruby version: $(ruby -v) and gem version: $(gem -v)"
echo "listing /var/lib/jenkins/bin: $(ls -l /var/lib/jenkins/bin)"
echo "PATH: $PATH"
echo "GEM_HOME: $GEM_HOME"
export PATH=$PATH:/var/lib/jenkins/bin
# echo "Installing the ysql gem..."
# gem install yugabytedb-ysql -- --with-pg-config=$YBDB_PATH/postgres/bin/pg_config
echo "Installing the concurrent gem..."
gem install concurrent-ruby
echo "Installing the pg gem..."
gem install pg -- --with-pg-config=$YBDB_PATH/postgres/bin/pg_config

# Function to run individual test cases and capture their results
run_test() {
    local script_name=$1
    local test_case=$2

    # Run the specific test case and capture errors
    echo "Running ${script_name} ${test_case}..."
    ./${script_name} ${test_case} 2>&1 | tee "${script_name}-${test_case}.log"
    if grep "Error" "${script_name}-${test_case}.log"; then
      # Get the lines after 'Error' which is the stack trace
      sed -n '/Error/,$p' "${script_name}-${test_case}.log" > stack4json.log
      python $WORKSPACE/integrations/utils/create_json.py --test_name $test_case --script_name $script_name --result FAILED --file_path stack4json.log >> temp_report.json  
      RESULT=1
    else
      python $WORKSPACE/integrations/utils/create_json.py --test_name $test_case --script_name $script_name --result PASSED >> temp_report.json  
    fi
}

echo "[" > temp_report.json

run_test "cluster_aware_lb_test.rb" test_with_single_placement_info
run_test "cluster_aware_lb_test.rb" test_with_multiple_placement_info
run_test "fallback_options_lb_test.rb" check_basic_behavior
run_test "fallback_options_lb_test.rb" check_node_down_behavior
run_test "fallback_options_lb_test.rb" check_node_down_behavior_multi_fallback
run_test "fallback_lb_test_extended.rb" check_multi_node_down_with_url
run_test "fallback_lb_test_extended.rb" check_node_down_primary_with_url
run_test "fallback_lb_test_extended.rb" check_multi_node_down_with_props
run_test "fallback_lb_test_extended.rb" check_node_down_primary_with_props
run_test "load_balance_test.rb" basic
run_test "load_balance_test.rb" with_topology_keys
run_test "rr_cluster_aware_test.rb" all
run_test "rr_topology_aware_test.rb" all

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

