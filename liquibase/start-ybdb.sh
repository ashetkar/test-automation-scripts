#!/bin/bash
set -e

# Destroy existing YugabyteDB cluster, if any
$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl destroy

# Start a new YugabyteDB cluster
$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl create --tserver_flags='enable_ysql_conn_mgr=true,"allowed_preview_flags_csv=enable_ysql_conn_mgr"'