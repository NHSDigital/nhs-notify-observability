resource "aws_cloudwatch_log_group" "splunk_logs_firehose" {
  name              = "${local.csi}-splunk-logs-firehose"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = module.kms_splunk.key_arn
  tags              = var.default_tags
}
