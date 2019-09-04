#!/bin/bash
set -e

unique_prefix=$1
export_import_bucket=$2
primary_region=$3
supported_regions=$4

echo "unique_prefix - ${unique_prefix}"
echo "export_import_bucket - ${export_import_bucket}"
echo "primary_region - ${primary_region}"
echo "supported_regions - ${supported_regions}"

supported_regions=$(echo ${supported_regions//,/ })
target_regions=($supported_regions)
echo "target_regions - ${target_regions}"

cd ./serverless/supported

for region in ${target_regions[@]}; do
  echo "Deploying to ${region}"

  set -o xtrace

  serverless deploy \
    --unique-prefix ${unique_prefix} \
    --export-import-bucket ${export_import_bucket} \
    --primary-region ${primary_region} \
    --region ${region}

  set +o xtrace
done
