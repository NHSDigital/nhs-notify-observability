resource "aws_cloudwatch_event_bus_policy" "main" {
  event_bus_name = aws_cloudwatch_event_bus.main.name
  policy         = data.aws_iam_policy_document.main.json
}

data "aws_iam_policy_document" "main" {
  statement {
    sid    = "AllowOtherAccounts"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [for account in var.bounded_context_account_ids : account.account_id]
    }

    actions   = ["events:PutEvents"]
    resources = [aws_cloudwatch_event_bus.main.arn]
  }
}
