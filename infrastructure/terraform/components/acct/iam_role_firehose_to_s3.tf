resource "aws_iam_role" "firehose_to_s3" {
  name               = "${local.csi}-firehose-to-s3-delivery-role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role_policy.json
}

data "aws_iam_policy_document" "firehose_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "firehose_to_s3" {
  name   = "${local.csi}-firehose-to-s3-delivery-policy"
  policy = data.aws_iam_policy_document.firehose_to_s3.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "firehose_to_s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ListBucket"
    ]
    resources = [
      module.s3bucket_splunk_firehose.arn,
      "${module.s3bucket_splunk_firehose.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [module.kms_splunk.key_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams"
    ]
    resources = [
      aws_cloudwatch_log_group.splunk_logs_firehose.arn,
      "${aws_cloudwatch_log_group.splunk_logs_firehose.arn}:*",
      aws_cloudwatch_log_group.splunk_metrics_firehose.arn,
      "${aws_cloudwatch_log_group.splunk_metrics_firehose.arn}:*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "firehose_to_s3" {
  role       = aws_iam_role.firehose_to_s3.name
  policy_arn = aws_iam_policy.firehose_to_s3.arn
}
