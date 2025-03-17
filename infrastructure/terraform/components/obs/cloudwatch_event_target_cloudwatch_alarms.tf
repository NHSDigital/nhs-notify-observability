resource "aws_cloudwatch_event_target" "cloudwatch_alarms" {
  rule           = aws_cloudwatch_event_rule.cloudwatch_alarms.name
  event_bus_name = data.terraform_remote_state.acct.outputs.event_bus_name
  arn            = module.lambda_alert_forwarding.function_arn
}
