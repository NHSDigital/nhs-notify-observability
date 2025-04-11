resource "aws_cloudwatch_metric_stream" "metrics_to_firehose" {
  name                            = "${local.csi}-metric-stream"
  firehose_arn                    = aws_kinesis_firehose_delivery_stream.splunk_metrics.arn
  role_arn                        = aws_iam_role.metric_stream_to_firehose.arn
  output_format                   = "json"
  include_linked_accounts_metrics = true

  depends_on = [aws_kinesis_firehose_delivery_stream.splunk_metrics]
}
