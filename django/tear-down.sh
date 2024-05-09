#!/bin/bash
set -e

rm -rf $WORKSPACE/environments/django-test
rm -rf $WORKSPACE/yb-django
rm -rf $WORKSPACE/$DJANGO_TESTS_DIR

# Destroy YugabyteDB cluster
$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl destroy
