resource "aws_cloudwatch_event_target" "aws_backup_errors" {
  rule           = aws_cloudwatch_event_rule.aws_backup_errors.name
  event_bus_name = data.terraform_remote_state.acct.outputs.event_bus_name
  arn            = module.lambda_alert_forwarding.function_arn
}
