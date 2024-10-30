#!/bin/bash

# Simulate the output by extracting only the lines after "Results :"
results_line=$(grep -A 2 "Results :" $ARTIFACTS_PATH/liquibase_yugabytedb_test_report.txt | tail -n 1)

echo $results_line

# Extract numbers of tests run, failures, and errors using grep and sed
tests_run=$(echo $results_line | sed -n 's/.*Tests run: \([0-9]*\),.*/\1/p')
failures=$(echo $results_line | sed -n 's/.*Failures: \([0-9]*\),.*/\1/p')
errors=$(echo $results_line | sed -n 's/.*Errors: \([0-9]*\),.*/\1/p')

# Calculate the values
success=$((tests_run - failures - errors))
failures_and_errors=$((failures + errors))
total_tests=$((tests_run))

# Write results to respective files
echo "$success" > success.txt
echo "$failures_and_errors" > failures.txt
echo "$total_tests" > total.txt

echo "Extraction complete. Results are stored in success.txt, failures.txt, and total.txt."
