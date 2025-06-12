resource "aws_cloudwatch_event_rule" "aws_backup_errors" {
  name           = "${local.csi}-aws-backup-errors"
  event_bus_name = data.terraform_remote_state.acct.outputs.acct_event_bus_name
  description    = "Triggers Lambda when an AWS Backup error is received"

  event_pattern = jsonencode({
    source        = ["aws.backup"],
    "detail-type" = ["Backup Job State Change", "Restore Job State Change", "Copy Job State Change"],
    detail = {
      state = ["FAILED", "ABORTED"]
    }
  })
}
