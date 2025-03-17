resource "aws_ssm_parameter" "teams_webhook_url_cloudwatch_alarms" {
  name  = "${local.csi}-teams-webhook-url-cloudwatch-alarms"
  type  = "SecureString"
  value = "PLACEHOLDER_VALUE"

  lifecycle {
    ignore_changes = [value]
  }
}
