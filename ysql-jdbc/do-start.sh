#!/bin/bash
set -e

# Launch YugabyteDB
# printf "Executing start-ybdb.sh ...\n"
# ./start-ybdb.sh

# Start the test/example application and generate reports
printf "Executing run-app.sh ...\n"
./run-app.sh
