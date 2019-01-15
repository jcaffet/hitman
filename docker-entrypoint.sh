#!/bin/sh
AWSNUKE_BIN=/usr/local/bin/aws-nuke
AWSNUKE_CONFIG_TEMPLATE=awsnuke-config-template.yaml
AWSNUKE_CONFIG=awsnuke-config.yaml

echo "Account to nuke : ${ACCOUNT_TO_NUKE}"

echo "Retrieve nuke template file"
aws s3 cp s3://${CONF_BUCKET}/${AWSNUKE_CONFIG_TEMPLATE} .

echo "aws-nuke version :"
${AWSNUKE_BIN} version

echo "Starting nuking ${ACCOUNT_TO_NUKE}"
aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT_TO_NUKE}:role/Administrator --role-session-name assumeRoleForNuke >/tmp/assume-role.json
export AWS_SECRET_ACCESS_KEY=`cat /tmp/assume-role.json | jq -r .Credentials.SecretAccessKey`
export AWS_ACCESS_KEY_ID=`cat /tmp/assume-role.json | jq -r .Credentials.AccessKeyId`
export AWS_SESSION_TOKEN=`cat /tmp/assume-role.json | jq -r .Credentials.SessionToken`
sed "s/||ACCOUNT||/${ACCOUNT_TO_NUKE}/g" ${AWSNUKE_CONFIG_TEMPLATE} > ${AWSNUKE_CONFIG}
${AWSNUKE_BIN} --config ${AWSNUKE_CONFIG} --session-token ${AWS_SESSION_TOKEN} --access-key-id ${AWS_ACCESS_KEY_ID} --secret-access-key ${AWS_SECRET_ACCESS_KEY} --no-dry-run --force
