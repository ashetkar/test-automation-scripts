#!/bin/bash
set -e

DIR="driver-examples"
if [ -d "$DIR" ]; then
 echo "driver-examples repository is already present"
 cd driver-examples
 git checkout main
 git pull
else
 echo "Cloning the driver examples repository"
 git clone git@github.com:yugabyte/driver-examples.git
 cd driver-examples
fi

cd python-psycopg2/

python3 -m venv $WORKSPACE/environments/psycopg2-test

source $WORKSPACE/environments/psycopg2-test/bin/activate

pip install psycopg2-yugabytedb

export YB_PATH=$YUGABYTE_HOME_DIRECTORY

EXIT_STATUS=0

python3 test_uniformloadbalancer.py || EXIT_STATUS=$?

python3 test_topologyawareloadbalancer.py || EXIT_STATUS=$?

python3 test_misc.py || EXIT_STATUS=$?

deactivate

exit $EXIT_STATUS