data "aws_iam_policy_document" "sns_alerting_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:role/nhs-notify-${var.environment}-grafana-workspace-role"]
    }
    actions = ["sts:AssumeRole"]
  }
}
