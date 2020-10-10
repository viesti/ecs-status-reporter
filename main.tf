resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name  = "${var.bot_name}-babashka-runtime"
  description = "Provides a runtime for running Clojure scripts via Babashka: https://github.com/borkdude/babashka"

  s3_bucket = "awsserverlessrepo-changesets-18ssd5swmy82n"
  s3_key    = "096681235511/arn:aws:serverlessrepo:us-east-1:209523798522:applications-babashka-runtime-versions-0.1.0/051e10fc-afe2-40ce-ab64-8a6bec39e3b2"

  compatible_runtimes = ["provided"]
}

data "archive_file" "ecs-status-code" {
  type        = "zip"
  source_file = "${path.module}/src/handler.clj"
  output_path = "${var.bot_name}.zip"
}

resource "aws_lambda_function" "ecs-status" {
  function_name = "${var.bot_name}-lambda"
  role          = aws_iam_role.ecs-status-role.arn
  handler       = "handler/handle"

  filename         = data.archive_file.ecs-status-code.output_path
  source_code_hash = data.archive_file.ecs-status-code.output_base64sha256

  timeout = 20
  runtime = "provided"
  layers  = [aws_lambda_layer_version.lambda_layer.arn]

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }
}

resource "aws_iam_role" "ecs-status-role" {
  name = "${var.bot_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "basic-execution-attachment" {
  role       = aws_iam_role.ecs-status-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_event_rule" "ecs-status" {
  name        = "${var.bot_name}-rule"
  description = "Send ECS events to Lambda that logs to Slack"

  event_pattern = <<EOF
{
  "source": [
    "aws.ecs"
  ]
}
EOF
}

resource "aws_cloudwatch_event_target" "ecs-status" {
  rule      = aws_cloudwatch_event_rule.ecs-status.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.ecs-status.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecs-status.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs-status.arn
}
