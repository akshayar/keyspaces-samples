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
  keySpacesCrossAccountRoleArn=arn:aws:iam::<KEYSPACES_ACCOUNT>:role/keyspaces-cluster-KeySpacesAccountRole-8FP7DV7LMQJ \
  peerVpcId=vpc-0f055f1578e22a2fe \
  peerAccountId=<KEYSPACES_ACCOUNT> \
  peerVPCCidr=10.0.0.0/16 \
  peeringAcceptorRoleArn=arn:aws:iam::<KEYSPACES_ACCOUNT>:role/keyspaces-cluster-vpcPeeringAcceptorRole-1UUEJIDAMEMIF

aws cloudformation describe-stacks --stack-name spark-cluster --query 'Stacks[0].Outputs[].[OutputKey,OutputValue]' --output text


