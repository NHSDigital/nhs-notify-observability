resource "aws_cloudwatch_metric_stream" "metrics_to_firehose_us" {
  count                           = var.enable_splunk_metric_streaming ? 1 : 0
  provider                        = aws.us-east-1
  name                            = "${local.csi}-us-east-1-metric-stream"
  firehose_arn                    = module.kinesis_firehose_to_splunk_metrics_us.kinesis_firehose_arn
  role_arn                        = aws_iam_role.metric_stream_to_firehose.arn
  output_format                   = "json"
  include_linked_accounts_metrics = true
}
