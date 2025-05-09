resource "aws_iam_role" "firehose_to_splunk" {
  name               = "${local.csi}-firehose-to-splunk-delivery-role"
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

resource "aws_iam_policy" "firehose_to_splunk" {
  name   = "${local.csi}-firehose-to-splunk-delivery-policy"
  policy = data.aws_iam_policy_document.firehose_to_splunk.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "firehose_to_splunk" {
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
      module.kinesis_firehose_to_splunk_logs.log_group_arn,
      "${module.kinesis_firehose_to_splunk_logs.log_group_arn}:*",
      module.kinesis_firehose_to_splunk_metrics.log_group_arn,
      "${module.kinesis_firehose_to_splunk_metrics.log_group_arn}:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration"
    ]
    resources = [
      "${module.splunk_logs_formatter.function_arn}:$LATEST",
      "${module.splunk_metrics_formatter.function_arn}:$LATEST"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "firehose_to_splunk" {
  role       = aws_iam_role.firehose_to_splunk.name
  policy_arn = aws_iam_policy.firehose_to_splunk.arn
}
