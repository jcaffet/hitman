#!/bin/sh

usage(){
    echo "Usage: $0 <profile> <accountId>"
    echo "profile : aws profile to reach Hitman assets"
    echo "accountId : aws account to nuke"
}

if [ $# -eq 2 ]; then
   profile=$1
   account=$2
else
   usage;
   exit 1;
fi

TMP_ASSUME_ROLE_FILE=/tmp/assume-role.json
ROLE_TO_ASSUME=Administrator
HITMAN_ACCOUNT="123456789012"

echo "Get session on profile ${profile}"
aws --profile=${PROFILE} sts assume-role --role-arn arn:aws:iam::${HITMAN_ACCOUNT}:role/${ROLE_TO_ASSUME} \
                                         --role-session-name assumeRoleForNuke \
					 >${TMP_ASSUME_ROLE_FILE}

export AWS_SECRET_ACCESS_KEY=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SecretAccessKey`
export AWS_ACCESS_KEY_ID=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.AccessKeyId`
export AWS_SESSION_TOKEN=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SessionToken`

python submitNukeJob.py ${account}
