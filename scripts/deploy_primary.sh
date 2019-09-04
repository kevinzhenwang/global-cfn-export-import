#!/bin/bash
set -e

unique_prefix=$1
export_import_bucket=$2
primary_region=$3

echo "[i] Start deploy primary"
echo "unique_prefix - ${unique_prefix}"
echo "export_import_bucket - ${export_import_bucket}"
echo "primary_region - ${primary_region}"

cd ./serverless/primary

serverless deploy \
  --unique-prefix ${unique_prefix} \
  --export-import-bucket ${export_import_bucket} \
  --region ${primary_region}