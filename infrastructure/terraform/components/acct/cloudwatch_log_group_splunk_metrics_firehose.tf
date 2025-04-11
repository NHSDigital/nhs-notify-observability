resource "aws_cloudwatch_log_group" "splunk_metrics_firehose" {
  name              = "${local.csi}-splunk-metrics-firehose"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = module.kms_splunk.key_arn
  tags              = var.default_tags
}
