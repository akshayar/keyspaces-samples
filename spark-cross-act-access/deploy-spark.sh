#!/bin/bash
set -eo pipefail
ARTIFACT_BUCKET=$1
echo "Artifact bucket is ${ARTIFACT_BUCKET}"
if [ -z "$ARTIFACT_BUCKET" ]
then
    echo "Usage: $0 <artifact-bucket>"
    exit 1
    #ARTIFACT_BUCKET=aksh-code-binaries
    #ARTIFACT_BUCKET=aksh-code-binaries-2
fi


aws s3 cp . s3://${ARTIFACT_BUCKET}/ --recursive --exclude "*" --include "*.jar"
aws s3 cp . s3://${ARTIFACT_BUCKET}/ --recursive --exclude "*" --include "*.yml"

echo "Validating CloudFormation template"
#aws cloudformation validate-template --template-body file://cloudformation/spark-act-resources.yml
echo "Validated CloudFormation template"
echo "Deploying KesSpaces cluster"
aws cloudformation deploy --template-file cloudformation/spark-act-resources.yml \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
  --stack-name spark-cluster  \
  --parameter-overrides \
  VPCCidr=172.16.0.0/16 \
  VPCStackTemplateUrl=https://${ARTIFACT_BUCKET}.s3.amazonaws.com/cloudformation/vpc-creation-with-private-subnet.yml \
  keySpacesCrossAccountRoleArn=arn:aws:iam::967781231549:role/keyspaces-cluster-KeySpacesAccountRole-1F25YC7O0V3IX \
  emrReleaseLabel=emr-6.10.0
