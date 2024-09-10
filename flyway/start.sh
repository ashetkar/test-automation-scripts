#!/bin/bash

printf '%s\n' "------------- START Flyway Tests run ------------------"
TOOL_VERSION=

CURRENT_DIR=`dirname $0`
CURRENT_DIR_PATH=`realpath $CURRENT_DIR`

cd $CURRENT_DIR_PATH

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
printf '%s\n' $summary
printf '%s\n' "------------- END Flyway Tests run ------------------"

cd ..

exit $SUCCESS
