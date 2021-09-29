# tf-module-sns-teams-relay
Terraform module to relay AWS SNS messages to a Teams webhook

## Change Log
- 1.0.0
  - Initial release

## Variables

- `namespace` (optional) --- A string prefix to add to AWS resource in order to ensure unique AWS resource names, if the module is deployed multiple times in the same region
- `tags` (optional) --- Mapping of tags to apply to AWS resources created
- `teams_webhook_url` (required) --- URL of webhook for the target Teams channel
- `sns_topic_arn_list` --- A list of SNS Arns which should have messages relayed to Teams

## Outputs

- `sns_teams_relay_lambda_arn` --- the Arn of the Lambda function deployed by the module

## Example Use

```
resource "aws_sns_topic" "example" {
  name = "example-topic"
}

module "sns_teams_relay" {
  source = "github.com/CU-CommunityApps/tf-module-sns-teams-relay.git?ref=v1.0.0"
  
  tags               = {
    "Environment" = "development"
  }
  namespace          = "example"
  teams_webhook_url  = "https://cornellprod.webhook.office.com/webhookb2/abc123"
  sns_topic_arn_list = [ aws_sns_topic.example.arn ]
}

```