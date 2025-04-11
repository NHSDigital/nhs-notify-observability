resource "aws_iam_policy" "firehose_splunk_logs" {
  name = "${local.csi}-firehose-splunk-logs-delivery-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = [
          "${module.s3bucket_splunk_logs.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = module.kms_splunk.key_arn
      },
      {
        Effect = "Allow",
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ],
        Resource = aws_kinesis_firehose_delivery_stream.splunk_logs.arn,
        Principal = {
          AWS = var.delegated_grafana_account_ids[*].account_id
        }
      }
    ]
  })
}
