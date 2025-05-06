resource "aws_cloudwatch_log_group" "splunk_firehose" {
  name              = "${local.csi}-splunk-${var.type}-firehose"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.kms_splunk_key_arn
  tags              = var.default_tags
}
