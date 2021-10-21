#!/bin/bash
AWS_REGION="eu-central-1"
echo "Staring build moodle  ami instance"
if packer build -machine-readable moodle.json > out.txt
 then 
ARTIFACT=$( cat out.txt |awk -F, '$0 ~/artifact,0,id/ {print $6}' )
 else 
  echo "Packer can't compile ami for moodle" && exit 1
fi
AMI_ID=`echo $ARTIFACT | cut -d ':' -f2`
echo "Saving $AMI_ID to variables.tf"
echo 'variable "AMI_ID" { default = "'${AMI_ID}'" }' > amivar.tf

echo "Copy variable.tf to S3 bucket"
S3_BUCKET=`aws s3 ls --region $AWS_REGION |grep moodle-tf |tail -n1 |cut -d ' ' -f3`
aws s3 cp amivar.tf s3://${S3_BUCKET}/amivar.tf --region $AWS_REGION
