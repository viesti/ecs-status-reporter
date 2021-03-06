# ecs-status-reporter

Terraform module for a Lambda function that reports ECS service status to Slack channel.

The Lambda function is written in Clojure and run by Babashka using [babashka-lambda-layer](https://github.com/dainiusjocas/babashka-lambda-layer).

Currently state changes started by events rules report the task duration, other states are reported as-is.

## Usage

Add the following into your `.tf` file:

```hcl
module "ecs_status_reporter" {
  # Use ref=<git hash> to pick a specific version
  source = "git@github.com:viesti/ecs-status-reporter?ref=1149c85179dbfefb2468a774f9254625b664acb5"

  bot_name = "ecs-status"
  slack_webhook_url = "..."
}
```

## Examples

Scheduled task report

![scheduled-task.png](doc/scheduled-task.png)

Service report

![service.png](doc/service.png)
