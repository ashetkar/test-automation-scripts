#!/bin/bash
set -e

# Start YugabyteDB
$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl create --tserver_flags="cql_nodelist_refresh_interval_secs=8" --master_flags="tserver_unresponsive_timeout_ms=10000, partitions_vtable_cache_refresh_secs=0"
