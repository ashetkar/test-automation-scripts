#!/bin/bash

printf '%s\n' "------------- START GOCQL run ------------------"
TOOL_VERSION=

CURRENT_DIR=`dirname $0`
CURRENT_DIR_PATH=`realpath $CURRENT_DIR`

cd $CURRENT_DIR_PATH

# Start the run
./do-start.sh
SUCCESS="$?"

# Tear down the setup
printf "Executing tear-down.sh ...\n"
./tear-down.sh

# Print summary
echo "Returning $SUCCESS"
summary="FAIL"
if [[ "$SUCCESS" == "0" ]]; then
  summary="PASS"
fi
printf '|%+24s |%+24s |\n' "GOCQL" $summary
printf '%s\n' "------------- END GOCQL run ------------------"

cd ..

exit $SUCCESS
