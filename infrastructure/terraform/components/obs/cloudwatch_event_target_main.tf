resource "aws_cloudwatch_event_target" "main" {
  rule           = aws_cloudwatch_event_rule.main.name
  event_bus_name = data.terraform_remote_state.acct.outputs.event_bus_name
  arn            = module.lambda_alert_forwarding.function_arn
}
