resource "aws_cloudwatch_log_destination" "firehose_logs" {
  name       = "${local.csi}-firehose-logs"
  target_arn = module.kinesis_firehose_to_splunk_logs.kinesis_firehose_arn
  role_arn   = aws_iam_role.cloudwatch_logs_to_firehose.arn

  depends_on = [
    aws_iam_role.cloudwatch_logs_to_firehose,
    aws_iam_role_policy_attachment.cloudwatch_logs_to_firehose_attachment,
    module.kinesis_firehose_to_splunk_logs.kinesis_firehose_arn
  ]
}

data "aws_iam_policy_document" "firehose_logs" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = concat(
        [for account in var.bounded_context_account_ids : "${account.account_id}"],
        ["${var.aws_account_id}"]
      )
    }
    actions   = ["logs:PutSubscriptionFilter"]
    resources = [aws_cloudwatch_log_destination.firehose_logs.arn]
  }
}

resource "aws_cloudwatch_log_destination_policy" "firehose_logs" {
  destination_name = aws_cloudwatch_log_destination.firehose_logs.name
  access_policy    = data.aws_iam_policy_document.firehose_logs.json
}
