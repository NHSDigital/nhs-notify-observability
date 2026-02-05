resource "aws_cloudwatch_log_destination" "firehose_logs" {
  count      = var.ship_logs_to_splunk ? 1 : 0
  name       = "${local.csi}-firehose-logs"
  target_arn = module.kinesis_firehose_to_splunk_logs[0].kinesis_firehose_arn
  role_arn   = aws_iam_role.cloudwatch_logs_to_firehose[0].arn

  depends_on = [
    aws_iam_role.cloudwatch_logs_to_firehose,
    aws_iam_role_policy_attachment.cloudwatch_logs_to_firehose_attachment,
    module.kinesis_firehose_to_splunk_logs
  ]
}

data "aws_iam_policy_document" "firehose_logs" {
  count = var.ship_logs_to_splunk ? 1 : 0
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = concat(
        [for account in var.bounded_context_account_ids : "${account.account_id}"],
        ["${var.aws_account_id}"]
      )
    }
    actions = ["logs:PutSubscriptionFilter"]
    resources = [
      aws_cloudwatch_log_destination.firehose_logs[0].arn,
      aws_cloudwatch_log_destination.firehose_logs_us[0].arn
    ]
  }
}

resource "aws_cloudwatch_log_destination_policy" "firehose_logs" {
  count            = var.ship_logs_to_splunk ? 1 : 0
  destination_name = aws_cloudwatch_log_destination.firehose_logs[0].name
  access_policy    = data.aws_iam_policy_document.firehose_logs[0].json
}

resource "aws_cloudwatch_log_destination" "firehose_logs_us" {
  count      = var.ship_logs_to_splunk ? 1 : 0
  provider   = aws.us-east-1
  name       = "${local.csi}-us-east-1-firehose-logs"
  target_arn = module.kinesis_firehose_to_splunk_logs[0].kinesis_firehose_arn
  role_arn   = aws_iam_role.cloudwatch_logs_to_firehose[0].arn

  depends_on = [
    aws_iam_role.cloudwatch_logs_to_firehose,
    aws_iam_role_policy_attachment.cloudwatch_logs_to_firehose_attachment,
    module.kinesis_firehose_to_splunk_logs.kinesis_firehose_arn
  ]
}

resource "aws_cloudwatch_log_destination_policy" "firehose_logs_us" {
  count            = var.ship_logs_to_splunk ? 1 : 0
  provider         = aws.us-east-1
  destination_name = aws_cloudwatch_log_destination.firehose_logs_us[0].name
  access_policy    = data.aws_iam_policy_document.firehose_logs[0].json
}
