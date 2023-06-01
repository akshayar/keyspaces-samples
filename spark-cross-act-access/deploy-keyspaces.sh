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
#aws cloudformation validate-template --template-body file://cloudformation/keyspaces-act-resources.yml
#aws cloudformation validate-template --template-body file://cloudformation/vpc-creation-with-private-subnet.yml
echo "Validated CloudFormation template"
echo "Deploying KesSpaces cluster"
aws cloudformation deploy --template-file cloudformation/keyspaces-act-resources.yml \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
  --stack-name keyspaces-cluster  \
  --parameter-overrides \
  VPCCidr=172.16.0.0/16 \
  VPCStackTemplateUrl=https://${ARTIFACT_BUCKET}.s3.amazonaws.com/cloudformation/vpc-creation-with-private-subnet.yml \
  KeyspaceName=testkey \
  PeerVPCCidr=10.4.0.0/16
