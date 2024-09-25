#!/bin/bash

printf '%s\n' "------------- START YSQL JDBC test run ------------------"
TOOL_VERSION=

CURRENT_DIR=`dirname $0`
CURRENT_DIR_PATH=`realpath $CURRENT_DIR`

cd $CURRENT_DIR_PATH

# Start the run
YBDB_IMAGE_PATH=$YBDB_IMAGE_PATH bash ./do-start.sh
SUCCESS="$?"

echo "Returning $SUCCESS"
summary="FAIL"
if [[ "$SUCCESS" == "0" ]]; then
  summary="PASS"
fi

# touch $HOME/jenkins/summary
# printf '|%+24s |%+24s |\n' "YSQL JDBC" $summary >> $HOME/jenkins/summary
printf '%s\n' "------------- END YSQL JDBC test run ------------------"

exit $SUCCESS
