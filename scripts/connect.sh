#!/bin/bash
set -e

unique_prefix=$1
primary_region=$2
supported_regions=$3

aws_account_id=$(aws sts get-caller-identity --query "Account" --output text)

echo "primary_region - ${primary_region}"
echo "supported_regions - ${supported_regions}"

# supported_regions=${supported_regions//,/ /}
supported_regions=$(echo ${supported_regions//,/ })
target_regions=($supported_regions)
echo "target_regions - ${target_regions}"

for region in ${target_regions[@]}; do
  echo "working region - ${region}"

  primary_lambda="arn:aws:lambda:${primary_region}:${aws_account_id}:function:${unique_prefix}-global-cfn-exporter"
  source_sns_arn="arn:aws:sns:${region}:${aws_account_id}:${unique_prefix}-global-exporter-notification-${region}"
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
