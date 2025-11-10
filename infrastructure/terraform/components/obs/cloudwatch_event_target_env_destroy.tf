resource "aws_cloudwatch_event_target" "env_destroy" {
  rule           = aws_cloudwatch_event_rule.env_destroy.name
  event_bus_name = data.terraform_remote_state.acct.outputs.acct_event_bus_name
  arn            = module.lambda_alert_forwarding.function_arn
}
