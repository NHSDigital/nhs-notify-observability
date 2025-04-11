resource "aws_kinesis_firehose_delivery_stream" "splunk_logs" {
  name        = "${local.csi}-splunk-logs-firehose"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_splunk_logs.arn
    bucket_arn         = module.s3bucket_splunk_logs.arn
    buffering_size     = 5
    buffering_interval = 300
    compression_format = "GZIP"
    kms_key_arn        = module.kms_splunk.key_arn
  }
}
