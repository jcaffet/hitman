#!/bin/sh
AWSNUKE_BIN=/usr/local/bin/aws-nuke
AWSNUKE_CONFIG_TEMPLATE=awsnuke-config-template.yaml
AWSNUKE_CONFIG=awsnuke-config.yaml
TMP_ASSUME_ROLE_FILE=/tmp/assume-role.json

echo "aws-nuke version :"
${AWSNUKE_BIN} version

echo "Retrieve nuke template file from s3://${CONF_BUCKET}/${AWSNUKE_CONFIG_TEMPLATE}"
aws s3 cp s3://${CONF_BUCKET}/${AWSNUKE_CONFIG_TEMPLATE} .

echo "Set account to nuke : ${ACCOUNT_TO_NUKE} in ${AWSNUKE_CONFIG_TEMPLATE}"
sed "s/||ACCOUNT||/${ACCOUNT_TO_NUKE}/g" ${AWSNUKE_CONFIG_TEMPLATE} > ${AWSNUKE_CONFIG}

echo "Assume role ${NUKE_ROLE_TO_ASSUME} role on ${ACCOUNT_TO_NUKE}"
aws sts assume-role \
        --role-arn arn:aws:iam::${ACCOUNT_TO_NUKE}:role/${NUKE_ROLE_TO_ASSUME} \
	      --role-session-name assumeRoleForNuke \
				--external-id ${NUKE_ROLE_EXTERNAL_ID} \
				>${TMP_ASSUME_ROLE_FILE}

export AWS_SECRET_ACCESS_KEY=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SecretAccessKey`
if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then echo "AWS_SECRET_ACCESS_KEY not set !"; exit 1; fi

export AWS_ACCESS_KEY_ID=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.AccessKeyId`
if [ -z "${AWS_ACCESS_KEY_ID}" ]; then echo "AWS_ACCESS_KEY_ID not set !"; exit 1; fi

export AWS_SESSION_TOKEN=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SessionToken`
if [ -z "${AWS_SESSION_TOKEN}" ]; then echo "AWS_SESSION_TOKEN not set !"; exit 1; fi

echo "Start nuking ${ACCOUNT_TO_NUKE}"
${AWSNUKE_BIN} --config ${AWSNUKE_CONFIG} \
	      --session-token ${AWS_SESSION_TOKEN} \
        --access-key-id ${AWS_ACCESS_KEY_ID} \
	      --secret-access-key ${AWS_SECRET_ACCESS_KEY} \
	      --no-dry-run \
	      --force
