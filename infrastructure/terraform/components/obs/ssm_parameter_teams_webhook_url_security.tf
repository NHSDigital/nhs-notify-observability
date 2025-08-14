resource "aws_ssm_parameter" "teams_webhook_url_alerts_security" {
  name  = "${local.csi}-teams-webhook-url-security"
  type  = "SecureString"
  value = "PLACEHOLDER_VALUE"

  lifecycle {
    ignore_changes = [value]
  }
}
