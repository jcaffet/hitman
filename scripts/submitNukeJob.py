import os
import sys
import boto3

# This script simply submits a Nuke job to AWS Batch
# It can used used either to tests purposes or for one shot account deletion
# Pay extrem attention to the final accountId, all ressources will be deleted !

ACCOUNT_DIGIT_SIZE = 12
NUKE_CENTRAL_ACCOUNT = "123456789012"
NUKE_ROLE_TO_ASSUME = "hitman-nuke-role"
JOBNAME = "hitman-job"
JOBQUEUE = "arn:aws:batch:eu-west-1:" + NUKE_CENTRAL_ACCOUNT + ":job-queue/hitman-queue"
JOBDEFINITION = "arn:aws:batch:eu-west-1:" + NUKE_CENTRAL_ACCOUNT + ":job-definition/hitman-job-definition:3"

if len(sys.argv) == 2:
	accountIdToNuke = sys.argv[1]
	if len(accountIdToNuke) != ACCOUNT_DIGIT_SIZE:
		raise Exception('No valid accountId !')
else:
	raise Exception('No valid number of arguments !')

client = boto3.client('batch')
response = client.submit_job(
	jobName=JOBNAME + "-" + accountIdToNuke,
	jobQueue=JOBQUEUE,
	jobDefinition=JOBDEFINITION,
	containerOverrides={
		'environment': [
			{
				'name': 'ACCOUNT_TO_NUKE',
				'value': accountIdToNuke
			},
			{
				'name': 'NUKE_ROLE_TO_ASSUME',
				'value': NUKE_ROLE_TO_ASSUME
			},
		]
	}
)

print("Job %s launched with jobId %s to nuke account %s with role %s" % (response['jobName'], response['jobId'], accountIdToNuke, NUKE_ROLE_TO_ASSUME))
