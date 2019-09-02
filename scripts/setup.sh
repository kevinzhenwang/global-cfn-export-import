#!/usr/bin/env bash
set -e

unique_prefix=${1}
export_import_bucket=${2}
primary_region=${3:-us-east-1}

echo "[i] primary region -- ${primary_region}"
echo "[i] export import bucket -- ${export_import_bucket}"

echo "[#] checking global export import bucket exists or not"
query_bucket_name=$(aws s3api list-buckets \
    --query "Buckets[?Name=='$export_import_bucket'].Name" \
    --output text)
    echo "[i] query bucket name -- ${query_bucket_name}"

if [ -z $query_bucket_name ]; then
    echo "[#] global export import bucket not exists, then create"
    aws s3api create-bucket --bucket $export_import_bucket --region $primary_region
else
    echo "[x] global export import bucket already exists, ignore creating"
fi
