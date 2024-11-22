echo "Editing the config file"

rm src/test/resources/harness-config.yml && cp $INTEGRATIONS_HOME_DIRECTORY/liquibase/harness-config.yml src/test/resources
sed -i 's@${YUGABYTE_RELEASE_NUMBER}@'"$YUGABYTE_RELEASE_NUMBER"'@' src/test/resources/harness-config.yml

echo "Building the Liquibase tests"
JAVA_HOME=/usr/lib/jvm/zulu-11.jdk mvn -ntp -q clean install
echo "Running the Liquibase tests"
JAVA_HOME=/usr/lib/jvm/zulu-11.jdk mvn -ntp test 2>&1 | tee $ARTIFACTS_PATH/liquibase_yugabytedb_test_report.txt
JAVA_HOME=/usr/lib/jvm/zulu-11.jdk mvn -ntp -Dtest=FoundationalExtensionHarnessSuite test 2>&1 | tee $ARTIFACTS_PATH/liquibase_foundational_test_report.txt
JAVA_HOME=/usr/lib/jvm/zulu-11.jdk mvn -ntp -Dtest=AdvancedExtensionHarnessSuite test 2>&1 | tee $ARTIFACTS_PATH/liquibase_advanced_test_report.txt

echo "Checking the Liquibase test reports"
if [ $(grep -c "BUILD SUCCESS" $ARTIFACTS_PATH/liquibase_yugabytedb_test_report.txt) -eq 0 ]
then
  cat $ARTIFACTS_PATH/liquibase_yugabytedb_test_report.txt
fi
if [ $(grep -c "BUILD SUCCESS" $ARTIFACTS_PATH/liquibase_foundational_test_report.txt) -eq 0 ]
then
  cat $ARTIFACTS_PATH/liquibase_foundational_test_report.txt
fi
if [ $(grep -c "BUILD SUCCESS" $ARTIFACTS_PATH/liquibase_advanced_test_report.txt) -eq 0 ]
then
  cat $ARTIFACTS_PATH/liquibase_advanced_test_report.txt
fi

! grep "BUILD FAILURE" $ARTIFACTS_PATH/liquibase_yugabytedb_test_report.txt
! grep "BUILD FAILURE" $ARTIFACTS_PATH/liquibase_foundational_test_report.txt
! grep "BUILD FAILURE" $ARTIFACTS_PATH/liquibase_advanced_test_report.txt
