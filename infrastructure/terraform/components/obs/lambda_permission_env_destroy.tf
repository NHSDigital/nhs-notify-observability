resource "aws_lambda_permission" "env_destroy" {
  statement_id  = "AllowExecutionFromEnvDestroyEvent"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_alert_forwarding.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.env_destroy.arn
}
