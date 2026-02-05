resource "aws_cloudwatch_metric_stream" "metrics_to_firehose" {
  count                           = var.ship_metrics_to_splunk ? 1 : 0
  name                            = "${local.csi}-metric-stream"
  firehose_arn                    = module.kinesis_firehose_to_splunk_metrics[0].kinesis_firehose_arn
  role_arn                        = aws_iam_role.metric_stream_to_firehose[0].arn
  output_format                   = "json"
  include_linked_accounts_metrics = true
}
