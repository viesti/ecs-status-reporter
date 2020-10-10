variable "slack_webhook_url" {
  description = "Slack webhook url. Will be exposed as environment variable for the Lambda that posts to Slack"
  type        = string
}

variable "bot_name" {
  description = "Bot name, used for prefixing resources created by the module"
  type        = string
}
