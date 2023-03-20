resource "aws_iam_role" "lambda" {
  name = join("-", compact([var.namespace, "sns-teams-relay"]))
  tags = var.tags
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
}

data "aws_iam_policy_document" "lambda_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }    
  }
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/sns-teams-relay.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  filename      = "${path.module}/lambda.zip"
  function_name = join("-", compact([var.namespace, "sns-teams-relay"]))
  role          = aws_iam_role.lambda.arn
  handler       = "sns-teams-relay.handler"
  description   = "Relay incoming SNS messages to a Microsoft Teams webhook"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.9"

  tags = var.tags
  
  environment {
    variables = {
      WEBHOOK_URL_NORMAL = var.teams_webhook_url_normal
      WEBHOOK_URL_ALERT  = var.teams_webhook_url_alert
      ALARM_SNS_TOPICS_NORMAL = join(",", var.alarm_sns_topic_arn_list_normal)
      ALARM_SNS_TOPICS_ALERT = join(",", var.alarm_sns_topic_arn_list_alert)
      STRFTIME_FORMAT = var.strftime_format
      GENERIC_SNS_TOPICS_NORMAL = join(",", var.generic_sns_topic_arn_list_normal)
      GENERIC_SNS_TOPICS_ALERT = join(",", var.generic_sns_topic_arn_list_alert)
    }
  }  
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 14
}

resource "aws_sns_topic_subscription" "sns_message_source" {
  count     = length(var.sns_topic_arn_list)
  topic_arn = var.sns_topic_arn_list[count.index]
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "sns" {
  count         = length(var.sns_topic_arn_list)
  statement_id  = "allow-${split(":", var.sns_topic_arn_list[count.index])[5]}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn_list[count.index]
}