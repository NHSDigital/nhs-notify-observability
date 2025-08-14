resource "aws_lambda_permission" "sechub" {
  statement_id  = "AllowExecutionFromCloudWatchSechub"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_alert_forwarding.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sechub.arn
}
