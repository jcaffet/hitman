#!/bin/bash
# This script can be used if you deploy the hitman-role in spoke accounts through a StackSet
# In the case, all target account are in the same AWS OrganizationUnit

usage(){
    echo "Usage: $0 <organizations-unit>" 
    echo "central-account : aws profile where Hitman is running" 
}

if [ $# -eq 1 ]; then
   organizations_unit=$1
else
   usage;
   exit 1;
fi

STACK_SET_NAME=hitman-spoke-account
REGION=eu-west-1
TARGET_ACCOUNTS=`aws organizations list-accounts-for-parent --parent-id ${organizations_unit} | jq -r '[.Accounts[] | .Id]'`

echo "Creating stack-set instances on accounts"
aws cloudformation create-stack-instances \
    --stack-set-name "${STACK_SET_NAME}" \
    --accounts "${TARGET_ACCOUNTS}" \
    --regions "${REGION}" \
    --operation-preferences FailureTolerancePercentage=100,MaxConcurrentPercentage=100

