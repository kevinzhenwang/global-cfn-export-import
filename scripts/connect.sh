#!/bin/bash
set -e

core_aws_account=$1
supported_regions=$2
primary_region=$3

echo "core_aws_account - ${core_aws_account}"
echo "supported_regions - ${supported_regions}"
echo "primary_region - ${primary_region}"

supported_regions=${supported_regions//,/}
supported_regions=${supported_regions##[}
supported_regions=${supported_regions%]}
echo "new supported_regions - ${supported_regions}"
target_regions=($supported_regions)
echo "target_regions - ${target_regions}"

cd serverless/supported

for region in ${target_regions[@]}; do
  echo "working region - ${region}"

  primary_lambda="arn:aws:lambda:${primary_region}:${core_aws_account}:function:iam-cfn-global-exporter"
  source_sns_arn="arn:aws:sns:${region}:${core_aws_account}:iam-global-exporter-notification-${region}"
  dt=$(date '+%Y%m%d_%H%M%S')

  set -o xtrace

  aws lambda add-permission \
    --function-name $primary_lambda \
    --statement-id sns_$dt \
    --action lambda:InvokeFunction \
    --principal sns.amazonaws.com \
    --source-arn $source_sns_arn \
    --region $primary_region

  set +o xtrace
done
