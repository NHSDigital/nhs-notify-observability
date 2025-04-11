resource "aws_iam_role" "firehose_splunk_logs" {
  name = "${local.csi}-firehose-splunk-logs-delivery-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "firehose.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
