#!/bin/bash
set -e

DIR="hashicorp-vault-ysql-plugin"
if [ -d "$DIR" ]; then
 echo "hashicorp-vault-ysql-plugin repository is already present"
 cd hashicorp-vault-ysql-plugin
 git checkout master
 git pull
else
 echo "Cloning the hashicorp-vault-ysql-plugin repository"
 git clone git@github.com:yugabyte/hashicorp-vault-ysql-plugin.git
 cd hashicorp-vault-ysql-plugin
fi

echo "Running tests"

go clean -testcache

go test -v