#!/bin/bash
set -e

core_aws_alias=$1
supported_regions=$2
branch=$3
primary_region=$4

echo "core_aws_alias - ${core_aws_alias}"
echo "supported_regions - ${supported_regions}"
echo "branch - ${branch}"
echo "primary_region - ${primary_region}"

# supported_regions=${supported_regions// /}
supported_regions=${supported_regions//,/}
supported_regions=${supported_regions##[}
supported_regions=${supported_regions%]}
target_regions=($supported_regions)
echo "target_regions - ${target_regions}"

cd serverless/supported

for region in ${target_regions[@]}; do
  echo "Deploying to ${region}"

  regional_deployment_bucket="ir-sls-deploy-${core_aws_alias}-${region}"
  echo "Regional deployment bucket - ${regional_deployment_bucket}"

  set -o xtrace

  serverless deploy \
    --branch ${branch} \
    --region ${region} \
    --deployment-bucket "${regional_deployment_bucket}" \
    --primary_region ${primary_region}

  set +o xtrace
done
