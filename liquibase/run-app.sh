#!/bin/bash
set -e

echo "Cloning the liquibase extension repository"

git clone -q git@github.com:liquibase/liquibase-yugabytedb.git && cd liquibase-yugabytedb
$YUGABYTE_HOME_DIRECTORY/bin/ysqlsh -f ./src/test/resources/docker/yugabytedb-init.sql

echo "Editing the config file"

rm src/test/resources/harness-config.yml && cp $INTEGRATIONS_HOME_DIRECTORY/liquibase/harness-config.yml src/test/resources

echo "Building the Liquibase tests"
JAVA_HOME=/usr/lib/jvm/zulu-11.jdk mvn -ntp -q clean install
echo "Running the Liquibase tests"
JAVA_HOME=/usr/lib/jvm/zulu-11.jdk mvn -ntp -Dtest=FoundationalExtensionHarnessSuite test

! grep "BUILD FAILURE" $ARTIFACTS_PATH/liquibasefoundationaltest.txt
