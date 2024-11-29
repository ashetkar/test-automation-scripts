#!/bin/bash
set -e

# Start the test/example application and generate reports
printf "Executing run-app.sh ...\n"
./run-app.sh

printf "hashicorp-vault-dynamic-secret-ysql-plugin test run was successful!\n"
