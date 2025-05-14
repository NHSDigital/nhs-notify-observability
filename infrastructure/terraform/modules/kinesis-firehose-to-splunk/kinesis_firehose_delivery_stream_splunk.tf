resource "aws_kinesis_firehose_delivery_stream" "splunk_firehose" {
  name        = "${local.csi}-splunk-${var.type}-firehose"
  destination = "splunk"

  splunk_configuration {
    hec_endpoint            = aws_ssm_parameter.splunk_hec_endpoint.value
    hec_endpoint_type       = "Event"
    hec_token               = aws_ssm_parameter.splunk_hec_token.value
    retry_duration          = 300
    s3_backup_mode          = "FailedEventsOnly"
    buffering_size             = var.kinesis_firehose_buffer
    buffering_interval         = var.kinesis_firehose_buffer_interval

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${var.formatter_lambda_function_arn}:$LATEST"
        }
        parameters {
          parameter_name  = "RoleArn"
          parameter_value = aws_iam_role.kinesis_firehose.arn
        }
        parameters {
          parameter_name  = "BufferSizeInMBs"
          parameter_value = var.formatter_lambda_buffer
        }
        parameters {
          parameter_name  = "BufferIntervalInSeconds"
          parameter_value = var.formatter_lambda_buffer_interval
        }
      }
    }

    s3_configuration {
      role_arn           = var.firehose_to_s3_role_arn
      bucket_arn         = var.splunk_firehose_bucket_arn
      buffering_size     = var.s3_kinesis_firehose_buffer
      buffering_interval = var.s3_kinesis_firehose_buffer_interval
      compression_format = "GZIP"
      kms_key_arn        = var.kms_splunk_key_arn

    }

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
