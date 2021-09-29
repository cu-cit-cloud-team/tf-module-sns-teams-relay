variable "tags" {
	description = "Tags to apply to AWS resources created by the module."
	type        = map(string)
	default      = {
		"Terraform Module Source" = "https://github.com/CU-CommunityApps/tf-module-sns-teams-relay"
	}
}

variable "namespace" {
	description = "Namespace string in order to ensure unique AWS resource names, if the module is deployed multiple times in the same region."
	type        = string
	default     = "default"
}

variable "teams_webhook_url" {
	description = "URL of webhook exposed for target Teams channel."
	type        = string
}

variable "sns_topic_arn_list" {
	description = "List of ARNs for SNS topics from which notifications should be relayed."
	type        = list(string)
}