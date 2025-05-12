# Role for Kinesis Firehose
resource "aws_iam_role" "kinesis_firehose" {
  name        = "${local.csi}-splunk-firehose-role"
  description = "IAM Role for Kinesis Firehose"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Effect": "Allow"
    }
  ]
}
POLICY

}

data "aws_iam_policy_document" "kinesis_firehose_policy_document" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = [
      var.splunk_firehose_bucket_arn,
      "${var.splunk_firehose_bucket_arn}/*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration",
    ]

    resources = [
      "${var.formatter_lambda_function_arn}:$LATEST",
    ]
  }

  statement {
    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.splunk_firehose.arn,
      aws_cloudwatch_log_stream.splunk_firehose.arn
    ]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "kinesis_firehose_iam_policy" {
  name        = "${local.csi}-firehose-policy"
  policy      = data.aws_iam_policy_document.kinesis_firehose_policy_document.json
  description = "IAM Policy for firehose delivery stream role"
}

resource "aws_iam_role_policy_attachment" "kinesis_fh_role_attachment" {
  role       = aws_iam_role.kinesis_firehose.name
  policy_arn = aws_iam_policy.kinesis_firehose_iam_policy.arn
}
