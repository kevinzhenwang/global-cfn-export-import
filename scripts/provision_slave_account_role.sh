#!/bin/bash
set -e

unique_prefix=$1
primary_region=$2

echo "[i] Start provision slave account role"
echo "unique_prefix - ${unique_prefix}"
echo "primary_region - ${primary_region}"

master_account_id=`cat env_master_account_id.txt`

cd ./serverless/slave-account

serverless deploy \
  --unique-prefix ${unique_prefix} \
  --master-account-id ${master_account_id} \
  --region ${primary_region} \
  --capabilities CAPABILITY_IAM \
  --aws-profile slave \
  --force
