# Hitman

Hitman is an AWS account content killer specialist.

## Description

People often need to delete training, POC, learning AWS accounts. Hitman is here to do the job for you at a defined frequency.
It ensures cost containment and security hardening.

**Warning : pay an extreme attention to the account list to nuke ... and do not forget to blacklist the accounts you will never want to nuke.**

## Design

### Diagram

![Hitman Diagram](images/hitman-diagram.png)

### Technical details

Hitman is based on the great [aws-nuke](https://github.com/rebuy-de/aws-nuke).
It simply industrializes the deletion process thanks to the following AWS resources :
- CloudWatch Rule to trigger the deletion execution
- Batch to ensure a pay per use strategy
- ECR to host the Docker image that embeds aws-nuke
- one Lambda to gather the accounts to nuke and submit the jobs. The Lambda needs one "configMode" parameter :
  - list : collect a list of account stored in a S3 Bucket
  - ou : all the accounts of a specified AWS OrganizationUnit will be nuked
  - single : specify one single account to nuke.
- S3 to store the configuration file
- CloudWatch Logs to log the global activity

### Security

- no user, no password, no key to manage. Only roles.
- no incoming connections. No ssh access needed to compute environments.

## Installation

### Prerequisites

Hitman needs :
- a VPC
- a private subnet with outgoing connectivity (for example NAT Gateway)

### Steps

1. deploy the [cf-hitman-common.yml](cf-hitman-common.yml) CloudFormation stack in the central account
2. build, tag and push the Docker image. Follow the information provided in the ECR repository page.
3. Depending of the chosen mode :
   - add the list of accounts to nuke in [accounts.list](accounts.list) file and upload it in the S3 bucket
   - configure the Organization Unit in the CloudWatch rule
4. customize [awsnuke-config-template.yaml](awsnuke-config-template.yaml) :
   - add in the blacklist part the accounts you will never want to nuke
   - add the resources you to not want to delete. Keep the role by Hitman to delete resources
   and upload it in the created S3 bucket
5. deploy the [cf-hitman-batch.yml](cf-hitman-batch.yml) CloudFormation stack in the central account
6. in each spoke account (or once with a Stackset), deploy [cf-hitman-spoke-account.yml](cf-hitman-spoke-account.yml) to spread IAM role to assume.

Do not forget a strong ExternalId like UUID.
