#!/bin/bash
# This script can be used if you deploy the hitman-role in spoke accounts through a StackSet
usage(){
    echo "Usage: $0 <central-account>" 
    echo "central-account : aws profile where Hitman is running" 
}

if [ $# -eq 1 ]; then
   central_account=$1
else
   usage;
   exit 1;
fi

STACK_SET_NAME=hitman-spoke-account

echo "Creating stack-set"
aws cloudformation create-stack-set \
    --stack-set-name "${STACK_SET_NAME}" \
    --description "Stack providing cross account access for Hitman" \
    --template-body file://cf-hitman-spoke-account.yml \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters ParameterKey=HitmanCentralAccount,ParameterValue=${central_account}

