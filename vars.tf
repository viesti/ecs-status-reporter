variable "slack_webhook_url" {
  description = "Slack webhook url. Will be exposed as environment variable for the Lambda that posts to Slack"
  type        = string
}

variable "bot_name" {
  description = "Bot name, used for prefixing resources created by the module"
  type        = string
}

variable "layer_s3_bucket" {
  description = "S3 bucket of the Babashka layer"
  type        = string
}

variable "layer_s3_object" {
  description = "S3 object of the Babashka layer"
  type        = string
}
