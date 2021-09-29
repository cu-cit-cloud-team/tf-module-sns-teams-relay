# tf-module-sns-teams-relay
Terraform module to relay AWS SNS messages to a Teams webhook

## Change Log
- 1.0
  - Initial release

## Variables

- `namespace` (optional) --- A string prefix to add to AWS resource in order to ensure unique AWS resource names, if the module is deployed multiple times in the same region
- `tags` (optional) --- Mapping of tags to apply to AWS resources created
- `teams_webhook_url` (required) --- URL of webhook for the target Teams channel
- `sns_topic_arn_list` --- A list of SNS Arns which should have messages relayed to Teams

## Outputs

- `sns-teams-relay-lambda-arn` --- the Arn of the Lambda function deployed by the module