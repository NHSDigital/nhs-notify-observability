resource "aws_lambda_permission" "aws_backup_errors" {
  statement_id  = "AllowExecutionFromCloudWatchAWSBackupErrors"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_alert_forwarding.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.aws_backup_errors.arn
}
