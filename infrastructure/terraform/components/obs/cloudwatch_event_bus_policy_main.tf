resource "aws_cloudwatch_event_bus_policy" "main" {
  event_bus_name = data.terraform_remote_state.acct.outputs.event_bus_name
  policy         = data.aws_iam_policy_document.main.json
}

data "aws_iam_policy_document" "main" {
  statement {
    sid    = "AllowOtherAccounts"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [for account in var.delegated_grafana_account_ids : account.account_id]
    }

    actions   = ["events:PutEvents"]
    resources = [data.terraform_remote_state.acct.outputs.event_bus_arn]
  }
}
