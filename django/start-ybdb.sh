#!/bin/bash
set -e

# Start YugabyteDB
$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl create --tserver_flags='enable_ysql_conn_mgr=true,"allowed_preview_flags_csv=enable_ysql_conn_mgr"'