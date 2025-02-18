resource "aws_ssm_parameter" "teams_webhook_url_alerts" {
  name  = "${local.csi}-teams-webhook-url-alerts"
  type  = "SecureString"
  value = "PLACEHOLDER_VALUE"

  lifecycle {
    ignore_changes = [value]
  }
}
