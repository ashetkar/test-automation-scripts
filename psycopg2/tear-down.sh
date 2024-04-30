#!/bin/bash
set -e

rm -rf $WORKSPACE/environments/psycopg2-test

# Destroy YugabyteDB cluster
$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl destroy
