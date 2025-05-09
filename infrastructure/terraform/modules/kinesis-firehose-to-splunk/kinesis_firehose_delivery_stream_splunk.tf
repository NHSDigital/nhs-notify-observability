resource "aws_kinesis_firehose_delivery_stream" "splunk_firehose" {
  name        = "${local.csi}-splunk-${var.type}-firehose"
  destination = "extended_s3"

  # splunk_configuration {
  #   hec_endpoint            = data.aws_ssm_parameter.splunk_hec_endpoint_logs.value
  #   hec_endpoint_type       = "Raw"
  #   hec_token               = data.aws_ssm_parameter.splunk_hec_token_logs.value
  #   retry_duration          = 300
  #   s3_backup_mode          = "AllEvents"
  #   s3_configuration {
  #     role_arn           = aws_iam_role.firehose_to_s3.arn
  #     bucket_arn         = module.s3bucket_splunk_firehose.arn
  #     buffering_size     = 5
  #     buffering_interval = 300
  #     compression_format = "GZIP"
  #     kms_key_arn        = module.kms_splunk.key_arn
  #     cloudwatch_logging_options {
  #       enabled         = true
  #       log_group_name  = aws_cloudwatch_log_group.splunk_logs_firehose.name
  #       log_stream_name = aws_cloudwatch_log_stream.splunk_logs_firehose.name
  #     }
  #   }
  # }

  extended_s3_configuration {
    role_arn           = var.firehose_to_s3_role_arn
    bucket_arn         = var.splunk_firehose_bucket_arn
    buffering_size     = 5
    buffering_interval = 300
    compression_format = "GZIP"
    kms_key_arn        = var.kms_splunk_key_arn
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.splunk_firehose.name
      log_stream_name = aws_cloudwatch_log_stream.splunk_firehose.name
    }
  }

  server_side_encryption {
    enabled  = true
    key_arn  = var.kms_splunk_key_arn
    key_type = "CUSTOMER_MANAGED_CMK"
  }
}
