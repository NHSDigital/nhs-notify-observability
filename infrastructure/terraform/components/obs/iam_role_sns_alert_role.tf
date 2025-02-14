
resource "aws_iam_role" "sns_alert_role" {
  name               = "${local.csi}-SNSAlertingRole"
  assume_role_policy = data.aws_iam_policy_document.sns_alerting_assume_role.json
}
