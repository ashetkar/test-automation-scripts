#!/bin/bash

YBDB_CLONE_DIR=/var/lib/jenkins/code/yugabyte-db
YBDB_IMAGE_PREFIX=yugabyte/ecosys-yugabyte:
YBDB_IMAGE_PATH=
PHABRICATOR_ID=

# Check if Docker image tag input provided.
if [ -z "$YBDB_IMAGE" ]; then
  echo "No YBDB_IMAGE provided. Using the latest master..."
  YBDB_IMAGE=latest
fi


# Construct the Docker image path from the input or the default value and check if it exists. Exit if yes.
case $YBDB_IMAGE in
  latest)
    echo "Using the latest master to build the image ..." 
  ;;
  sha_*)
    SHA_COMMIT="${YBDB_IMAGE:4}"
    # Or ${YBDB_IMAGE#sha_}
    echo "Using the SHA commit $SHA_COMMIT to build the image ..." 
  ;;
  # phd_*)
  #   PHABRICATOR_ID="${YBDB_IMAGE:4}"
  #   echo "Using phabricator diff id $PHABRICATOR_ID to build the image ..." 
  #  ;;
  ght_*)
    YBDB_IMAGE_PATH=yugabytedb/yugabyte:${YBDB_IMAGE:4}
    echo "Using Docker Hub image $YBDB_IMAGE_PATH ..."
  ;;
  last_latest)
    LATEST_IMAGE=$(docker image list --filter=reference="${YBDB_IMAGE_PREFIX}latest" --format "{{.Repository}}:{{.Tag}}")
    if [ -z "$LATEST_IMAGE" ]; then
      echo "No Docker image found with 'latest' tag. Building new one with the latest master ..."
      YBDB_IMAGE=latest
    else
      YBDB_IMAGE_PATH=${LATEST_IMAGE}
      echo "Using the Docker image $YBDB_IMAGE_PATH ..."
    fi
  ;;
  *)
    echo "Invalid YBDB_IMAGE value: $YBDB_IMAGE. Using the latest master build ..."
    YBDB_IMAGE=latest
  ;;
esac


if [ -z "$YBDB_IMAGE_PATH" ]; then
  cd $YBDB_CLONE_DIR
  git fetch > /dev/null

  if [ ! -z "$SHA_COMMIT" ]; then
    git checkout $SHA_COMMIT
    echo "Cloned the commit $SHA_COMMIT"
  else
    git checkout master
    git pull > /dev/null
    echo "Cloned latest master of yugabyte-db repository"
  fi

  LATEST=$(git log --pretty=format:"%h" -1)
  TAG_SUFFIX=$LATEST
  if [ ! -z ${PHABRICATOR_ID} ]; then
    TAG_SUFFIX=$LATEST-${PHABRICATOR_ID}
  fi
  echo "Tag suffix: $TAG_SUFFIX"

  YBDB_IMAGE_PATH=$(docker image list --filter=reference="${YBDB_IMAGE_PREFIX}*${TAG_SUFFIX}" --format "{{.Repository}}:{{.Tag}}")
  if [ ! -z $YBDB_IMAGE_PATH ]; then
    echo "Image built with the given commit exists already: $YBDB_IMAGE_PATH"
  else
    echo "Running yb_build.sh ..."
    source ~/.bashrc
    ./yb_build.sh --clean > yb_build.log 2>&1
    grep "BUILD SUCCESS" yb_build.log
    if [ $? -ne 0 ]; then
      echo "yb_build.sh failed!"
    else
      echo "Running yb_release ..."
      ./yb_release > release.log 2>&1
      # Find and note the path/name of the generated tar.gz file.
      GENERATED_TAR=$(grep "Generated a package at" release.log | grep -o "/var/lib/jenkins/code/yugabyte-db/build/.*.tar.gz")
      if [ -z $GENERATED_TAR ]; then
        echo "Could not generate the yugabyte-db package (.tar.gz) file."
      else
        GENERATED_TAR_NAME=${GENERATED_TAR:40}
        TAG_VERSION=$(echo $GENERATED_TAR_NAME | awk -F[--] '{print $2}')
        echo "Tag version: $TAG_VERSION"

        # Build the Docker image.
        cd ../devops
        # ./bin/install_python_requirements.sh
        # ./bin/install_ansible_requirements.sh
        cd docker/images/yugabyte
        mkdir -p packages
        rm -f packages/*
        cp $GENERATED_TAR packages/yugabyte-$TAG_VERSION-$TAG_SUFFIX-centos-x86_64.tar.gz

        echo "Building the docker image ..."
        docker build -t ${YBDB_IMAGE_PREFIX}$TAG_VERSION-$TAG_SUFFIX . > ../docker-build.log 2>&1

        # Verify build succeeded.
        grep "Successfully tagged" ../docker-build.log
        if [ $? -eq 0 ]; then
          if [ "${YBDB_IMAGE}" = "latest" ]; then
            docker image tag ${YBDB_IMAGE_PREFIX}$TAG_VERSION-$TAG_SUFFIX ${YBDB_IMAGE_PREFIX}latest
          fi
          docker image prune -f

          YBDB_IMAGE_PATH=${YBDB_IMAGE_PREFIX}$TAG_VERSION-$TAG_SUFFIX
        else
          echo "Command 'docker build' failed!"
        fi
      fi
    fi
  fi
fi

