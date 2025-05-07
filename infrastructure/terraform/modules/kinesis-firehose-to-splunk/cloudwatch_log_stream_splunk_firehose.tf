resource "aws_cloudwatch_log_stream" "splunk_firehose" {
  name           = "FailedDelivery"
  log_group_name = aws_cloudwatch_log_group.splunk_firehose.name
}
