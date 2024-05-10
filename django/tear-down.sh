#!/bin/bash
set -e

export DJANGO_TESTS_DIR="django_tests_dir"

# Destroy YugabyteDB cluster
$YUGABYTE_HOME_DIRECTORY/bin/yb-ctl destroy

rm -rf $WORKSPACE/environments/django-test
rm -rf $INTEGRATIONS_HOME_DIRECTORY/django/yb-django
rm -rf $INTEGRATIONS_HOME_DIRECTORY/django/$DJANGO_TESTS_DIR