module "ecs_status_reporter" {
  source = "../"

  bot_name = "ecs-status"
  slack_webhook_url = "plop"

}
