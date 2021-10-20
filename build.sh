#!/bin/bash
AWS_REGION="eu-west-2"
ARTIFACT=`packer build -machine-readable moodle.json |awk -F, '$0 ~/artifact,0,id/ {print $6}'`

AMI_ID=`echo $ARTIFACT | cut -d ':' -f2`
echo 'variable "AMI_ID" { default = "'${AMI_ID}'" }' > amivar.tf

S3_BUCKET=`aws s3 ls --region $AWS_REGION |grep moodle-tf |tail -n1 |cut -d ' ' -f3`
aws s3 cp amivar.tf s3://${S3_BUCKET}/amivar.tf --region $AWS_REGION
