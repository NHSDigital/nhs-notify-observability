resource "aws_cloudwatch_event_target" "sechub" {
  rule           = aws_cloudwatch_event_rule.sechub.name
  event_bus_name = data.terraform_remote_state.acct.outputs.acct_event_bus_name
  arn            = module.lambda_alert_forwarding.function_arn
}
