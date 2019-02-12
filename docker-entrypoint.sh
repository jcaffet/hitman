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

echo "Start nuking ${ACCOUNT_TO_NUKE} with ${NUKE_ROLE_TO_ASSUME} role"
aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT_TO_NUKE}:role/${NUKE_ROLE_TO_ASSUME} \
	            --role-session-name assumeRoleForNuke >${TMP_ASSUME_ROLE_FILE}

export AWS_SECRET_ACCESS_KEY=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SecretAccessKey`
export AWS_ACCESS_KEY_ID=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.AccessKeyId`
export AWS_SESSION_TOKEN=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SessionToken`

${AWSNUKE_BIN} --config ${AWSNUKE_CONFIG} \
	       --session-token ${AWS_SESSION_TOKEN} \
               --access-key-id ${AWS_ACCESS_KEY_ID} \
	       --secret-access-key ${AWS_SECRET_ACCESS_KEY} \
	       --no-dry-run \
	       --force

