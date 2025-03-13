resource "aws_ssm_parameter" "teams_webhook_url_alerts_backup_errors" {
  name  = "${local.csi}-teams-webhook-url-backup-errors"
  type  = "SecureString"
  value = "PLACEHOLDER_VALUE"

  lifecycle {
    ignore_changes = [value]
  }
}
