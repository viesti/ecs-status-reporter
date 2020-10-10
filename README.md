# ecs-status-reporter

Terraform module for a Lambda function that reports ECS service status to Slack channel.

The Lambda function is written in Clojure and run by Babashka using [babashka-lambda-layer](https://github.com/dainiusjocas/babashka-lambda-layer).

Currently all ECS Task State Change events are reported.
