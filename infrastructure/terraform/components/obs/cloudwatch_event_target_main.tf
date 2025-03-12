resource "aws_cloudwatch_event_target" "main" {
  rule           = aws_cloudwatch_event_rule.main.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  arn            = module.lambda_alert_forwarding.function_arn
}
