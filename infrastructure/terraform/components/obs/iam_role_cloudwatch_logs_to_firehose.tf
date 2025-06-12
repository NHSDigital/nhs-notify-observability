resource "aws_iam_role" "cloudwatch_logs_to_firehose" {
  name               = "${local.csi}-cloudwatch-logs-to-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_logs_to_firehose_assume_role_policy.json
}

data "aws_iam_policy_document" "cloudwatch_logs_to_firehose_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values = concat(
        [for account in var.bounded_context_account_ids : "arn:aws:logs:${var.region}:${account.account_id}:*"],
        ["arn:aws:logs:${var.region}:${var.aws_account_id}:*"],
        [for account in var.bounded_context_account_ids : "arn:aws:logs:us-east-1:${account.account_id}:*"],
        ["arn:aws:logs:us-east-1:${var.aws_account_id}:*"]
      )
    }
  }
}

resource "aws_iam_policy" "cloudwatch_logs_to_firehose_policy" {
  name   = "${local.csi}-cloudwatch-logs-to-firehose-policy"
  policy = data.aws_iam_policy_document.cloudwatch_logs_to_firehose_policy.json
}

data "aws_iam_policy_document" "cloudwatch_logs_to_firehose_policy" {
  statement {
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    resources = [
      module.kinesis_firehose_to_splunk_logs.kinesis_firehose_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_to_firehose_attachment" {
  role       = aws_iam_role.cloudwatch_logs_to_firehose.name
  policy_arn = aws_iam_policy.cloudwatch_logs_to_firehose_policy.arn
}
