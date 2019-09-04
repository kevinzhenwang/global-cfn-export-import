#!/usr/bin/env bash
set -e

unique_prefix=${1}
export_import_bucket=${2}
primary_region=${3:-us-east-1}
supported_regions=${4}

echo "[i] primary region -- ${primary_region}"
echo "[i] export import bucket -- ${export_import_bucket}"

function bucket_provisioning () {
  echo "[#] checking $1 exists or not"
  query_bucket_name=$(aws s3api list-buckets \
    --query "Buckets[?Name=='$1'].Name" \
    --output text)
  echo "[i] query bucket name -- ${query_bucket_name}"

  if [ -z $query_bucket_name ]; then
    echo "[#] $1 not exists, then create"
    aws s3api create-bucket --bucket $1 --region $2
  else
    echo "[x] $1 already exists, ignore creating"
  fi
}

# echo "[#] checking global export import bucket exists or not"
# query_bucket_name=$(aws s3api list-buckets \
#     --query "Buckets[?Name=='$export_import_bucket'].Name" \
#     --output text)
#     echo "[i] query bucket name -- ${query_bucket_name}"

# if [ -z $query_bucket_name ]; then
#     echo "[#] global export import bucket not exists, then create"
#     aws s3api create-bucket --bucket $export_import_bucket --region $primary_region
# else
#     echo "[x] global export import bucket already exists, ignore creating"
# fi

# export import resources bucket provisioning
bucket_provisioning $export_import_bucket $primary_region

supported_regions=$(echo ${supported_regions//,/ })
target_regions=($supported_regions)
echo "target_regions - ${target_regions}"

for region in ${target_regions[@]}; do
  echo "working region - ${region}"
  regional_serverless_bucket="${unique_prefix}-export-import-serverless-${region}"
  # serverless deployment bucket provisioning
  bucket_provisioning $regional_serverless_bucket $region
done
